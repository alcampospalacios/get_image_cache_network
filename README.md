<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->
## Get Image Cache Network
This package provides a configurable widget to display an image from the network or from the cache, it also provides an error widget in case of failures.

## Features
![get_image_cache_network](https://user-images.githubusercontent.com/54634181/179444759-11f2f480-11e7-4ece-9727-32bb6463d934.gif)


## Usage

```dart
 GetImageCacheNetwork(
            imageFromNetworkUrl: _imageUrl, // Image from the network
            imageFromAssetsUrl: 'assets/placeholder.png', // Image for your placeholder image
            width: MediaQuery.of(context).size.width * 0.8, // Optional width by default 64
            height: MediaQuery.of(context).size.width * 0.5, // Optional height by default 64
            cacheDuration: 10 // Optional duration of the file in cache 15 days by default
            loading: const CircularProgressIndicator(color: Colors.blue), // Optional widget to do loading by default progress indicator with green color
          )
```

## Additional information
This package use dio to manage request and use hive to storage cache. 
