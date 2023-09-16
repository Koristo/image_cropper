import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as image;

import '/style.dart';
import './button.dart';

//****************************************************************************//

class ImageCropper extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return ImageCroperState();
  }

}

//****************************************************************************//

class ImageCroperState extends State<ImageCropper> {

  final _viewWidth  = 200.0;
  final _viewHeight = 300.0;

  int _imgWidth = 0;
  int _imgHeight = 0;

  String _imagePath  = '';
  image.Image? _image;

  double _scale      = 0.0;
  double _initialScale  = 0.0;
  Offset _offset     = Offset.zero;
  Offset _initialOffset = Offset.zero;

  late double _imgScaledWidth;
  late double _imgScaledHeight;
  late double _blurScaledWidth;
  late double _blurScaledHeight;

  double _cropX      = 0;
  double _cropY      = 0;
  double _cropWidth  = 50;
  double _cropHeight = 50;

  late double _leftCropAreaWidth;
  late double _rightCropAreaWidth;
  late double _topCropAreaHeight;
  late double _bottomCropAreaHeight;

  final Color borderColor = StyleColor.black.withAlpha(127);

  //-------------------------------------------------------------------------//

  @override
  void initState() {
    super.initState();
  }

  //-------------------------------------------------------------------------//

  @override
  void dispose() {
    super.dispose();
  }

  //-------------------------------------------------------------------------//

  @override
  Widget build(BuildContext context) {
    _leftCropAreaWidth    = _cropX;
    _rightCropAreaWidth   = _viewWidth - _cropWidth - _cropX;
    _topCropAreaHeight    = _cropY;
    _bottomCropAreaHeight = _viewHeight - _cropHeight - _cropY;

    return Column(
      children: [
        if (_imagePath.isNotEmpty) ... {
          Container(
            width : _viewWidth,
            height: _viewHeight,
            child : Stack(
              children: [
                _buildBlurImage(),
                _buildImage(), // original image
                _buildCrop(),
              ],
            ),
          ),
          SizedBox(height: 10),
        },
        Button(
          height : 40,
          width  : 150,
          bgColor: StyleColor.blue,
          text   : "Load image for crop",
          onClick: _loadImage,
        ),
        if (_imagePath.isNotEmpty) ... {
          SizedBox(height: 10),
          Button(
            height : 40,
            width  : 150,
            bgColor: StyleColor.blue,
            text   : "Save crop image",
            onClick: () => _saveNewImage(_viewWidth, _viewHeight),
          ),
        },
      ],
    );

  }

  //-------------------------------------------------------------------------//

  Widget _buildBlurImage() {
    return ClipRRect(
      child: ImageFiltered( // blured image
        imageFilter: ui.ImageFilter.blur(
          sigmaX: 15,
          sigmaY: 15,
        ),
        child      : Container(
          // width: 185,
          // height: 285,
          child: Image.file(
            File(_imagePath),
            width : _blurScaledWidth,
            height: _blurScaledHeight,
            fit   : BoxFit.cover,
          ),
        ),
      ),
    );
  }

  //-------------------------------------------------------------------------//

  Widget _buildImage() {
    // int imageWidth  = (_image != null) ? _image!.width.toInt()  : 0;
    // int imageHeight = (_image != null) ? _image!.height.toInt() : 0;

    // if ((imageWidth > 0) && (imageHeight > 0)) {
    // double scale  = _clampScale(_viewWidth, _viewHeight, _imgWidth, _imgHeight, _scale);
    // Offset offset = _clampOffset(_viewWidth, _viewHeight, _imgWidth, _imgHeight, _offset, scale);
    _imgScaledWidth  = _imgWidth  * _scale;
    _imgScaledHeight = _imgHeight * _scale;
    //   print("!!!! image moved/scaled: $_imgScaledWidth, $_imgScaledHeight $scale $offset !!!!");

    return Positioned(
      left: (_viewWidth  - _imgScaledWidth)  / 2 + _offset.dx,
      top : (_viewHeight - _imgScaledHeight) / 2 + _offset.dy,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child : InteractiveViewer(
          scaleEnabled       : false,
          onInteractionStart : (ScaleStartDetails details) {
            _initialOffset = _offset - details.focalPoint;
            _initialScale  = _scale;
          },
          onInteractionUpdate: (details) {
            if (details.scale != 1) {
              _scale = _clampScale(_viewWidth, _viewHeight, _imgWidth, _imgHeight, _initialScale * details.scale);
            } else {
              _offset = _clampOffset(_viewWidth, _viewHeight, _imgWidth, _imgHeight, _initialOffset + details.focalPoint, _scale);
            }

            setState(() {});
          },
          child: Image.file(
            File(_imagePath),
            fit   : BoxFit.fill,
            width : _imgScaledWidth,
            height: _imgScaledHeight,
          ),
        ),
      ),
    );
  }

  //-------------------------------------------------------------------------//

  Widget buildImageDot(bool xChanged, bool yChanged, bool widthInv, bool heightInv) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child : GestureDetector(
        onPanUpdate: (details) {
          double newWidth  = widthInv  ? _cropWidth  - details.delta.dx : _cropWidth  + details.delta.dx;
          double newHeight = heightInv ? _cropHeight - details.delta.dy : _cropHeight + details.delta.dy;
          double newX      = xChanged ? _cropX + details.delta.dx : _cropX;
          double newY      = yChanged ? _cropY + details.delta.dy : _cropY;
          bool needUpdate  = false;

          if (newWidth.round() >= 50 && newX >= 0 && newWidth + newX <= _viewWidth) {
            needUpdate = true;
            _cropX     = newX;
            _cropWidth = newWidth;
          }

          if (newHeight.round() >= 50 && newY >= 0 && newHeight + newY <= _viewHeight) {
            needUpdate  = true;
            _cropY      = newY;
            _cropHeight = newHeight;
          }

          if (needUpdate) {
            setState(() {});
          }
        },
        child: Container(
          width     : 12,
          height    : 12,
          decoration: new BoxDecoration(
            color: StyleColor.blue,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  //-------------------------------------------------------------------------//

  Widget _buildCrop() {
    return Container(
      width : _cropWidth,
      height: _cropHeight,
      child : Row(
        children: [
          Column(
            children: [
              buildImageDot(true, true, true, true),
              Spacer(),
              buildImageDot(true, false, true, false),
            ],
          ),
          Spacer(),
          Column(
            children: [
              buildImageDot(false, true, false, true),
              Spacer(),
              buildImageDot(false, false, false, false),
            ],
          ),
        ]
      )
    );
  }

  //-------------------------------------------------------------------------//

  void _loadImage() async {
    ui.Codec? codec;
    ui.Image? img;
    List<String> allowedTypes = ["jpg", "jpeg", "png"];

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

      if (result != null && result.files.isNotEmpty) {
        _imagePath = result.files[0].path!;

        final data = await File(_imagePath).readAsBytes();

        codec = await ui.instantiateImageCodec(data);
        img   = (await codec.getNextFrame()).image;

        _cropX         = 0;
        _cropY         = 0;
        _initialOffset = Offset.zero;
        _offset        = Offset.zero;
        _cropWidth     = _viewWidth  / 2;
        _cropHeight    = _viewHeight / 2;
        _scale         = 0.0;
        _initialScale  = 0.0;

        _image = await image.decodeImage(File(_imagePath).readAsBytesSync());

        _imgWidth  = (_image != null) ? _image!.width  : 0;
        _imgHeight = (_image != null) ? _image!.height : 0;

        assert((_imgWidth > 0.0) && (_imgHeight > 0.0));
        _scale  = _clampScale(_viewWidth, _viewHeight, _imgWidth, _imgHeight, 0.0);
        _offset = _clampOffset(_viewWidth, _viewHeight, _imgWidth, _imgHeight, Offset.zero, _scale);
        _imgScaledWidth  = _blurScaledWidth  = _imgWidth  * _scale;
        _imgScaledHeight = _blurScaledHeight = _imgHeight * _scale;
        print("!!!! image moved/scaled: $_imgScaledWidth, $_imgScaledHeight $_scale $_offset !!!!");

        setState(() {});
      }
    } catch(e) {
      print("Error parse image file for cropping: ${Future.error(e).toString()}");
    }

    img?.dispose();
    codec?.dispose();
  }

  //-------------------------------------------------------------------------//

  Offset _clampOffset(double width, double height, int imageWidth, int imageHeight, Offset offset, double scale) {
    Offset offsetRange = Offset(
      (imageWidth  * scale - width).abs()  / 2 + min(width  / 2, imageWidth  * scale / 2),
      (imageHeight * scale - height).abs() / 2 + min(height / 2, imageHeight * scale / 2),
    );

    return Offset(
      min(max(offset.dx, -offsetRange.dx), offsetRange.dx),
      min(max(offset.dy, -offsetRange.dy), offsetRange.dy),
    );
  }

  //-------------------------------------------------------------------------//

  double _clampScale(double width, double height, int imageWidth, int imageHeight, double scale) {
    double maxScale = 5;

    double fitScale  = min(width / imageWidth, height / imageHeight);
    double fillScale = max(width / imageWidth, height / imageHeight);

    return (scale != 0) ? min(max(scale, fitScale), maxScale) : fillScale;
  }

  //-------------------------------------------------------------------------//

  void _saveNewImage(double width, double height) async {
    int imageWidth  = (_image != null) ? _image!.width.toInt()  : 0;
    int imageHeight = (_image != null) ? _image!.height.toInt() : 0;

    if ((width > 0) && (height > 0) && (imageWidth > 0) && (imageHeight > 0)) {
      double scale  = _clampScale(width, height, imageWidth, imageHeight, _scale);
      Offset offset = _clampOffset(width, height, imageWidth, imageHeight, _offset, scale);

      final path = await FilePicker.platform.getDirectoryPath(
        dialogTitle: "Save new image"
      );

      File? file = await _resizeFile({
        "image" : _image,
        "file"   : File('$path/cropped_image.png'),
        "crop_x" : _cropX.round(),
        "crop_y" : _cropY.round(),
        "crop_w" : _cropWidth.round(),
        "crop_h" : _cropHeight.round(),
        "image_x": ((_viewWidth  - _imgScaledWidth)  / 2 + offset.dx).round(),
        "image_y": ((_viewHeight - _imgScaledHeight) / 2 + offset.dy).round(),
        "image_w": _imgScaledWidth,
        "image_h": _imgScaledHeight,
        "view_w" : _viewWidth.toInt(),
        "view_h" : _viewHeight.toInt(),
      }
      );

      if (mounted && (file != null)) {
        print("Successfully saved new image");
      }
    }
  }

  //-------------------------------------------------------------------------//

  static Future<File?> _resizeFile(Map<String, dynamic> data) async {
    try {
      image.Image? paramImage = data["image"]   as image.Image;
      File paramFile          = data["file"]    as File;
      int cropX               = data["crop_x"]  as int;
      int cropY               = data["crop_y"]  as int;
      int cropW               = data["crop_w"]  as int;
      int cropH               = data["crop_h"]  as int;
      int imageX              = data["image_x"] as int;
      int imageY              = data["image_y"] as int;
      double imageW           = data["image_w"] as double;
      double imageH           = data["image_h"] as double;
      int viewW               = data["view_w"]  as int;
      int viewH               = data["view_h"]  as int;

      int originalWidth       = paramImage.width;
      int originalHeight      = paramImage.height;

      print("!!!! crop:[$cropX, $cropY, $cropW, $cropH], image:[$imageX, $imageY, $imageW, $imageH] !!!!");
      print("!!!! original image:[${originalWidth}, ${originalHeight}] view:[$viewW, $viewH] !!!!");

      image.Image backgroundImage = image.copyCrop(
          image.Image.fromBytes(
            viewW,
            viewH,
            _gaussianBlur(
              image.copyResize(
                paramImage,
                width : viewW,
                height: viewH,
                interpolation: image.Interpolation.nearest, // background is blurred, so using fastest interpolation should be fine
              ).data,
              viewW,
              viewH,
              10,
            ),
          ),
          cropX,
          cropY,
          cropW,
          cropH
      );

      int chosenImageAreaX = cropX - imageX;
      int chosenImageAreaY = cropY - imageY;
      int chosenImageAreaW = cropW;
      int chosenImageAreaH = cropH;

      int dstx = 0;
      int dsty = 0;

      print("!!!! chosen area img args: $chosenImageAreaX, $chosenImageAreaY, $chosenImageAreaW, $chosenImageAreaH !!!!");

      if (chosenImageAreaX > imageW) {
        chosenImageAreaW = 0;
      }
      if (chosenImageAreaX < 0) {
        chosenImageAreaW += chosenImageAreaX;
        dstx             = -chosenImageAreaX;
        chosenImageAreaX = 0;
      }
      if (chosenImageAreaY > imageH) {
        chosenImageAreaH = 0;
      }
      if (chosenImageAreaY < 0) {
        chosenImageAreaH += chosenImageAreaY;
        dsty             = - chosenImageAreaY;
        chosenImageAreaY = 0;
      }

      print("!!!! chosen area img args after check: $chosenImageAreaX, $chosenImageAreaY, $chosenImageAreaW, $chosenImageAreaH !!!!");

      image.Image ?scaledImage;
      if (chosenImageAreaH > 0 && chosenImageAreaW > 0) {
        scaledImage = image.copyCrop(
          image.copyResize(
            paramImage,
            width        : imageW.round(),
            height       : imageH.round(),
            interpolation: image.Interpolation.linear
          ),
          chosenImageAreaX,
          chosenImageAreaY,
          chosenImageAreaW,
          chosenImageAreaH,
        );
      }

      print("!!!! final sizes back[${backgroundImage.width}, ${backgroundImage.height}], scaled[${scaledImage?.width}, ${scaledImage?.height}] !!!!");

      image.Image finalImage = backgroundImage;

      if (scaledImage != null) {
        finalImage = image.drawImage(
          backgroundImage,
          scaledImage,
          dstX: dstx,
          dstY: dsty,
          dstW: scaledImage.width,
          dstH: scaledImage.height,
          srcX: 0,
          srcY: 0,
          srcW: scaledImage.width,
          srcH: scaledImage.height,
        );
      }

      return await paramFile.writeAsBytes(
        image.encodePng(finalImage),
        flush: true,
      );
    } catch (e) {
      print("Failed to process image: $e");
    }

    return null;
  }
}

//-------------------------------------------------------------------------//

Uint32List _gaussianBlur(Uint32List rgbaPixels, int width, int height, int radius) {
  final int size = width * height;
  final Uint8List alpha = Uint8List(size);
  final Uint8List red = Uint8List(size);
  final Uint8List green = Uint8List(size);
  final Uint8List blue = Uint8List(size);

  for (int i = 0; i < size; i++) {
    alpha[i] = (rgbaPixels[i] & 0xff000000) >> 24;
    red[i] = (rgbaPixels[i] & 0xff0000) >> 16;
    green[i] = (rgbaPixels[i] & 0x00ff00) >> 8;
    blue[i] = (rgbaPixels[i] & 0x0000ff);
  }

  final Uint8List newAlpha = Uint8List(size);
  final Uint8List newRed = Uint8List(size);
  final Uint8List newGreen = Uint8List(size);
  final Uint8List newBlue = Uint8List(size);

  _gaussBlur4(alpha, newAlpha, width, height, radius);
  _gaussBlur4(red, newRed, width, height, radius);
  _gaussBlur4(green, newGreen, width, height, radius);
  _gaussBlur4(blue, newBlue, width, height, radius);

  for (int i = 0; i < size; i++) {
    rgbaPixels[i] = (newAlpha[i] << 24) | (newRed[i] << 16) | (newGreen[i] << 8) | newBlue[i];
  }

  return rgbaPixels;
}

//-------------------------------------------------------------------------//

void _gaussBlur4(Uint8List source, Uint8List dest, int width, int height, int r) {
  final List<int> bxs = _boxesForGauss(r, 3);
  _boxBlur4(source, dest, width, height, (bxs[0] - 1) >> 1);
  _boxBlur4(dest, source, width, height, (bxs[1] - 1) >> 1);
  _boxBlur4(source, dest, width, height, (bxs[2] - 1) >> 1);
}

//-------------------------------------------------------------------------//

List<int> _boxesForGauss(int sigma, int n) {
  final double wIdeal = sqrt((12 * sigma * sigma / n) + 1);
  int wl = wIdeal.floor();
  if (wl % 2 == 0) wl--;
  final int wu = wl + 2;

  final int m = (12 * sigma * sigma - n * wl * wl - 4 * n * wl - 3 * n) ~/ (-4 * wl - 4);

  final Uint8List sizes = Uint8List(n);
  sizes.fillRange(0, m, wl);
  sizes.fillRange(m, n, wu);
  return sizes;
}

//-------------------------------------------------------------------------//

void _boxBlur4(Uint8List source, Uint8List dest, int w, int h, int r) {
  for (int i = 0; i < source.length; i++) {
    dest[i] = source[i];
  }
  _boxBlurH4(dest, source, w, h, r);
  _boxBlurT4(source, dest, w, h, r);
}

//-------------------------------------------------------------------------//

void _boxBlurH4(Uint8List source, Uint8List dest, int w, int h, int r) {
  final double iar = 1 / (r + r + 1);
  final double rDouble = r.toDouble();
  for (int i = 0; i < h; i++) {
    int ti = i * w;
    int li = ti;
    int ri = ti + r;
    final int fv = source[ti];
    final int lv = source[ti + w - 1];
    double val = (rDouble + 1) * fv;
    for (int j = 0; j < r; j++) {
      val += source[ti + j];
    }
    for (int j = 0; j <= r; j++) {
      val += source[ri++] - fv;
      dest[ti++] = (val * iar).round();
    }
    for (int j = r + 1; j < w - r; j++) {
      val += source[ri++] - source[li++];
      dest[ti++] = (val * iar).round();
    }
    for (int j = w - r; j < w; j++) {
      val += lv - source[li++];
      dest[ti++] = (val * iar).round();
    }
  }
}

//-------------------------------------------------------------------------//

void _boxBlurT4(Uint8List source, Uint8List dest, int w, int h, int r) {
  final double iar = 1 / (r + r + 1);
  final double rDouble = r.toDouble();
  for (int i = 0; i < w; i++) {
    int ti = i;
    int li = ti;
    int ri = ti + r * w;
    final int fv = source[ti];
    final int lv = source[ti + w * (h - 1)];
    double val = (rDouble + 1) * fv;
    for (int j = 0; j < r; j++) {
      val += source[ti + j * w];
    }
    for (int j = 0; j <= r; j++) {
      val += source[ri] - fv;
      dest[ti] = (val * iar).round();
      ri += w;
      ti += w;
    }
    for (int j = r + 1; j < h - r; j++) {
      val += source[ri] - source[li];
      dest[ti] = (val * iar).round();
      li += w;
      ri += w;
      ti += w;
    }
    for (int j = h - r; j < h; j++) {
      val += lv - source[li];
      dest[ti] = (val * iar).round();
      li += w;
      ti += w;
    }
  }
}
