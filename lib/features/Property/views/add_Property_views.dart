import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../cubit/Property_cubit.dart';
import '../cubit/Property_state.dart';
import '../data/model/Property_model.dart';

class AddPropertyView extends StatelessWidget {
  final PropertyModel? existingModel;

  AddPropertyView({super.key, this.existingModel});

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final locationController = TextEditingController();
  final priceController = TextEditingController();

  final List<String> types = [
    "شقق",
    "فنادق",
    "فيلات",
    "محلات",
    "مراكز تدريب",
    "اراضي",
    "شقق للمغتربين",
  ];

  final List<String> statuses = [
    "للبيع",
    "للإيجار",
  ];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages(BuildContext context) async {
    final cubit = context.read<PropertyCubit>();
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      cubit.pickImages(pickedFiles.map((x) => File(x.path)).toList());
    }
  }

  Future<void> _pickVideo(BuildContext context) async {
    final cubit = context.read<PropertyCubit>();
    final XFile? pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      cubit.pickVideo([File(pickedFile.path)]);
    }
  }

  @override
  Widget build(BuildContext context) {
    var cubit = context.watch<PropertyCubit>();

    /// ✅ تحميل البيانات مرة واحدة بس
    if (existingModel != null && titleController.text.isEmpty) {
      titleController.text = existingModel!.title ?? "";
      descController.text = existingModel!.description ?? "";
      locationController.text = existingModel!.location ?? "";
      priceController.text = existingModel!.price ?? "";
      cubit.selectedType ??= existingModel!.type;
      cubit.selectedStatus ??= existingModel!.status;
      cubit.rooms ??= existingModel!.rooms;
      cubit.beds ??= existingModel!.beds;

      /// ❌ متحولش URL لـ File
      cubit.images = [];
      cubit.videos = [];
    }

    return BlocConsumer<PropertyCubit, PropertyState>(
      listener: (context, state) {
        if (state is PropertySuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("تم النشر ✅")),
          );
          cubit.getMyProperties(FirebaseAuth.instance.currentUser!.uid);
          Navigator.pop(context);
        } else if (state is PropertyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${state.error}")),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
              title: Text(existingModel != null ? "تعديل العقار" : "Add Property")),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 🖼️ Images + 🎥 Videos
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      GestureDetector(
                        onTap: () => _pickImages(context),
                        child: _addBox(Icons.image, "صور"),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _pickVideo(context),
                        child: _addBox(Icons.video_call, "فيديو"),
                      ),
                      const SizedBox(width: 10),

                      /// ✅ صور قديمة من Firebase
                      if (existingModel?.images != null)
                        ...existingModel!.images!.map((url) => Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              url,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )),

                      /// ✅ صور جديدة من الجهاز
                      ...cubit.images.map((img) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.file(
                                img,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: -5,
                              right: -5,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  cubit.removeImage(img);
                                },
                              ),
                            ),
                          ],
                        ),
                      )),

                      /// فيديوهات (زي ما هي)
                      ...cubit.videos.map((vid) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(Icons.play_arrow, size: 40),
                            ),
                            Positioned(
                              top: -5,
                              right: -5,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  cubit.removeVideo(vid);
                                },
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _dropdownField("الحالة", statuses, cubit.selectedStatus, cubit.changeStatus),
                const SizedBox(height: 15),
                _dropdownField("نوع العقار", types, cubit.selectedType, cubit.changeType),

                const SizedBox(height: 15),

                if (cubit.selectedType == "شقق للمغتربين") ...[
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          "Rooms",
                          isNumber: true,
                          onChanged: (v) => cubit.rooms = int.tryParse(v),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _field(
                          "Beds",
                          isNumber: true,
                          onChanged: (v) => cubit.beds = int.tryParse(v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                ],

                _field("Title", controller: titleController),
                _field("Description", controller: descController, maxLines: 3),
                _field("Location", controller: locationController),
                _field("Price", controller: priceController),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state is PropertyLoading
                        ? null
                        : () {
                      cubit.addOrUpdateProperty(
                        title: titleController.text,
                        description: descController.text,
                        location: locationController.text,
                        price: priceController.text,
                        existingModel: existingModel,
                      );
                    },
                    child: state is PropertyLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(existingModel != null ? "تعديل" : "Publish"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _addBox(IconData icon, String text) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          Text(text, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _field(String hint,
      {TextEditingController? controller,
        int maxLines = 1,
        bool isNumber = false,
        Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _dropdownField(
      String hint, List<String> items, String? value, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(hint),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (val) {
          if (val != null) onChanged(val);
        },
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }
}