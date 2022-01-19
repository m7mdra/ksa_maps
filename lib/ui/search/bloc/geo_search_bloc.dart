import 'package:bloc/bloc.dart';
import 'package:ksa_maps/data/error_handler.dart';
import 'package:ksa_maps/data/map_data_repository.dart';
import 'package:ksa_maps/data/model/query_result.dart';
import 'package:meta/meta.dart';
import 'package:stream_transform/stream_transform.dart';

part 'geo_search_event.dart';

part 'geo_search_state.dart';

const _duration = Duration(milliseconds: 300);

class GeoSearchBloc extends Bloc<GeoSearchEvent, GeoSearchState> {
  final MapDataRepository _client;
  var _pageNumber = 1;

  GeoSearchBloc(this._client) : super(GeoSearchInitial()) {
    on<SubmitSearchKey>((event, emit) async {
      if (event.query.isEmpty) {
        return;
      }
      try {
        emit(GeoSearchClearState());
        emit(GeoSearchLoading());
        _pageNumber = 1;
        var response = await _client.geoSearch(
            event.query, event.lang, event.bounds, event.center);
        var list = response.list;
        if (list.isEmpty) {
          emit(GeoSearchEmpty());
        } else {
          _pageNumber += 1;
          emit(GeoSearchResult(list, false, _pageNumber));
        }
      } catch (error) {
        print(error);
        if (error is CancelException) {
          emit(GeoSearchInitial());
        } else {
          emit(GeoSearchError());
        }
      }
    }, transformer: debounce(_duration));
    on<LoadNextSearchPage>((event, emit) async {
      if (event.query.isEmpty) {
        return;
      }

      try {
        var response = await _client.geoSearchNextPage(
            event.query, event.lang, _pageNumber, event.bounds, event.center);
        var list = response.list;
        if (list.isEmpty) {
          emit(GeoSearchResult([], true, _pageNumber));
        } else {
          _pageNumber += 1;
          emit(GeoSearchResult(list, false, _pageNumber));
        }
      } catch (error) {
        print(error);
        if (error is CancelException) {
          emit(GeoSearchInitial());
        } else {
          emit(GeoSearchError());
        }
      }
    });
  }

  EventTransformer<Event> debounce<Event>(Duration duration) {
    return (events, mapper) => events.debounce(duration).switchMap(mapper);
  }
}
