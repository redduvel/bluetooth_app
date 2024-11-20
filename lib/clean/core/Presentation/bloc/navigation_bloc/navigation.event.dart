import 'package:flutter/material.dart';

abstract class NavigationEvent<T> {
  final Widget screen;

  NavigationEvent(this.screen);
}

class NavigateTo extends NavigationEvent {
  NavigateTo(super.screen);
}

class Started extends NavigationEvent {
  Started(super.screen);
}
