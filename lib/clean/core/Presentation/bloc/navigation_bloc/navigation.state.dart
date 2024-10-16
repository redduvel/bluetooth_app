import 'package:flutter/material.dart';

abstract class NavigationState {
  final Widget screen;

  NavigationState(this.screen);
}

class InitialState extends NavigationState {
  InitialState(super.screen);
}

class ScreenState extends NavigationState {
  ScreenState(super.screen);
}
