import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas/helpers/debouncer.dart';
import 'package:peliculas/models/models.dart';

//En vez de provider se puede poner service ;)
class MoviesProvider extends ChangeNotifier {
  final String _baseUrl = 'api.themoviedb.org';
  final String _apiKey = '756a1432468019d8f66bfcc946fa99e4';
  final String _language = 'es-ES';

  List<Movie> onDisplayMovies = [];

  List<Movie> popularMovies = [];
  int _popularPage = 0;

  Map<int, List<Cast>> moviesCasts = {};

  final debouncer = Debouncer(
    duration: const Duration(milliseconds: 500),
  );

  final StreamController<List<Movie>> _suggestionStreamContoller =
      StreamController.broadcast();
  Stream<List<Movie>> get suggestionStream => _suggestionStreamContoller.stream;

  MoviesProvider() {
    getOnDisplayMovies();
    getPopularMovies();
  }

  Future<String> _getJsonData(String segmento, [int pagina = 1]) async {
    final url = Uri.https(_baseUrl, segmento, {
      'api_key': _apiKey,
      'language': _language,
      'page': '$pagina',
    });

    var response = await http.get(url);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return "";
    }
  }

  getOnDisplayMovies() async {
    final jsonData = await _getJsonData('3/movie/now_playing');
    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);

    onDisplayMovies = nowPlayingResponse.results;

    notifyListeners();
  }

  getPopularMovies() async {
    _popularPage++;

    final jsonData = await _getJsonData('3/movie/popular', _popularPage);
    final popularResponse = PopularResponse.fromJson(jsonData);

    popularMovies = [...popularMovies, ...popularResponse.results];
    notifyListeners();
  }

  Future<List<Cast>> getMovieCasts(int movieId) async {
    if (moviesCasts.containsKey(movieId)) {
      return moviesCasts[movieId]!;
    } else {
      final jsonData =
          await _getJsonData('3/movie/$movieId/credits', _popularPage);

      final creditsResponse = CreditsResponse.fromJson(jsonData);
      moviesCasts[movieId] = creditsResponse.cast;
      return creditsResponse.cast;
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    final url = Uri.https(_baseUrl, '3/search/movie',
        {'api_key': _apiKey, 'language': _language, 'query': query});

    final response = await http.get(url);
    final searchResponse = SearchResponse.fromJson(response.body);

    return searchResponse.results;
  }

  void getSuggestionsByQuery(String searchTerm) {
    debouncer.value = '';
    debouncer.onValue = (value) async {
      final results = await searchMovies(value);
      _suggestionStreamContoller.add(results);
    };

    final timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      debouncer.value = searchTerm;
    });

    Future.delayed(const Duration(milliseconds: 301))
        .then((_) => timer.cancel());
  }
}
