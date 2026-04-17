import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/model/Property_model.dart';
import '../data/repo/Property_repo.dart';
import 'Property_state.dart';

class PropertyCubit extends Cubit<PropertyState> {
  PropertyCubit(this.repo) : super(PropertyInitial());

  static PropertyCubit get(context) => BlocProvider.of(context);

  final PropertyRepo repo;

  // Dropdowns
  String? selectedType;
  String? selectedStatus;

  // Search
  String searchText = "";

  double? minPrice;
  double? maxPrice;
  String? locationFilter;

  // Media
  List<File> images = [];
  List<File> videos = [];

  // Rooms
  int? rooms;
  int? beds;

  // Cache
  List<PropertyModel> myProperties = [];

  /// =========================
  /// STREAM MY PROPERTIES
  /// =========================
  Stream<List<PropertyModel>> myPropertiesStream(String uid) {
    return repo.getMyProperties(uid);
  }

  /// =========================
  /// CHANGE TYPE
  /// =========================
  void changeType(String type) {
    selectedType = type;
    emit(PropertyTypeChanged(type));
  }

  /// =========================
  /// CHANGE STATUS
  /// =========================
  void changeStatus(String status) {
    selectedStatus = status;
    emit(PropertyStatusChanged(status));
  }

  /// =========================
  /// PICK IMAGES
  /// =========================
  void pickImages(List<File> pickedImages) {
    images.addAll(pickedImages);
    emit(PropertyImagesPicked(images));
  }

  void removeImage(File image) {
    images.remove(image);
    emit(PropertyImagesPicked(images));
  }

  /// =========================
  /// PICK VIDEOS
  /// =========================
  void pickVideo(List<File> pickedVideos) {
    videos.addAll(pickedVideos);
    emit(PropertyVideosPicked(videos));
  }

  void removeVideo(File video) {
    videos.remove(video);
    emit(PropertyVideosPicked(videos));
  }

  /// =========================
  /// ADD OR UPDATE
  /// =========================
  Future<void> addOrUpdateProperty({
    required String title,
    required String description,
    required String location,
    required String price,
    PropertyModel? existingModel,
  }) async {
    emit(PropertyLoading());

    try {
      final model = PropertyModel(
        id: existingModel?.id,
        ownerId: existingModel?.ownerId,
        title: title,
        description: description,
        location: location,
        price: price,
        type: selectedType,
        status: selectedStatus,
        rooms: rooms,
        beds: beds,
        images: existingModel?.images,
        videos: existingModel?.videos,
        likes: existingModel?.likes ?? [],
        likesCount: existingModel?.likesCount ?? 0,
        favoritesCount: existingModel?.favoritesCount ?? 0,
        commentsCount: existingModel?.commentsCount ?? 0,
      );

      final result = await repo.addOrUpdateProperty(
        model: model,
        images: images,
        videos: videos,
      );

      result.fold(
            (err) => emit(PropertyError(err)),
            (prop) {
          emit(PropertySuccess());

          if (prop.ownerId != null) {
            getMyProperties(prop.ownerId!);
          }
        },
      );
    } catch (e) {
      emit(PropertyError(e.toString()));
    }
  }

  /// =========================
  /// DELETE
  /// =========================
  Future<void> deleteProperty(PropertyModel model) async {
    emit(PropertyLoading());

    final result = await repo.deleteProperty(
      model.id!,
      model.images,
      model.videos,
    );

    result.fold(
          (err) => emit(PropertyError(err)),
          (_) {
        emit(PropertySuccess());
        if (model.ownerId != null) {
          getMyProperties(model.ownerId!);
        }
      },
    );
  }

  /// =========================
  /// LIKE
  /// =========================
  void toggleLike(PropertyModel model, String uid) {
    if (model.likes!.contains(uid)) {
      model.likes!.remove(uid);
      model.likesCount = (model.likesCount ?? 0) - 1;
      repo.unlikeProperty(model.id!, uid);
    } else {
      model.likes!.add(uid);
      model.likesCount = (model.likesCount ?? 0) + 1;
      repo.likeProperty(model.id!, uid);
    }
    emit(PropertySuccess());
  }

  /// =========================
  /// FAVORITE
  /// =========================
  void toggleFavorite(PropertyModel model, String uid) {
    bool isFav = model.favoritesCount != null && model.favoritesCount! > 0;
    repo.toggleFavorite(model.id!, uid, isFav);
    emit(PropertySuccess());
  }

  /// =========================
  /// MY PROPERTIES
  /// =========================
  void getMyProperties(String uid) {
    emit(PropertyLoading());

    repo.getMyProperties(uid).listen((properties) {
      myProperties = properties;
      emit(PropertyLoaded(properties));
    });
  }

  /// =========================
  /// SIMPLE SEARCH
  /// =========================
  Stream<List<PropertyModel>> search(String query) {
    return repo.searchProperties(query);
  }

  /// =========================
  /// ADVANCED SEARCH (FIXED)
  /// =========================
  Future<List<PropertyModel>> searchAdvanced({
    required String search,
    DocumentSnapshot? lastDoc,
  }) async {
    try {
      final stream = repo.searchProperties(search);

      final list = await stream.first;

      /// 🔥 فلترة محلية (Client Side Filtering)
      List<PropertyModel> filtered = list.where((e) {

        /// 🔍 Type
        if (selectedType != null && e.type != selectedType) {
          return false;
        }

        /// 🔍 Status
        if (selectedStatus != null && e.status != selectedStatus) {
          return false;
        }

        /// 📍 Location
        if (locationFilter != null &&
            locationFilter!.isNotEmpty &&
            !(e.location ?? "")
                .toLowerCase()
                .contains(locationFilter!.toLowerCase())) {
          return false;
        }

        /// 💰 Price
        double price = double.tryParse(e.price ?? "0") ?? 0;

        if (minPrice != null && price < minPrice!) return false;
        if (maxPrice != null && price > maxPrice!) return false;

        return true;
      }).toList();

      return filtered;
    } catch (e) {
      return [];
    }
  }
}