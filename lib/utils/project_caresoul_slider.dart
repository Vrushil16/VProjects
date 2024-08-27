import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProjectCarousel extends StatelessWidget {
  final List<String> imageUrls;
  final List<String> videoUrls;
  final void Function(String) onImageClick;

  const ProjectCarousel({
    Key? key,
    required this.imageUrls,
    required this.videoUrls,
    required this.onImageClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final isWeb = kIsWeb;
    return CarouselSlider(
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height * 0.5,
        autoPlay: true,
        enableInfiniteScroll: true,
        viewportFraction: 1.0,
      ),
      items: [...imageUrls, ...videoUrls].map((url) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () => onImageClick(url),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(url),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
