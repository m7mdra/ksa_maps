import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ksa_maps/data/data.dart';
import 'package:ksa_maps/di/dependency_provider.dart';
import 'package:ksa_maps/ui/search/bloc/geo_search_bloc.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

class SearchPage extends StatefulWidget {
  final List<double> center;
  final List<double> bounds;

  const SearchPage({Key? key, required this.center, required this.bounds})
      : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late GeoSearchBloc _bloc;
  final _pageController = PagingController<int, QueryResult>(firstPageKey: 1);
  final _textEditingController = TextEditingController();
  final _results = <QueryResult>[];
  var _isLoading = false;
  var _isLastPage = false;

  @override
  void initState() {
    super.initState();
    _bloc = GeoSearchBloc(D.provide());

    _pageController.addPageRequestListener((pageKey) {
      _bloc.add(LoadNextSearchPage(
          query: _textEditingController.text,
          lang: Localizations.localeOf(context).languageCode,
          bounds: widget.bounds,
          center: widget.center));
    });
    _bloc.stream.listen(_onNewState);
  }


  void _onNewState(state) {
    if (state is GeoSearchError) {
      setState(() {
        _isLoading = false;
      });
    }

    if (state is GeoSearchClearState) {
      setState(() {
        _isLoading = false;
        _results.clear();
      });
    }
    if (state is GeoSearchEmpty) {}
    if (state is GeoSearchLoading) {
      setState(() {
        _isLoading = true;
      });
    }
    if (state is GeoSearchResult) {
      if (state.lastPage) {
        _results.addAll(state.list);
        setState(() {
          _isLastPage = true;
          _isLoading = false;
        });
      } else {
        _results.addAll(state.list);
        setState(() {
          _isLastPage = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _bloc.close();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _buildResultListView(),
            _buildSearchCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildResultListView() {
    return BlocBuilder(
      bloc: _bloc,
      builder: (BuildContext context, state) {
        if (state is GeoSearchLoading) {
          return _loadingProgress();
        }
        if (state is GeoSearchEmpty) {
          return const Center(
              child: Text("No Result found matching the keywork"));
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 70),
          itemBuilder: (context, index) {
            if (index == _results.length) {
              if (_isLastPage) {
                return Container();
              } else {
                if (_isLoading) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _loadingProgress(),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: OutlinedButton(
                      onPressed: () {
                        _bloc.add(LoadNextSearchPage(
                            query: _textEditingController.text,
                            lang: Localizations.localeOf(context).languageCode,
                            bounds: widget.bounds,
                            center: widget.center));

                        setState(() {
                          _isLoading = true;
                        });
                      },
                      child: const Text("Load more"),
                    ),
                  );
                }
              }
            } else {
              var item = _results[index];

              return ListTile(
                onTap: () {
                  Navigator.pop(context, item);
                },
                title: Text(item.name ?? ""),
                subtitle: Text(item.fullAddress ?? ""),
                leading: _buildLeadingIconForId(item.type),
              );
            }
          },
          itemCount: _results.isEmpty ? 0 : _results.length + 1,
        );
      },
    );
  }

  Center _loadingProgress() => const Center(child: CircularProgressIndicator());

  Card _buildSearchCard(BuildContext context) {
    return Card(
        margin: const EdgeInsets.all(8),
        child: Row(children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back))),
          Expanded(
            child: TextField(
              controller: _textEditingController,
              onChanged: (text) {
                _bloc.add(SubmitSearchKey(
                    query: text,
                    lang: Localizations.localeOf(context).languageCode,
                    bounds: widget.bounds,
                    center: widget.center));
              },
              decoration: const InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.all(12)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _results.clear();
                _textEditingController.clear();
              });
            },
          )
        ]));
  }


  Widget _buildLeadingIconForId(int type) {
    switch (type) {
      case 1:
        return const Icon(Icons.location_city_outlined);
      case 2:
        return const Icon(Icons.directions_outlined);
      default:
        return const Icon(Icons.place_outlined);
    }
  }
}
