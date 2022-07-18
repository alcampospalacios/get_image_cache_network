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
      title: 'Flutter Demo',
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: GetImageCacheNetwork(
            imageFromNetworkUrl: _imageUrl,
            imageFromAssetsUrl: 'assets/placeholder.png',
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.width * 0.5,
          )),
          const SizedBox(
            height: 25,
          ),
          Column(
            children: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      _imageUrl =
                          'https://media-exp1.licdn.com/dms/image/C4E16AQG83klydJYNIA/profile-displaybackgroundimage-shrink_200_800/0/1628956177363?e=2147483647&v=beta&t=dPRrOvqQENO-Y_TeUpjvSKfrTqzZI6RsZYOyif_-LN0';
                    });
                  },
                  child: const Text('Get image from cache')),
              const SizedBox(
                height: 10,
              ),
              TextButton(
                  onPressed: () {
                    setState(() {
                      _imageUrl = 'Fake Url';
                    });
                  },
                  child: const Text('Get image from assets firing Error')),
            ],
          )
        ],
      ),
    );
  }
}
