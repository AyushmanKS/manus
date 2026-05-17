import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:manus/core/models/attachment.dart';
import 'package:manus/core/utils/app_logger.dart';
import 'package:mime/mime.dart';

class AttachmentService {
  final ImagePicker _imagePicker = ImagePicker();

  Future<Attachment?> pickFromCamera(final BuildContext context) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) return null;

      final int size = await _getFileSize(image.path);
      return Attachment(
        path: image.path,
        name: image.name,
        sizeBytes: size,
        type: AttachmentType.image,
        mimeType: lookupMimeType(image.path),
      );
    } catch (e, stack) {
      AppLogger.error('Error picking image from camera', e, stack);
      if (e.toString().contains('permission')) {
        if (context.mounted) {
          _showPermissionError(context, 'Camera');
        }
      }
      return null;
    }
  }

  Future<List<Attachment>> pickFromGallery(final BuildContext context) async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );

      if (images.isEmpty) return <Attachment>[];

      final List<Attachment> attachments = <Attachment>[];
      for (final XFile image in images) {
        final int size = await _getFileSize(image.path);
        attachments.add(
          Attachment(
            path: image.path,
            name: image.name,
            sizeBytes: size,
            type: AttachmentType.image,
            mimeType: lookupMimeType(image.path),
          ),
        );
      }
      return attachments;
    } catch (e, stack) {
      AppLogger.error('Error picking images from gallery', e, stack);
      if (e.toString().contains('permission')) {
        if (context.mounted) {
          _showPermissionError(context, 'Photo Library');
        }
      }
      return <Attachment>[];
    }
  }

  Future<List<Attachment>> pickFiles(final BuildContext context) async {
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: <String>[
          'pdf',
          'doc',
          'docx',
          'txt',
          'csv',
          'xls',
          'xlsx',
        ],
      );

      if (result == null || result.files.isEmpty) return <Attachment>[];

      final List<Attachment> attachments = <Attachment>[];
      for (final PlatformFile file in result.files) {
        if (file.path == null) continue;

        attachments.add(
          Attachment(
            path: file.path!,
            name: file.name,
            sizeBytes: file.size,
            type: _getAttachmentType(file.path!),
            mimeType: lookupMimeType(file.path!),
          ),
        );
      }
      return attachments;
    } catch (e, stack) {
      AppLogger.error('Error picking files', e, stack);
      if (e.toString().contains('permission')) {
        if (context.mounted) {
          _showPermissionError(context, 'Files');
        }
      }
      return <Attachment>[];
    }
  }

  Future<int> _getFileSize(final String path) async {
    return File(path).length();
  }

  AttachmentType _getAttachmentType(final String path) {
    final String? mime = lookupMimeType(path);
    if (mime != null && mime.startsWith('image/')) {
      return AttachmentType.image;
    }
    return AttachmentType.file;
  }

  void _showPermissionError(
    final BuildContext context,
    final String permission,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Manus needs $permission access to attach files.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

final Provider<AttachmentService> attachmentServiceProvider =
    Provider<AttachmentService>((final Ref ref) => AttachmentService());
