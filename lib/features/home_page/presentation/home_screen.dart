import 'package:flutter/material.dart';
import 'package:generative_ui_with_ecommerce/core/theme/app_color.dart';
import 'package:generative_ui_with_ecommerce/core/widgets/bottom_navigation_bar.dart';
import 'package:generative_ui_with_ecommerce/core/widgets/chip_button.dart';
import 'package:generative_ui_with_ecommerce/core/widgets/icon_widget.dart';
import 'package:generative_ui_with_ecommerce/core/widgets/row_icons.dart'; // IconGroup widget

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: ButtomNavigationBar(),
      ),
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconWidget(isHaveBackgroundColor: true, icon: Icon(Icons.home)),
            const Center(child: Text('مرحبا بك في الصفحه الرئيسية!')),
            TextFormField(decoration: const InputDecoration(hintText: 'ادخل نصا هنا')),
            ElevatedButton(onPressed: () {}, child: Text('اضغط هنا')),
            SizedBox(height: 30),
            ChipButton(label: 'items', onPressed: () {}),
            ChipButton(
              label: 'outside',
              onPressed: () {},

              iconWidget: Icon(Icons.arrow_forward_ios, size: 12),
            ),

            SizedBox(height: 20),

            IconGroup(
              isVertical: false,
              icons: [
                IconWidget(
                  isHaveBackgroundColor: true,
                  icon: Icon(Icons.home, size: 23),
                  backgroundColor: Colors.white,
                ),
                IconWidget(isHaveBackgroundColor: true, icon: Icon(Icons.search, size: 23)),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: IconWidget(
                padding: EdgeInsets.all(8),
                isHaveBackgroundColor: true,
                icon: Icon(Icons.home, size: 23, color: Colors.black),
                backgroundColor: AppColors.primary100,
              ),
            ),
            SizedBox(height: 16),
            Align(
              alignment: AlignmentGeometry.topRight,
              child: IconGroup(
                isVertical: true,
                icons: [
                  IconWidget(
                    isHaveBackgroundColor: true,
                    icon: Icon(Icons.home, size: 23),
                    backgroundColor: Colors.white,
                  ),
                  IconWidget(isHaveBackgroundColor: true, icon: Icon(Icons.search, size: 23)),
                ],
              ),
            ),
            IconGroup(
              backgrounndColor: Colors.transparent,
              isVertical: false,
              icons: [
                IconWidget(
                  isHaveBackgroundColor: true,
                  icon: Text('items'),
                  backgroundColor: Colors.white,
                ),
                IconWidget(isHaveBackgroundColor: true, icon: Icon(Icons.search, size: 23)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
