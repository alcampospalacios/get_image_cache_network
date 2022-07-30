import 'package:flutter/material.dart';
import 'package:get_image_cache_network/get_image_cache_network.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Get_Image_Cache_Network',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _imageUrl =
      'https://media-exp1.licdn.com/dms/image/C4E16AQG83klydJYNIA/profile-displaybackgroundimage-shrink_200_800/0/1628956177363?e=2147483647&v=beta&t=dPRrOvqQENO-Y_TeUpjvSKfrTqzZI6RsZYOyif_-LN0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image cache network'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Center(
              child: GetImageCacheNetwork(
            imageFromNetworkUrl: _imageUrl,
            imageFromAssetsUrl: 'assets/placeholder.png',
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.width * 0.5,
            errorWidth: MediaQuery.of(context).size.width * 0.8,
            errorHeight: MediaQuery.of(context).size.width * 0.5,
            showLogs: true,
          )),
          TextButton(
              onPressed: () {
                setState(() {
                  _imageUrl =
                      'https://media-exp1.licdn.com/dms/image/C4E16AQG83klydJYNIA/profile-displaybackgroundimage-shrink_200_800/0/1628956177363?e=2147483647&v=beta&t=dPRrOvqQENO-Y_TeUpjvSKfrTqzZI6RsZYOyif_-LN0';
                });
              },
              child: const Text('Get image from cache')),
          TextButton(
              onPressed: () {
                setState(() {
                  _imageUrl = 'Fake Url';
                });
              },
              child: const Text('Get image from assets firing Error'))
        ],
      ),
    );
  }
}
