import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/style.dart';
import 'package:provider/provider.dart';
import 'widgets/image_cropper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child : MaterialApp(
        title: 'Image cropper',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme : ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home : const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image cropper",
          style: StyleText.header,
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment : MainAxisAlignment.center,
          children          : [
            ImageCropper(),
          ],
        ),
      ),
    );
  }
}