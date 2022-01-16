part of 'geo_search_bloc.dart';

@immutable
abstract class GeoSearchEvent {}

class LoadNextSearchPage extends GeoSearchEvent {
  final String query;
  final String lang;
  final List<double> bounds;
  final List<double> center;

  LoadNextSearchPage(
      {required this.query,
      required this.lang,
      required this.bounds,
      required this.center});

  @override
  String toString() {
    return 'SubmitSearchKey{query: $query}';
  }
}

class SubmitSearchKey extends GeoSearchEvent {
  final String query;
  final String lang;
  final List<double> bounds;
  final List<double> center;

  SubmitSearchKey(
      {required this.query,
      required this.lang,
      required this.bounds,
      required this.center});

  @override
  String toString() {
    return 'SubmitSearchKey{query: $query}';
  }
}
