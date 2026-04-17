import 'dart:io';

import '../data/model/Property_model.dart';

abstract class PropertyState {}

class PropertyInitial extends PropertyState {}

class PropertyLoading extends PropertyState {}

class PropertySuccess extends PropertyState {}

class PropertyError extends PropertyState {
  final String error;
  PropertyError(this.error);
}

/// اختيار نوع العقار
class PropertyTypeChanged extends PropertyState {
  final String selectedType;
  PropertyTypeChanged(this.selectedType);
}

/// اختيار الحالة
class PropertyStatusChanged extends PropertyState {
  final String selectedStatus;
  PropertyStatusChanged(this.selectedStatus);
}

/// اختيار صور
class PropertyImagesPicked extends PropertyState {
  final List<File> images;
  PropertyImagesPicked(this.images);
}

/// اختيار فيديوهات
class PropertyVideosPicked extends PropertyState {
  final List<File> videos;
  PropertyVideosPicked(this.videos);
}

/// ✅ جديد (لايك)
class PropertyLikeChanged extends PropertyState {}


/// ✅ حالة جديدة لجلب العقارات
class PropertyLoaded extends PropertyState {
  final List<PropertyModel> properties;
  PropertyLoaded(this.properties);
}