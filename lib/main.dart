import 'dart:io';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_cropping/image_cropping.dart';
import 'package:national_avatar/avatar.dart';

import 'generated/assets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '国庆头像生成',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CarouselController _controller = CarouselController();
  final List<String> _cover = [];
  int _selectedIndex = 0;
  final double _size = 150;
  final GlobalKey _avatarKey = GlobalKey();
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _cover.add(Assets.gradual1);
    _cover.add(Assets.gradual2);
    _cover.add(Assets.gradual3);
    _cover.add(Assets.gradual4);
    _cover.add(Assets.gradual5);
    _cover.add(Assets.gradual6);
    _cover.add(Assets.newNA);
    _cover.add(Assets.newNB);
    _cover.add(Assets.newNE);
    _cover.add(Assets.newNG);
    _cover.add(Assets.newNH);
    _cover.add(Assets.newNJ);
    _cover.add(Assets.newNK);
    _cover.add(Assets.other2);
    _cover.add(Assets.simple2);
    _cover.add(Assets.simple3);
    _cover.add(Assets.simple4);
    _cover.add(Assets.simple5);
    _cover.add(Assets.simple6);
    _cover.add(Assets.simple7);
    _cover.add(Assets.simple8);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      alignment: Alignment.center,
      children: [
        //在背景后，生成400x400的头像，用于输出到图片文件
        Avatar(
          key: _avatarKey,
          size: 400,
          cover: _cover[_selectedIndex],
          imageBytes: _imageBytes,
        ),
        Image.asset(
          Assets.imagesBackground,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (_imageBytes != null)
                  Image.memory(
                    _imageBytes!,
                    width: _size,
                    height: _size,
                    fit: BoxFit.fill,
                  ),
                if (_imageBytes == null)
                  Image.asset(
                    Assets.imagesAdd,
                    width: _size,
                    height: _size,
                  ),
                _buildCarouselSlider(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: GestureDetector(
                  onTap: () async {
                    var avatarState = _avatarKey.currentWidget as Avatar;
                    var bytes = await avatarState.captureBitmap(context);

                    String? outputFile = await FilePicker.platform.saveFile(
                      dialogTitle: '保存图片',
                      fileName: 'avatar.jpg',
                    );
                    if (outputFile == null) {
                    } else {
                      var file = File(outputFile);
                      if (bytes != null) {
                        file.writeAsBytes(bytes);
                      }
                    }
                  },
                  child: Image.asset(Assets.imagesBtnSave, width: 200)),
            ),
          ],
        )
      ],
    ));
  }

  _pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      Uint8List bytes;
      if (kIsWeb) {
        bytes = result.files.first.bytes!;
      } else {
        File file = File(result.files.first.path!);
        bytes = await file.readAsBytes();
      }
      final croppedBytes = await ImageCropping.cropImage(
        context: context,
        imageBytes: bytes,
        onImageStartLoading: () {},
        onImageEndLoading: () {},
        onImageDoneListener: (data) {
          setState(() {
            _imageBytes = data;
          });
        },
        selectedImageRatio: CropAspectRatio.fromRation(ImageRatio.RATIO_1_1),
        visibleOtherAspectRatios: true,
        squareBorderWidth: 2,
        encodingQuality: 80,
        outputImageFormat: OutputImageFormat.jpg,
        workerPath: 'crop_worker.js',
      );
    }
  }

  CarouselSlider _buildCarouselSlider() {
    return CarouselSlider.builder(
        carouselController: _controller,
        options: CarouselOptions(
            height: _size,
            aspectRatio: 1,
            viewportFraction: 0.5,
            onPageChanged: (int itemIndex, CarouselPageChangedReason reason) {
              setState(() {
                _selectedIndex = itemIndex;
              });
            }),
        itemCount: 15,
        itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
          return GestureDetector(
            onTapDown: (detail) {
              if (itemIndex == _selectedIndex) {
                //如果选中的是中间的图片，执行图片选择
                _pickFile();
              } else {
                var dx = detail.globalPosition.dx;
                if (dx < _size * 2) {
                  // 如果触摸位置在左边，定位到上一页
                  _controller.previousPage();
                } else {
                  _controller.nextPage();
                }
                setState(() {
                  _selectedIndex = itemIndex;
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child:
                  Image.asset(_cover[itemIndex], width: _size, height: _size),
            ),
          );
        });
  }
}
