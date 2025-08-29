import 'package:flutter_laranjinha_payment/constants/laranjinha_print_content_types.dart';

class LaranjinhaContentprint {
  final LaranjinhaPrintType type;
  final String? content;
  final LaranjinhaPrintAlign? align;
  final LaranjinhaPrintSize? size;
  final String? imagePath;
  final bool ignoreLineBreak;

  LaranjinhaContentprint({required this.type, this.content, this.align, this.size = LaranjinhaPrintSize.medium, this.imagePath, this.ignoreLineBreak = false})
    : assert(
        type != LaranjinhaPrintType.text || (content is String && align is LaranjinhaPrintAlign && size is LaranjinhaPrintSize),
        "content, align, and size must be defined when type is text",
      ),
      assert(type != LaranjinhaPrintType.image || imagePath is String, "imagePath cannot be null when type is image"),
      assert(type != LaranjinhaPrintType.line || content is String, "content cannot be null when type is line");

  /// Método para formatar o conteúdo evitando cortes no meio das palavras e tratando palavras maiores que o limite da linha.
  String _formatContent() {
    if (ignoreLineBreak == true) {
      return content ?? '';
    }
    if (type == LaranjinhaPrintType.image || content == null || size == null) return content ?? '';

    int maxLength = _getMaxLength(size!);
    List<String> lines = [];
    List<String> words = content!.split(' ');
    String currentLine = '';

    for (var word in words) {
      if (word.length > maxLength) {
        // Se a palavra for maior que o limite da linha, quebra a palavra
        if (currentLine.isNotEmpty) {
          lines.add(currentLine);
          currentLine = '';
        }

        // Divide a palavra em partes do tamanho máximo permitido
        for (int i = 0; i < word.length; i += maxLength) {
          lines.add(word.substring(i, (i + maxLength) > word.length ? word.length : (i + maxLength)));
        }
      } else if (currentLine.isEmpty) {
        currentLine = word;
      } else if ((currentLine.length + word.length + 1) <= maxLength) {
        currentLine += ' $word';
      } else {
        lines.add(currentLine);
        currentLine = word;
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    return lines.join("\n");
  }

  /// Retorna o tamanho máximo de caracteres permitido para cada tamanho de impressão
  int _getMaxLength(LaranjinhaPrintSize size) {
    switch (size) {
      case LaranjinhaPrintSize.small:
        return 48;
      case LaranjinhaPrintSize.medium:
      case LaranjinhaPrintSize.big:
        return 32;
    }
  }

  Map<String, dynamic> toJson() {
    bool disableAlignAndSize = type != LaranjinhaPrintType.text;

    return {
      'type': type.name.toString(),
      'content': type != LaranjinhaPrintType.image ? _formatContent() : null,
      'align': disableAlignAndSize ? null : align?.name.toString(),
      'size': disableAlignAndSize ? null : size?.name.toString(),
      'imagePath': type == LaranjinhaPrintType.image ? imagePath : null,
    };
  }

  static LaranjinhaContentprint fromJson(Map<String, dynamic> json) {
    return LaranjinhaContentprint(
      type: LaranjinhaPrintType.values.firstWhere((e) => e.name == json['type']),
      content: json['content'],
      align: json['align'] != null ? LaranjinhaPrintAlign.values.firstWhere((e) => e.name == json['align']) : null,
      size: LaranjinhaPrintSize.values.firstWhere((e) => e.name == json['size']),
      imagePath: json['imagePath'],
    );
  }
}
