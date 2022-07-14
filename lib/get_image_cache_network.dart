library get_image_cache_network;

import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart' as dartz;
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/material.dart';

import 'src/util/app_path_provider.dart';

class Failure {
  const Failure();
}

class DioInterceptor extends Interceptor {
  DioInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Showing logs of every request in console
    log("--> ${options.method != '' ? options.method.toUpperCase() : 'METHOD'} ${"${options.baseUrl}${options.path}"}");

    log("Headers:");
    options.headers.forEach((k, v) => log('$k: $v'));

    log("queryParameters:");
    options.queryParameters.forEach((k, v) => log('$k: $v'));

    if (options.data != null) log("Body: ${options.data}");

    log("--> END ${options.method != '' ? options.method.toUpperCase() : 'METHOD'}");

    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log("--> START RESPONSE}");
    log(response.statusCode != null ? response.statusCode.toString() : 'STATUS CODE');

    log("Headers:");
    response.headers.forEach((k, v) => log('$k: $v'));

    log("Data");
    response.data.forEach((k, v) => log('$k: $v'));

    log("--> END ");

    return super.onResponse(response, handler);
  }
}

/// This class is used to get the image from the network or from the cache.
/// This [GetImageCacheNetwork] return a [Widget] that can be a image or a placeholder.
/// If there is no image in the cache, it will get the image from the network and save it in the cache.
/// If there is an image in the cache, it will get the image from the cache.
/// If there is an error, it will return a placeholder.
/// You can provide a [width] and [height] to get a image with the correct size by default would be 64px.
/// You can provide a cacheDuration by default would be 15 days.
class GetImageCacheNetwork extends StatefulWidget {
  final String imageFromNetworkUrl;
  final String imageFromAssetsUrl;
  final double? width;
  final double? height;
  final Widget? loading;
  final int? cacheDuration;
  const GetImageCacheNetwork(
      {Key? key,
      required this.imageFromNetworkUrl,
      required this.imageFromAssetsUrl,
      this.width,
      this.height,
      this.loading,
      this.cacheDuration})
      : super(key: key);

  @override
  State<GetImageCacheNetwork> createState() => _GetImageCacheNetworkState();
}

class _GetImageCacheNetworkState extends State<GetImageCacheNetwork> {
  final Dio _dio = Dio();

  ImageProvider? _imageProvider;

  /* Get image from network */
  Future<dartz.Either<Failure, ImageProvider>> getImageFromNetwork() async {
    // Creating interceptor to cache the image
    final DioCacheInterceptor dioCacheInterceptor = DioCacheInterceptor(
      options: CacheOptions(
        store: HiveCacheStore(AppPathProvider.path),
        policy: CachePolicy.refreshForceCache,
        hitCacheOnErrorExcept: [],
        maxStale: Duration(
          days: widget.cacheDuration ?? 15,
        ), //increase number of days for loger cache
        priority: CachePriority.high,
      ),
    );
    // Creating interceptor to log the request and response
    final DioInterceptor dioInterceptor = DioInterceptor();

    //this is for avoiding certificates error cause by dio
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };

    // Adding intercetors to handle cache and show logs
    _dio.interceptors.add(dioCacheInterceptor);
    _dio.interceptors.add(dioInterceptor);

    // doing request to get image
    try {
      final response = await _dio.get(widget.imageFromNetworkUrl);
      _imageProvider = MemoryImage(response.data);

      // Return imageProvider
      return dartz.Right(_imageProvider!);
    } catch (e) {
      // Return error
      return const dartz.Left(Failure());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: FutureBuilder(
          future: getImageFromNetwork(),
          initialData: null,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return snapshot.data != null
                ? (snapshot.data as dartz.Either<Failure, ImageProvider>).fold(
                    (failure) => Image.asset(
                      widget.imageFromAssetsUrl,
                      fit: BoxFit.cover,
                      width: widget.width ?? 64,
                      height: widget.height ?? 64,
                    ),
                    (imageProvider) => Image(
                      image: imageProvider,
                      width: widget.width ?? 64,
                      height: widget.height ?? 64,
                    ),
                  )
                : SizedBox(
                    height: 64,
                    width: 64,
                    child: Center(child: widget.loading ?? const CircularProgressIndicator(color: Color(0xff0abb87))));
          },
        ),
      ),
    );
  }
}
