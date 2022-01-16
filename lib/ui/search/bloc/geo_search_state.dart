part of 'geo_search_bloc.dart';

@immutable
abstract class GeoSearchState {}

class GeoSearchInitial extends GeoSearchState {}

class GeoSearchLoading extends GeoSearchState {}

class GeoSearchError extends GeoSearchState {}
class GeoSearchEmpty extends GeoSearchState {}

class GeoSearchResult extends GeoSearchState {
  final List<QueryResult> list;
  final bool lastPage;
  final int pageNumber;

  GeoSearchResult(this.list, this.lastPage, this.pageNumber);
}
