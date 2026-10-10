import 'package:conning_tower/constants.dart';
import 'package:conning_tower/helper.dart';
import 'package:conning_tower/utils/asset_loader.dart';
import 'package:conning_tower/utils/objectbox.dart';
import 'package:conning_tower/utils/path_util.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences localStorage;
final InAppLocalhostServer localhostServer = InAppLocalhostServer(
    port: 8686, documentRoot: 'assets/www', directoryIndex: 'home.html');
late bool safeNavi;
late int selectedIndex;
late DeviceType deviceType;
late ObjectBox objectbox;
late PathUtil pathUtil;

Future<void> init() async {
  localStorage = await SharedPreferences.getInstance();

  deviceType = await getDeviceType();

  await AssetLoader.init();

  safeNavi = false;
  selectedIndex = 0;
}
