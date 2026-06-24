import 'package:aquarway/core/utils/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aquarway/features/auth/data/model/user_model.dart';
import 'package:aquarway/features/chat/views/chat_screen.dart';
import '../../features/Property/cubit/Property_cubit.dart';
import '../../features/Property/data/model/Property_model.dart';
import '../../features/Property/views/add_Property_views.dart';
import '../../features/chat/data/repo/chat_repo.dart';
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
  bool isExpanded = false;

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
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ================= HEADER (UNCHANGED) =================
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.model.ownerId)
                .get(),
            builder: (context, snapshot) {
              String name = "User";
              String image = "";

              if (snapshot.hasData && snapshot.data!.exists) {
                final data =
                snapshot.data!.data() as Map<String, dynamic>;

                name = (data['name'] ??
                    data['username'] ??
                    data['fullName'] ??
                    "User")
                    .toString();

                image = (data['image'] ?? data['photo'] ?? "")
                    .toString();
              }

              return Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [

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
                          PopupMenuItem(value: 'edit', child: Text("تعديل")),
                          PopupMenuItem(value: 'delete', child: Text("حذف")),
                        ],
                      ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [

                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Row(
                                children: [
                                  _smallTag(widget.model.type ?? ""),
                                  const SizedBox(width: 4),
                                  _smallTag(widget.model.status ?? ""),
                                ],
                              ),
                            ],
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
                  setState(() => currentIndex = index);
                },
                itemBuilder: (_, i) {
                  final item = media[i];

                  if (item["type"] == "image") {
                    return Image.network(
                      item["url"].toString(),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    );
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
                  margin: const EdgeInsets.symmetric(horizontal: 3),
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

                Text(widget.model.title ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold)),

                const SizedBox(height: 6),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.model.description ?? "",
                      maxLines: isExpanded ? null : 3,
                      overflow: isExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),

                    if ((widget.model.description ?? "").length > 100)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            isExpanded ? "عرض أقل" : "قراءة المزيد",
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 6),


                Text(widget.model.location ?? ""),
                Text("${widget.model.price ?? ""} جنيه"),

                const SizedBox(height: 5),

                Text("Type: ${widget.model.type ?? ""}"),
                Text("Status: ${widget.model.status ?? ""}"),

                if (widget.model.rooms != null)
                  Row(
                    children: [
                      const Text(
                        "Rooms: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      if (isOwner)
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            int current = widget.model.rooms ?? 0;

                            if (current > 0) {
                              PropertyCubit.get(context)
                                  .updateRooms(widget.model.id!, current - 1);
                            }
                          },
                        ),

                      Text("${widget.model.rooms}"),

                      if (isOwner)
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.green),
                          onPressed: () {
                            int current = widget.model.rooms ?? 0;

                            PropertyCubit.get(context)
                                .updateRooms(widget.model.id!, current + 1);
                          },
                        ),
                    ],
                  ),

                if (widget.model.beds != null)
                  Row(
                    children: [
                      const Text(
                        "Beds: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      if (isOwner)
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            int current = widget.model.beds ?? 0;

                            if (current > 0) {
                              PropertyCubit.get(context)
                                  .updateBeds(widget.model.id!, current - 1);
                            }
                          },
                        ),

                      Text("${widget.model.beds}"),

                      if (isOwner)
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.green),
                          onPressed: () {
                            int current = widget.model.beds ?? 0;

                            PropertyCubit.get(context)
                                .updateBeds(widget.model.id!, current + 1);
                          },
                        ),
                    ],
                  ),

                const SizedBox(height: 10),

                /// ================= ACTIONS =================
                Wrap(
                  spacing: 10,
                  runSpacing: 5,
                  children: [

                    /// LIKE
                    IconButton(
                      icon: Icon(
                        widget.model.likes != null &&
                            widget.model.likes!.contains(uid)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: widget.model.likes != null &&
                            widget.model.likes!.contains(uid)
                            ? Colors.red
                            : Colors.grey, // لون البوردر قبل اللايك
                      ),
                      onPressed: () {
                        PropertyCubit.get(context)
                            .toggleLike(widget.model, uid);
                      },
                    ),
                    Text("${widget.model.likesCount ?? 0}"),

                    const SizedBox(width: 10),

                    /// COMMENT
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

                    const SizedBox(width: 10),

                    /// FAVORITE
                    IconButton(
                      icon: Icon(
                        widget.model.favorites != null &&
                            widget.model.favorites!.contains(uid)
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: widget.model.favorites != null &&
                            widget.model.favorites!.contains(uid)
                            ? Colors.amber
                            : Colors.grey,
                        size: 28,
                      ),
                      onPressed: () {
                        PropertyCubit.get(context)
                            .toggleFavorite(widget.model, uid);
                      },
                    ),

                    Text("${widget.model.favoritesCount ?? 0}"),

                    const SizedBox(width: 10),

                    /// CHAT
                    IconButton(
                      icon: const Icon(
                        Icons.mark_unread_chat_alt_outlined,
                        color: Colors.black,
                      ),
                      onPressed: () async {
                        final doc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.model.ownerId)
                            .get();

                        final data =
                        doc.data() as Map<String, dynamic>?;

                        final otherUser = UserModel(
                          id: widget.model.ownerId,
                          username: data?['name'] ?? 'مالك العقار',
                          image: data?['image'] ?? '',
                        );

                        final myUser = UserModel(
                          id: uid,
                          username:
                          FirebaseAuth.instance.currentUser?.displayName,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              myUser: myUser,
                              otherUser: otherUser,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(width: 10),

                    /// BOOKING BUTTON
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.grenblak,
                      ),
                      icon: const Icon(Icons.book_online, size: 18),
                      label: const Text(
                        "طلب حجز",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        final uid = FirebaseAuth.instance.currentUser!.uid;

                        final myDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .get();

                        final myName = myDoc.data()?['name'] ?? "User";

                        final repo = ChatRepo();

                        await repo.sendBookingRequest(
                          myUid: uid,
                          myName: myName,
                          ownerId: widget.model.ownerId!,
                          propertyTitle: widget.model.title ?? "",
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallTag(String text) {
    if (text.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10),
      ),
    );
  }
}