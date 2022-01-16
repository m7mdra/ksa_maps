import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ksa_maps/data/map_data_client.dart';
import 'package:ksa_maps/data/model/query_result.dart';
import 'package:ksa_maps/ui/search/bloc/geo_search_bloc.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

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
  final textEditingController = TextEditingController();
  bool searchBarEmpty = true;

  @override
  void initState() {
    super.initState();
    var dio = Dio(BaseOptions(baseUrl: "https://ksamaps.com/api/"));
    dio.interceptors.add(PrettyDioLogger());
    _bloc = GeoSearchBloc(MapDataClient(dio));

    _pageController.addPageRequestListener((pageKey) {
      _bloc.add(LoadNextSearchPage(
          query: textEditingController.text,
          lang: Localizations.localeOf(context).languageCode,
          bounds: widget.bounds,
          center: widget.center));
    });
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
        child: BlocListener(
          listener: (context, state) {
            if (state is GeoSearchError) {
              _pageController.error = "Failed to load data, try again";
            }
            if (state is GeoSearchResult) {
              if (state.lastPage) {
                _pageController.appendLastPage(state.list);
              } else {
                _pageController.appendPage(state.list, state.pageNumber);
              }
            }
          },
          bloc: _bloc,
          child: Column(
            children: [
              Card(
                  margin: const EdgeInsets.all(8),
                  child: Row(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: searchBarEmpty
                          ? const BackButton(color: Colors.grey)
                          : const Icon(Icons.search, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: textEditingController,
                        onChanged: (text) {
                          if (text.length <= 3) return;
                          _pageController.refresh();
                          setState(() {
                            searchBarEmpty = text.isEmpty;
                          });

                          if (text.isNotEmpty) {
                            _bloc.add(SubmitSearchKey(
                                query: text,
                                lang: Localizations.localeOf(context)
                                    .languageCode,
                                bounds: widget.bounds,
                                center: widget.center));
                          }
                        },
                        decoration: const InputDecoration(
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            contentPadding: EdgeInsets.all(12)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {

                        setState(() {
                          searchBarEmpty = true;
                        });
                        textEditingController.clear();
                        _pageController.refresh();
                      },
                    )
                  ])),
              Expanded(
                  child: searchBarEmpty
                      ? Container()
                      : PagedListView<int, QueryResult>(
                          pagingController: _pageController,
                          builderDelegate: PagedChildBuilderDelegate(
                              itemBuilder: (context, item, index) {
                            return ListTile(
                              onTap: () {
                                Navigator.pop(context, item);
                              },
                              title: Text(item.name ?? ""),
                              subtitle: Text(item.fullAddress ?? ""),
                              leading: const Icon(Icons.location_on_outlined),
                            );
                          }),
                        ))
            ],
          ),
        ),
      ),
    );
  }
}
