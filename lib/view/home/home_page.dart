import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:product_hunt/controller/ai_controller.dart';
import 'package:product_hunt/model/product.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  Product? _product;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    print(_isLoading);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Epic Shit"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0).copyWith(bottom: 0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.file(
                      _image!,
                      height: 300,
                    ),
                  ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_outlined),
                  label: const Text("Pick Image"),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _image == null ? null : _generateText,
                      child: const Text("Hunt product"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _image == null
                          ? null
                          : () {
                              setState(() {
                                _product = null;
                                _image = null;
                              });
                            },
                      child: const Text("Remove image"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_product != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          // border: Border.all(color: Colors.grey),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(_product!.title ?? "title"),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          // border: Border.all(color: Colors.grey),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(_product!.description ?? "description"),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          // border: Border.all(color: Colors.grey),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(_product!.funFact ?? "fun fact"),
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 60,
                        width: MediaQuery.of(context).size.width,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 150,
                        width: MediaQuery.of(context).size.width,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 100,
                        width: MediaQuery.of(context).size.width,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  )
                      .animate(
                        onComplete: (controller) {
                          if (_isLoading) controller.repeat();
                        },
                        target: _isLoading ? 1 : 0,
                      )
                      .shimmer(color: Colors.white, delay: 500.milliseconds),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _generateText() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
      return;
    }

    final controller = AiController.getInstance();
    setState(() {
      _isLoading = true;
    });
    try {
      await Future.delayed(1.seconds);

      final product = await controller.getInformationAboutProduct(_image!);

      setState(() {
        _product = product;
        // _product = Product();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final action = await showCupertinoModalPopup<int?>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              child: const Text("Camera"),
              onPressed: () {
                Navigator.of(context).pop(0);
              },
            ),
            CupertinoActionSheetAction(
              child: const Text("Gallery"),
              onPressed: () {
                Navigator.of(context).pop(1);
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );

    if (action == null) return;

    final XFile? file;
    var picker = ImagePicker();
    if (action == 0) {
      // camera code here
      file = await picker.pickImage(source: ImageSource.camera);
    } else {
      // Gallery code here
      file = await picker.pickImage(source: ImageSource.gallery);
    }

    if (file == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected')),
        );
      }

      return;
    }
    final type = lookupMimeType(file.path);
    if (type == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image type not found')),
      );
      return;
    }

    if (type != 'image/jpeg') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image type not supported')),
      );
      return;
    }

    var image = File(file.path);
    setState(() {
      _image = image;
    });
  }
}
