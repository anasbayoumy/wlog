import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wlog/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:wlog/core/theme/theme_pallet.dart';
import 'package:wlog/core/utils/imagepicker.dart';
import 'package:wlog/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:wlog/features/blog/presentation/pages/blog_page.dart';
import 'package:wlog/features/blog/presentation/widgets/textfield_content.dart';

class AddNewBlogPage extends StatefulWidget {
  const AddNewBlogPage({super.key});

  @override
  State<AddNewBlogPage> createState() => _AddNewBlogPageState();
}

class _AddNewBlogPageState extends State<AddNewBlogPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  List<String> selectedTags = [];
  File? imagePicked;
  final formKey = GlobalKey<FormState>();

  void pickImageFromGalleryBlog() async {
    final image = await pickImageFromGallery();
    if (image != null) {
      setState(() {
        imagePicked = image;
      });
    }
  }

  void pickImageFromCameraBlog() async {
    final image = await pickImageFromCamera();
    if (image != null) {
      setState(() {
        imagePicked = image;
      });
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Blog'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              if (formKey.currentState!.validate() &&
                  imagePicked != null &&
                  selectedTags.isNotEmpty) {
                final posterId = context.read<AppUserCubit>().state.user?.id;
                if (posterId != null) {
                  context.read<BlogBloc>().add(UploadBlogEvent(
                        image: imagePicked!,
                        title: titleController.text,
                        content: contentController.text,
                        topics: selectedTags,
                        posterId: posterId,
                      ));
                }
              }
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Blog uploaded successfully')),
            );
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const BlogPage()),
                (route) => false);
          } else if (state is BlogFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is BlogLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    imagePicked != null
                        ? GestureDetector(
                            onTap: () {
                              pickImageFromGalleryBlog();
                            },
                            child: SizedBox(
                              width: double.infinity,
                              height: 150,
                              child: Image.file(
                                imagePicked!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Select Image'),
                                  content: Column(
                                    children: [
                                      TextButton(
                                          onPressed: () {
                                            pickImageFromGalleryBlog();
                                          },
                                          child: const Text('Gallery')),
                                      TextButton(
                                          onPressed: () {
                                            pickImageFromCameraBlog();
                                          },
                                          child: const Text('Camera')),
                                    ],
                                  ),
                                ),
                                barrierDismissible: true,
                              );
                            },
                            child: DottedBorder(
                              radius: const Radius.circular(20),
                              color: Colors.grey,
                              borderType: BorderType.RRect,
                              dashPattern: const [10, 5],
                              child: const SizedBox(
                                height: 150,
                                width: double.infinity,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.drive_folder_upload_rounded),
                                    SizedBox(height: 20),
                                    Text('Upload'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'Title1',
                          'title2',
                          'title3',
                          'title4',
                          'title5',
                          'title6',
                          'title7',
                          'title8',
                          'title9',
                        ]
                            .map((e) => Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (selectedTags.contains(e)) {
                                        setState(() {
                                          selectedTags.remove(e);
                                        });
                                      } else {
                                        setState(() {
                                          selectedTags.add(e);
                                        });
                                      }
                                    },
                                    child: Chip(
                                      label: Text(e),
                                      backgroundColor: selectedTags.contains(e)
                                          ? AppPallete.gradient1
                                          : Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: selectedTags.contains(e)
                                              ? AppPallete.backgroundColor
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFieldContent(
                      hintText: 'Vlog Title',
                      controller: titleController,
                      maxlines: 1,
                    ),
                    const SizedBox(height: 20),
                    TextFieldContent(
                      hintText: 'Vlog Content',
                      controller: contentController,
                      maxlines: null,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
