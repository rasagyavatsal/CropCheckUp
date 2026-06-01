import 'package:flutter/material.dart';


class AppLoadingState extends StatelessWidget {
  final String? message;

  const AppLoadingState({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        liveRegion: true,
        child: CircularProgressIndicator(
          semanticsLabel: message ?? 'Loading',
        ),
      ),
    );
  }
}
