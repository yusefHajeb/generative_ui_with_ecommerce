import 'package:flutter/material.dart';
import 'package:generative_ui_with_ecommerce/features/home_page/presentation/widgets/status_image.dart';

class StatusWidget extends StatelessWidget {
  const StatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: Column(
        children: [
          StatusImage(),
          SizedBox(height: 8),
          Text(
            '@ٌusername',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
              textBaseline: TextBaseline.ideographic,
              color: Color(0xFF433000),
            ),
          ),
        ],
      ),
    );
  }
}
