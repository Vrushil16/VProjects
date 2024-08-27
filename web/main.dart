import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:v_projects/main.dart' as app;

main() async {
  // await webOnlyInitializePlatform();
  setUrlStrategy(PathUrlStrategy());
  app.main();
}
