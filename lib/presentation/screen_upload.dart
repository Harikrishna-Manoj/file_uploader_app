import 'package:flutter/material.dart';
import 'package:tem_file_uploader/presentation/domain/service.dart';

class ScreenUploadFile extends StatelessWidget {
  const ScreenUploadFile({super.key});

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: GridView.builder(
          itemCount: 8,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // number of items in each row
            mainAxisSpacing: 8.0, // spacing between rows
            crossAxisSpacing: 8.0, // spacing between columns
          ),
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            return Container(
              height: 50,
              width: 50,
              color: Colors.amber,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await MediaUploadService.filepicker();
        },
      ),
    );
  }
}
