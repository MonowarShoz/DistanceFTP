import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:geolocator/geolocator.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  Future<void> uploadImageToFtp(File clickedImage) async {
    try {
      FTPConnect ftpConnect = FTPConnect(
        '103.110.218.55',
        user: 'administrator',
        pass: 'asit@123',
      );
      await ftpConnect.connect();
      await ftpConnect.changeDirectory('monowar');
      bool res = await ftpConnect.uploadFile(
        clickedImage,
      );

      if (res) {
        setState(() {
          clickedImage.existsSync() ? clickedImage.delete() : '';
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File sent successfully'),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send file'),
          ),
        );
      }

      await ftpConnect.disconnect();
      debugPrint('$res');
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    File? clickedImage = File(widget.imagePath);
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: Column(
        children: [
          clickedImage.existsSync()
              ? Image.file(
                  clickedImage,
                )
              : SizedBox.shrink(),
          Center(
            child: ElevatedButton.icon(
              onPressed: () async {
                uploadImageToFtp(clickedImage);
              },
              icon: Icon(Icons.send),
              label: Text('Send this image to the FTP Server'),
            ),
          ),
        ],
      ),
    );
  }
}
