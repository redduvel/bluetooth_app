// template_item.dart
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:equatable/equatable.dart';

abstract class TemplateItem extends Equatable {
  const TemplateItem();

  @override
  List<Object> get props => [];
}

class TemplateParagraph extends TemplateItem {
  final int weight;
  final int aling;
  final String content;

  const TemplateParagraph({required this.content, this.aling = LineText.ALIGN_LEFT, this.weight = 1});

  @override
  List<Object> get props => [content];
}

class TemplateImage extends TemplateItem {
  final String path;

  const TemplateImage({required this.path});

  @override
  List<Object> get props => [path];
}

class TemplateQRCode extends TemplateItem {
  final content;

  const TemplateQRCode({required this.content});

  @override
  List<Object> get props => [content];
}