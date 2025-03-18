import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CarouselImage extends StatefulWidget {
  final List<String> imageLinks;

  const CarouselImage({super.key, required this.imageLinks});

  @override
  State<CarouselImage> createState() => _CarouselImageState();
}

class _CarouselImageState extends State<CarouselImage> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.imageLinks.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CarouselSlider(
          items: widget.imageLinks.map((path) {
            return Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: path,
                  fit: BoxFit.fill,
                  // width: 180,
                ),
              ),
            );
          }).toList(),
          options: CarouselOptions(
            height: 200,
            padEnds: false,
            disableCenter: true,
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: widget.imageLinks.asMap().entries.map((e) {
        //     return Container(
        //       width: 8,
        //       height: 8,
        //       margin: const EdgeInsets.symmetric(horizontal: 4),
        //       decoration: BoxDecoration(
        //         shape: BoxShape.circle,
        //         color: Theme.of(context)
        //             .colorScheme
        //             .secondary
        //             .withOpacity(_current == e.key ? .9 : .4),
        //       ),
        //     );
        //   }).toList(),
        // ),
      ],
    );
  }
}
