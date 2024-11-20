import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.bloc.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.event.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.state.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/features/printing/Presentation/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationPage extends StatefulWidget {
  final List<List<PrimaryButtonIcon>> controls;

  const NavigationPage({super.key, required this.controls});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  late NavigationBloc bloc;
  Widget? currentPage;

  @override
  void initState() {
    bloc = context.read<NavigationBloc>();
    currentPage = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(currentPage);
    return BlocListener<NavigationBloc, NavigationState>(
      bloc: bloc,
      listener: (context, state) {
        return switch (state) {
          ScreenState() => setState(() {
              currentPage = state.screen;
            }),
          InitialState() => setState(() => currentPage = const DashboardPage()),
          _ => null,
        };
      },
      child: Container(
        color: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: widget.controls.map((c) {
              return Column(
                children: c.map((w) {
                  if (w.toPage != null) {
                    return PrimaryButtonIcon(
                      toPage: w.toPage,
                      text: w.text,
                      icon: w.icon,
                      width: double.infinity,
                      onPressed: () {
                        bloc.add(NavigateTo(w.toPage!));
                      },
                      selected: currentPage.runtimeType == w.toPage.runtimeType,
                    );
                  } else {
                    return w;
                  }
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
