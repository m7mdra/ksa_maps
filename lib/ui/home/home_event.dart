part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class NavigationToSearch extends HomeEvent {}

class NavigationToRoute extends HomeEvent {
}

class NavigationToFavorite extends HomeEvent {}

class NavigationToSettings extends HomeEvent {}

class SearchLocationSelected extends HomeEvent {
  final QueryResult result;

  SearchLocationSelected(this.result);
}

class OnBackPress extends HomeEvent {}

class OnStartPointSelect extends HomeEvent {
  final QueryResult result;

  OnStartPointSelect(this.result);
}

class OnEndPointSelect extends HomeEvent {
  final QueryResult result;

  OnEndPointSelect(this.result);

}

class OnStopPointAdd extends HomeEvent {}
