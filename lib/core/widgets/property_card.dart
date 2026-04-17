import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/Property/cubit/Property_cubit.dart';
import '../../features/Property/data/model/Property_model.dart';
import '../../features/Property/views/add_Property_views.dart';
import '../../features/home/views/comments_view.dart';

class PropertyCard extends StatelessWidget {
  final PropertyModel model;

  const PropertyCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    bool isOwner = model.ownerId == uid;

    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          if (model.images != null && model.images!.isNotEmpty)
            Image.network(model.images!.first, height: 200, fit: BoxFit.cover),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// ✅ Row فيها البيانات والتلت نقاط
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(model.title ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(model.location ?? ""),
                          Text("${model.price ?? ""} جنيه"),
                        ],
                      ),
                    ),

                    /// ✅ التلت نقاط بس لو صاحب المنشور
                    if (isOwner)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: PropertyCubit.get(context),
                                  child: AddPropertyView(existingModel: model),
                                ),
                              ),
                            );


                          } else if (value == 'delete') {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("حذف المنشور"),
                                content: const Text("هل أنت متأكد من حذف المنشور؟"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("إلغاء"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      PropertyCubit.get(context).deleteProperty(model);
                                    },
                                    child: const Text(
                                      "حذف",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text("تعديل"),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text("حذف", style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                /// ✅ Row التفاعلات
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        model.likes != null && model.likes!.contains(uid)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        PropertyCubit.get(context).toggleLike(model, uid);
                      },
                    ),
                    Text("${model.likesCount ?? 0}"),

                    const SizedBox(width: 10),

                    IconButton(
                      icon: Icon(
                        model.favoritesCount != null && model.favoritesCount! > 0
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        PropertyCubit.get(context)
                            .toggleFavorite(model, uid);
                      },
                    ),
                    Text("${model.favoritesCount ?? 0}"),

                    const SizedBox(width: 10),

                    IconButton(
                      icon: const Icon(Icons.comment),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CommentsView(propertyId: model.id!),
                          ),
                        );
                      },
                    ),
                    Text("${model.commentsCount ?? 0}"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}