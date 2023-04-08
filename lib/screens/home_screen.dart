import 'package:flutter/material.dart';
import 'package:peliculas/providers/movie_provider.dart';
import 'package:peliculas/search/search_delegate.dart';
import 'package:provider/provider.dart';
import '../widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moviesProvider = Provider.of<MoviesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peliculas App'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () =>
                showSearch(context: context, delegate: MovieSearchDelegate()),
            icon: const Icon(Icons.search),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CardSwiper(movies: moviesProvider.onDisplayMovie),
            MovieSlider(
                movies: moviesProvider.popularMovie,
                title: 'populares!',
                onNextPage: () => moviesProvider.getPopularMovies()),
            const SizedBox(height: 10),
            MovieSlider(
                movies: moviesProvider.topRatedMovie,
                title: 'Top Rated',
                onNextPage: () => moviesProvider.getTopRatedMovies()),
          ],
        ),
      ),
    );
  }
}
