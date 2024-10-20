import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/product.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/widgets/label_template_widget.dart';
import 'package:flutter/material.dart';

class ProductWidget extends StatefulWidget {
  final Product product;

  const ProductWidget({super.key, required this.product});

  @override
  State<ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  Color backgroundColor = AppColors.surface;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onHover: (value) {
        setState(() {
          if (value) {
            
          backgroundColor = AppColors.onSurface;
          }else {
            backgroundColor = AppColors.surface;
          }
        });
      },
      onTap: () {
        showDialog(context: context, builder: (context) => Dialog(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Text(
                  'Печать этикетки: ${widget.product.title}',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w500),
                ),
              ),
              const SliverToBoxAdapter(child: Divider()),
              SliverToBoxAdapter(child: LabelTemplateWidget(product: widget.product))
              
            ],
          ),
        ));
      },
      child: Container(
        width: 200,
        height: 175,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: backgroundColor, borderRadius: BorderRadius.circular(8)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.product.title,
                      style: AppTextStyles.labelMedium18,
                    ),
                    Text(
                      widget.product.category.name,
                      style: AppTextStyles.labelSmall12,
                    )
                  ],
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit))
              ],
            ),
            Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: widget.product.characteristics.map((c) {
                  return Text(c.toString(), style: AppTextStyles.bodyMedium16,);
      
                }).toList()
            )
                
          ],
        ),
      ),
    );
  }
}

