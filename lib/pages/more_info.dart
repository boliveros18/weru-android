import 'package:weru/components/app_bar_ui.dart';
import 'package:flutter/material.dart';
import 'package:weru/components/app_status.dart';

class MoreInfoPage extends StatefulWidget {
  const MoreInfoPage({super.key});

  @override
  State<MoreInfoPage> createState() => _MoreInfoState();
}

class _MoreInfoState extends State<MoreInfoPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarUi(
        header: "Informacion adicional",
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppStatus(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
