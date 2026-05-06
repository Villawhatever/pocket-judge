import 'package:flutter/services.dart';

late String? assetPath;

Future<String> getIsarDbAsset() async {
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  final assets = manifest.listAssets();
  assetPath = assets.where((key) => key.endsWith('.isar')).first;
  return assetPath!;
}

Future<String> getIsarDbName() async {
  assetPath ??= await getIsarDbAsset();
  return assetPath!.split('/').last.split('.')[0];
}
