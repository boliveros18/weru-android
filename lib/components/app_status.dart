import 'package:flutter/material.dart';
import 'package:weru/functions/current_situation.dart';

class AppStatus extends StatefulWidget {
  const AppStatus({Key? key}) : super(key: key);

  @override
  _AppStatusState createState() => _AppStatusState();
}

class _AppStatusState extends State<AppStatus> with WidgetsBindingObserver {
  String appState = "Abrir-App";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notifyStatusChange();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      appState =
          (state == AppLifecycleState.paused) ? "Minimizar-App" : "Abrir-App";
      _notifyStatusChange();
    });
  }

  void _notifyStatusChange() async {
    await currentSituation(appState);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
