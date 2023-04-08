import 'package:flutter/material.dart';
import 'package:peliculas/providers/movie_provider.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';

class MovieSearchDelegate extends SearchDelegate {
  @override
  String get searchFieldLabel => 'Buscar Pelicula';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return const Text('buildResults');
  }

  Widget _emptyContainer() {
    return Container(
        child: const Center(
      child: Icon(
        Icons.movie_creation_outlined,
        color: Colors.black38,
        size: 130,
      ),
    ));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _emptyContainer();
    }

    final moviesProvider = Provider.of<MoviesProvider>(context, listen: false);
    moviesProvider.getSuggestionsByQuery(query);

    return StreamBuilder(
      stream: moviesProvider.suggestionStream,
      builder: (_, AsyncSnapshot<List<Movie>> snapshot) {
        if (!snapshot.hasData) return _emptyContainer();

        final movies = snapshot.data!;

        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (_, int index) => _MovieItem(movies[index]),
        );
      },
    );
  }
}

class _MovieItem extends StatelessWidget {
  final Movie movies;
  const _MovieItem(this.movies);

  @override
  Widget build(BuildContext context) {
    movies.heroId = 'seacrh-${movies.id}';
    return ListTile(
      leading: Hero(
        tag: movies.heroId!,
        child: FadeInImage(
          placeholder: const AssetImage('assets/no-image.jpg'),
          image: NetworkImage(movies.fullBackdropPath),
          width: 50,
          fit: BoxFit.contain,
        ),
      ),
      title: Text(movies.title),
      subtitle: Text(movies.originalTitle),
      onTap: () {
        Navigator.pushNamed(context, 'details', arguments: movies);
      },
    );
  }
}
