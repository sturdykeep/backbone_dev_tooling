import 'package:perfmon/globals.dart';

class Settings {
  String? get pathToProject {
    return Globals.sharedPreferences.get("pathToProject")?.toString();
  }

  String? get flutterCommand {
    return Globals.sharedPreferences.get("flutterCommand")?.toString();
  }

  int? get wsPort {
    return Globals.sharedPreferences.getInt("wsPort") ?? 8080;
  }

  set wsPort(int? value) {
    Globals.sharedPreferences.setInt("wsPort", value ?? 8080);
  }

  set pathToProject(String? path) {
    Globals.sharedPreferences.setString("pathToProject", path!);
  }

  set flutterCommand(String? path) {
    Globals.sharedPreferences.setString("flutterCommand", path!);
  }
}
