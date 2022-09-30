import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


class Avatar extends StatelessWidget {
  final Uint8List? imageBytes;
  final String cover;
  final double size;
  final GlobalKey _key = GlobalKey();

  Avatar(
      {Key? key,
      required this.imageBytes,
      required this.size,
      required this.cover})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _key,
      child: Stack(
        children: [
          if (imageBytes != null)
            Image.memory(
              imageBytes!,
              width: size,
              height: size,
              fit: BoxFit.fill,
            ),
          Image.asset(
            cover,
            width: size,
            height: size,
          )
        ],
      ),
    );
  }

  Future<Uint8List?> captureBitmap(BuildContext context) async {
    try {
      RenderRepaintBoundary? boundary =
          _key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      var image = await boundary?.toImage(
          pixelRatio: MediaQuery.of(context).devicePixelRatio);
      ByteData? byteData = await image?.toByteData(format: ImageByteFormat.png);
      Uint8List? pageBytes = byteData?.buffer.asUint8List(); //图片data
      return pageBytes;
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("图片生成失败")));
    }

    return null;
  }
}
