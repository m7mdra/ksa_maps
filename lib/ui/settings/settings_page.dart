import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Settings',
              style: TextStyle(fontSize: 20),
            ),
          ),
          ListTile(
            onTap: () {

            },
            leading: const Icon(Icons.language_outlined),
            title: const Text("Language"),
            subtitle: Text(Localizations.localeOf(context).languageCode == "en"
                ? "English"
                : "Arabic"),
          ),
          const Divider(),
          ListTile(
            onTap: () {},
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text("User interface style"),
            subtitle: Text(Theme.of(context).brightness == Brightness.light
                ? "Light mode"
                : "Dark mode"),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
