import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';

class CardSwiperWidget extends StatelessWidget {
  final List<Movie> movies;

  const CardSwiperWidget({Key? key, required this.movies}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (movies.isEmpty) {
      return SizedBox(
        width: double.infinity,
        height: size.height * 0.5,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: size.height * 0.5,
      child: Swiper(
        itemCount: movies.length,
        layout: SwiperLayout.STACK,
        itemWidth: size.width * .6,
        itemHeight: size.height * .9,
        itemBuilder: (BuildContext context, int index) {
          //final movie = movies[index];
          movies[index].heroId = 'swiper-${movies[index].id}';
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, 'details',
                arguments: movies[index]),
            child: Hero(
              tag: movies[index].heroId!,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FadeInImage(
                  placeholder: const AssetImage('assets/no-image.jpg'),
                  image: NetworkImage(movies[index].fullPosterImg),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
