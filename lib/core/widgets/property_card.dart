import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/Property/cubit/Property_cubit.dart';
import '../../features/Property/data/model/Property_model.dart';
import '../../features/Property/views/add_Property_views.dart';
import '../../features/home/views/comments_view.dart';

class PropertyCard extends StatefulWidget {
  final PropertyModel model;

  const PropertyCard({super.key, required this.model});

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    bool isOwner = widget.model.ownerId == uid;

    final images = widget.model.images ?? [];
    final videos = widget.model.videos ?? [];

    final media = [
      ...images.map((e) => {"type": "image", "url": e}),
      ...videos.map((e) => {"type": "video", "url": e}),
    ];

    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ================= HEADER (FIXED UI) =================
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.model.ownerId)
                .get(),
            builder: (context, snapshot) {
              String name = "User";
              String image = "";

              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>;

                name = (data['name'] ??
                    data['username'] ??
                    data['fullName'] ??
                    "User")
                    .toString();

                image = (data['image'] ??
                    data['photo'] ??
                    "")
                    .toString();
              }

              return Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [

                    /// ================= LEFT: DOTS MENU =================
                    if (isOwner)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: PropertyCubit.get(context),
                                  child: AddPropertyView(
                                    existingModel: widget.model,
                                  ),
                                ),
                              ),
                            );
                          } else if (value == 'delete') {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("حذف المنشور"),
                                content: const Text("هل أنت متأكد؟"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context),
                                    child: const Text("إلغاء"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      PropertyCubit.get(context)
                                          .deleteProperty(widget.model);
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
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                              value: 'edit', child: Text("تعديل")),
                          PopupMenuItem(
                              value: 'delete', child: Text("حذف")),
                        ],
                      ),

                    const SizedBox(width: 10),

                    /// ================= RIGHT: USER =================
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 18,
                            backgroundImage:
                            image.isNotEmpty ? NetworkImage(image) : null,
                            child: image.isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          /// ================= MEDIA =================
          if (media.isNotEmpty)
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _controller,
                itemCount: media.length,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (_, i) {
                  final item = media[i];
                  final url = item["url"];

                  if (item["type"] == "image") {
                    if (url == null || url.toString().isEmpty) {
                      return const Icon(Icons.broken_image);
                    }

                    return Image.network(
                      url.toString(),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.error),
                    );
                  }

                  if (url == null || url.toString().isEmpty) {
                    return const Icon(Icons.videocam_off);
                  }

                  return const Center(
                    child: Icon(Icons.play_circle_fill, size: 50),
                  );
                },
              ),
            ),

          /// ================= DOTS =================
          if (media.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                media.length,
                    (index) => Container(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
                  width: currentIndex == index ? 10 : 6,
                  height: currentIndex == index ? 10 : 6,
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? Colors.blue
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

          /// ================= INFO =================
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.model.title ?? "",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          Text(widget.model.location ?? ""),
                          Text("${widget.model.price ?? ""} جنيه"),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        widget.model.likes != null &&
                            widget.model.likes!.contains(uid)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        PropertyCubit.get(context)
                            .toggleLike(widget.model, uid);
                      },
                    ),
                    Text("${widget.model.likesCount ?? 0}"),

                    const SizedBox(width: 10),

                    IconButton(
                      icon: Icon(
                        (widget.model.favoritesCount ?? 0) > 0
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        PropertyCubit.get(context)
                            .toggleFavorite(widget.model, uid);
                      },
                    ),
                    Text("${widget.model.favoritesCount ?? 0}"),

                    const SizedBox(width: 10),

                    IconButton(
                      icon: const Icon(Icons.comment),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CommentsView(
                              propertyId: widget.model.id!,
                            ),
                          ),
                        );
                      },
                    ),
                    Text("${widget.model.commentsCount ?? 0}"),
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