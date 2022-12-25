import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as p;
import 'package:http/http.dart';
import 'package:cli_dialog/cli_dialog.dart';

import 'i18n.dart';

main(List<String> args) async {
  print(I18n.fetchingVersionInfoFromRemote());

  final tags = json.decode((await get(
          Uri.parse('https://api.github.com/repos/mpflutter/mpflutter/tags')))
      .body) as List;
  final masterBranch = json.decode((await get(Uri.parse(
          'https://api.github.com/repos/mpflutter/mpflutter/branches/master')))
      .body) as Map;
  final versions = <String>[];
  versions.addAll(tags.sublist(0, min(10, tags.length)).map((e) => e['name']));
  versions.add((masterBranch['commit']['sha'] as String).substring(0, 7));
  final versionDialog = CLI_Dialog(listQuestions: [
    [
      {
        'question': I18n.selectVersionCode(),
        'options': [...versions, '0.0.1-master', 'Cancel']
      },
      'versionCode'
    ]
  ]);
  final versionCode = versionDialog.ask()['versionCode'];
  if (versionCode == null || versionCode == 'Cancel' || versionCode == '/') {
    return;
  } else {
    final pubspecFile = File(p.join('pubspec.yaml'));
    if (pubspecFile.existsSync()) {
      var pubspecContent = File(p.join('pubspec.yaml')).readAsStringSync();
      pubspecContent = pubspecContent.replaceAllMapped(
          RegExp(r'(mpflutter/mpflutter\n.*?\n.*?ref: ).*'), (match) {
        return '${match.group(1)}${versionCode}';
      });
      pubspecContent =
          pubspecContent.replaceAllMapped(RegExp(r'flutter:.+'), (match) {
        return 'flutter: "${versionCode}"';
      });
      pubspecContent = pubspecContent
          .replaceAllMapped(RegExp(r'flutter_web_plugins:.+'), (match) {
        return 'flutter_web_plugins: "${versionCode}"';
      });
      pubspecContent =
          pubspecContent.replaceAllMapped(RegExp(r'mpcore:.+'), (match) {
        return 'mpcore: "${versionCode}"';
      });
      pubspecContent = pubspecContent
          .replaceAllMapped(RegExp(r'mp_build_tools:.+'), (match) {
        return 'mp_build_tools: "${versionCode}"';
      });
      File(p.join('pubspec.yaml')).writeAsStringSync(pubspecContent);
      print(I18n.successfulUpgrade('pubspec'));
    }
    final webFile = File(p.join('web', 'index.html'));
    if (webFile.existsSync()) {
      var webIndexHtml = File(p.join('web', 'index.html')).readAsStringSync();
      webIndexHtml = webIndexHtml.replaceAll(
        RegExp(r'mpflutter\.com/dist/.*?/'),
        'mpflutter\.com/dist/${versionCode}/',
      );
      File(p.join('web', 'index.html')).writeAsStringSync(webIndexHtml);
      print(I18n.successfulUpgrade('web'));
    }
    final weappFile = File(p.join('weapp', 'app.js'));
    if (weappFile.existsSync()) {
      final fileList = [
        'mpdom.min.js',
        'kbone/miniprogram-element/index-vhost.js',
        'kbone/miniprogram-element/index.wxml',
        'kbone/miniprogram-element/template/subtree.wxml',
        'kbone/miniprogram-element/template/inner-component.wxml',
        'kbone/miniprogram-element/template/subtree-cover.wxml',
        'kbone/miniprogram-element/index.js',
        'kbone/miniprogram-element/index.wxss',
        'kbone/miniprogram-element/index-vhost.json',
        'kbone/miniprogram-element/base.js',
        'kbone/miniprogram-element/custom-component/index.wxml',
        'kbone/miniprogram-element/custom-component/index.js',
        'kbone/miniprogram-element/custom-component/index.wxss',
        'kbone/miniprogram-element/custom-component/index.json',
        'kbone/miniprogram-element/index-vhost.wxss',
        'kbone/miniprogram-element/base.js.map',
        'kbone/miniprogram-element/index.json',
        'kbone/miniprogram-element/index-vhost.wxml',
        'kbone/miniprogram-render/index.js',
        'kbone/miniprogram-render/index.js.map'
      ];
      for (var item in fileList) {
        final response = await get(
          Uri.parse('https://dist.mpflutter.com/dist/$versionCode/dist_weapp/' +
              item),
        );
        File(p.join('weapp', item)).writeAsStringSync(response.body);
        print(I18n.successfulUpgrade('微信小程序' + item));
      }
    }
    final swanappFile = File(p.join('swanapp', 'app.js'));
    if (swanappFile.existsSync()) {
      final fileList = [
        'mpdom.min.js',
        'kbone/miniprogram-element/index-vhost.js',
        'kbone/miniprogram-element/index.swan',
        'kbone/miniprogram-element/template/subtree.swan',
        'kbone/miniprogram-element/template/inner-component.swan',
        'kbone/miniprogram-element/template/subtree-cover.swan',
        'kbone/miniprogram-element/index.js',
        'kbone/miniprogram-element/index.css',
        'kbone/miniprogram-element/index-vhost.json',
        'kbone/miniprogram-element/base.js',
        'kbone/miniprogram-element/custom-component/index.swan',
        'kbone/miniprogram-element/custom-component/index.js',
        'kbone/miniprogram-element/custom-component/index.css',
        'kbone/miniprogram-element/custom-component/index.json',
        'kbone/miniprogram-element/index-vhost.css',
        'kbone/miniprogram-element/base.js.map',
        'kbone/miniprogram-element/index.json',
        'kbone/miniprogram-element/index-vhost.swan',
        'kbone/miniprogram-render/index.js',
        'kbone/miniprogram-render/index.js.map'
      ];
      for (var item in fileList) {
        final response = await get(
          Uri.parse(
              'https://dist.mpflutter.com/dist/$versionCode/dist_swan/' + item),
        );
        File(p.join('swanapp', item)).writeAsStringSync(response.body);
        print(I18n.successfulUpgrade('百度小程序' + item));
      }
    }
    final ttFile = File(p.join('tt', 'app.js'));
    if (ttFile.existsSync()) {
      final fileList = [
        'mpdom.min.js',
        'kbone/miniprogram-element/index-vhost.js',
        'kbone/miniprogram-element/index.ttml',
        'kbone/miniprogram-element/template/subtree.ttml',
        'kbone/miniprogram-element/template/inner-component.ttml',
        'kbone/miniprogram-element/template/subtree-cover.ttml',
        'kbone/miniprogram-element/index.js',
        'kbone/miniprogram-element/index.ttss',
        'kbone/miniprogram-element/index-vhost.json',
        'kbone/miniprogram-element/base.js',
        'kbone/miniprogram-element/custom-component/index.ttml',
        'kbone/miniprogram-element/custom-component/index.js',
        'kbone/miniprogram-element/custom-component/index.ttss',
        'kbone/miniprogram-element/custom-component/index.json',
        'kbone/miniprogram-element/index-vhost.ttss',
        'kbone/miniprogram-element/base.js.map',
        'kbone/miniprogram-element/index.json',
        'kbone/miniprogram-element/index-vhost.ttml',
        'kbone/miniprogram-render/index.js',
        'kbone/miniprogram-render/index.js.map'
      ];
      for (var item in fileList) {
        final response = await get(
          Uri.parse(
              'https://dist.mpflutter.com/dist/$versionCode/dist_tt/' + item),
        );
        File(p.join('tt', item)).writeAsStringSync(response.body);
        print(I18n.successfulUpgrade('字节小程序' + item));
      }
    }
  }
}
