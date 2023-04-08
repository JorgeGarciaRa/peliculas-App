import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas/helpers/debouncer.dart';

import '../models/models.dart';

class MoviesProvider extends ChangeNotifier {
  String _baseUrl = 'api.themoviedb.org';
  String _apiKey = '53872918aeae35ef42fbf86631856821';
  String _language = 'es-ES';

  List<Movie> onDisplayMovie = [];
  List<Movie> popularMovie = [];
  List<Movie> topRatedMovie = [];

  Map<int, List<Cast>> moviesCast = {};

  int _popularPage = 0;
  final debouncer = Debouncer(
    duration: const Duration(milliseconds: 500),
  );

  final StreamController<List<Movie>> _suggestionStreamController =
      StreamController.broadcast();

  Stream<List<Movie>> get suggestionStream =>
      _suggestionStreamController.stream;

  MoviesProvider() {
    getOnDisplayMovies();
    getPopularMovies();
    getTopRatedMovies();
  }

  Future<String> _getJsonData(String endPoint, [int page = 1]) async {
    final url = Uri.https(_baseUrl, endPoint, {
      'api_key': _apiKey,
      'language': _language,
      'page': '$page',
    });

    final response = await http.get(url);
    return response.body;
  }

  getOnDisplayMovies() async {
    final jsonData = await _getJsonData('3/movie/now_playing');
    final nowPlayResponse = NowPlayingResponse.fromJson(jsonData);
    onDisplayMovie = nowPlayResponse.results;
    notifyListeners();
  }

  getPopularMovies() async {
    _popularPage++;
    final jsonData = await _getJsonData(
      '3/movie/popular',
      _popularPage,
    );
    final popularResponse = PopularResponse.fromJson(jsonData);
    popularMovie = [...popularMovie, ...popularResponse.results];
    notifyListeners();
  }

  getTopRatedMovies() async {
    _popularPage++;
    final jsonData = await _getJsonData('3/movie/top_rated', _popularPage);

    final topRatedResponse = TopRatedResponse.fromJson(jsonData);
    topRatedMovie = [...topRatedMovie, ...topRatedResponse.results];
    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int movieId) async {
    if (moviesCast.containsKey(movieId)) return moviesCast[movieId]!;

    final jsonData = await _getJsonData('3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromJson(jsonData);
    moviesCast[movieId] = creditsResponse.cast;
    return creditsResponse.cast;
  }

  Future<List<Movie>> searchMovie(String query) async {
    final url = Uri.https(_baseUrl, '3/search/movie', {
      'api_key': _apiKey,
      'language': _language,
      'query': query,
    });

    final response = await http.get(url);
    final searchResponse = SearchResponse.fromJson(response.body);
    return searchResponse.results;
  }

  void getSuggestionsByQuery(String searchTerm) {
    debouncer.value = '';
    debouncer.onValue = (value) async {
      final results = await searchMovie(value);
      _suggestionStreamController.add(results);
    };

    final timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      debouncer.value = searchTerm;
    });

    Future.delayed(const Duration(milliseconds: 301))
        .then((_) => timer.cancel());
  }
}
