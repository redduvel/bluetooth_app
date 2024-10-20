import 'dart:async';

import 'package:bluetooth_app/clean/core/Domain/entities/characteristic.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClockWidget extends StatefulWidget {
  final DateTime startDate;
  final Characteristic? characteristic;

  const ClockWidget(
      {super.key, required this.startDate, required this.characteristic});

  @override
  _ClockWidgetState createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  DateTime? _currentTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeTime();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  @override
  void didUpdateWidget(covariant ClockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.characteristic != oldWidget.characteristic) {
      _initializeTime();
    }
  }

  void _initializeTime() {
    _currentTime = widget.startDate;
    if (widget.characteristic != null) {
      //_currentTime = setAdjustmentTime(_currentTime!, widget.characteristic!);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      _currentTime = _currentTime!.add(const Duration(seconds: 1));
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatDateTime(_currentTime!),
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
    );
  }
}
