enum AttachmentType { image, file }

class Attachment {
  final String path;
  final String name;
  final int sizeBytes;
  final AttachmentType type;
  final String? mimeType;

  Attachment({
    required this.path,
    required this.name,
    required this.sizeBytes,
    required this.type,
    this.mimeType,
  });

  Attachment copyWith({
    String? path,
    String? name,
    int? sizeBytes,
    AttachmentType? type,
    String? mimeType,
  }) {
    return Attachment(
      path: path ?? this.path,
      name: name ?? this.name,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      type: type ?? this.type,
      mimeType: mimeType ?? this.mimeType,
    );
  }
}
