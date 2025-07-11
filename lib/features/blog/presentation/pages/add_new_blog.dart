import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wlog/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:wlog/core/common/widgets/app_navigation_bar.dart';
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
  Uint8List? webImage; // For web platforms
  final formKey = GlobalKey<FormState>();

  // Function to pick image from specified source
  void selectImage(ImageSource source) async {
    if (kIsWeb) {
      // Web implementation
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        var f = await image.readAsBytes();
        setState(() {
          webImage = f;
          imagePicked = File("dummy"); // Dummy file for web
        });
      }
    } else {
      // Mobile/desktop implementation
      final image = await pickImage(source: source);
      if (image != null) {
        setState(() {
          imagePicked = image;
        });
      }
    }
  }

  // Gallery picker helper
  void pickImageFromGalleryBlog() async {
    if (kIsWeb) {
      selectImage(ImageSource.gallery);
    } else {
      final image = await pickImageFromGallery();
      if (image != null) {
        setState(() {
          imagePicked = image;
        });
      }
    }
  }

  // Camera picker helper
  void pickImageFromCameraBlog() async {
    if (kIsWeb) {
      selectImage(ImageSource.camera);
    } else {
      final image = await pickImageFromCamera();
      if (image != null) {
        setState(() {
          imagePicked = image;
        });
      }
    }
  }

  // Helper method to show image source dialog
  void showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                pickImageFromGalleryBlog();
              },
              child: const Text('Gallery'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                pickImageFromCameraBlog();
              },
              child: const Text('Camera'),
            ),
          ],
        ),
      ),
      barrierDismissible: true,
    );
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
                  (imagePicked != null || webImage != null) &&
                  selectedTags.isNotEmpty) {
                final posterId = context.read<AppUserCubit>().state.user?.id;
                if (posterId == null || posterId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('User not authenticated. Please login again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                print('Starting blog upload for user: $posterId'); // Debug log
                context.read<BlogBloc>().add(UploadBlogEvent(
                      image: imagePicked!,
                      title: titleController.text.trim(),
                      content: contentController.text.trim(),
                      topics: selectedTags,
                      posterId: posterId,
                      webImage: webImage, // Pass webImage for web platforms
                    ));
              } else {
                // Show validation errors
                String errorMessage = '';
                if (!formKey.currentState!.validate()) {
                  errorMessage = 'Please fill in all required fields.';
                } else if (imagePicked == null && webImage == null) {
                  errorMessage = 'Please select an image.';
                } else if (selectedTags.isEmpty) {
                  errorMessage = 'Please select at least one tag.';
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogUploadSuccess) {
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
                    // Image Upload Section with Animation
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: (imagePicked != null || webImage != null)
                          ? GestureDetector(
                              onTap: () {
                                showImageSourceDialog();
                              },
                              child: SizedBox(
                                width: double.infinity,
                                height: 150,
                                child: kIsWeb
                                    ? Image.memory(
                                        webImage!,
                                        fit: BoxFit.contain,
                                      )
                                    : Image.file(
                                        imagePicked!,
                                        fit: BoxFit.contain,
                                      ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                showImageSourceDialog();
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
                    ),

                    // Tags Section with Animation
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                'Facebook',
                                'Instagram',
                                'Tiktok',
                                'Linkedin',
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
                                            backgroundColor:
                                                selectedTags.contains(e)
                                                    ? AppPallete.gradient1
                                                    : Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                        ],
                      ),
                    ),

                    // Title Field with Animation
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1000),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          TextFieldContent(
                            hintText: 'Post Title',
                            controller: titleController,
                            maxlines: 1,
                          ),
                        ],
                      ),
                    ),

                    // Content Field with Animation
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1200),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          TextFieldContent(
                            hintText: 'Post Content',
                            controller: contentController,
                            maxlines: null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const AppNavigationBar(currentIndex: 2),
    );
  }
}
