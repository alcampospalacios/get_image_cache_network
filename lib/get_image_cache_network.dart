library get_image_cache_network;

import 'dart:developer';
import 'dart:typed_data';

import 'package:dartz/dartz.dart' as dartz;
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
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
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
    log(response.statusCode != null
        ? response.statusCode.toString()
        : 'STATUS CODE');

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
  final double? errorWidth;
  final double? errorHeight;
  final BoxFit? fit;
  final BoxFit? errorFit;
  final double? scale;
  final double? errorScale;
  final Widget? loading;
  final int? cacheDuration;
  final bool showLogs;

  /// This class is used to get the image from the network or from the cache.
  /// This [GetImageCacheNetwork] return a [Widget] that can be a image or a placeholder.
  /// If there is no image in the cache, it will get the image from the network and save it in the cache.
  /// If there is an image in the cache, it will get the image from the cache.
  /// If there is an error, it will return a placeholder.
  /// You can provide a [width], [height], [fit], [scale] to get a image with the correct size by default would be [64px],
  ///  [BoxFit.cover], [1].
  /// You can provide a [errorWidth], [errorHeight], [errorFit], [errorScale] to get a image with the correct size by default would be [64px],
  /// [BoxFit.cover], [1].
  /// You can provide a cacheDuration by default would be 15 days.
  /// You can decide if you want to see the logs of request management [showLogs].
  /// If there is not any errorSetting this take from the image setting or in case there is not exist from [defaults]
  const GetImageCacheNetwork({
    Key? key,
    required this.imageFromNetworkUrl,
    required this.imageFromAssetsUrl,
    this.width,
    this.height,
    this.fit,
    this.scale,
    this.errorWidth,
    this.errorHeight,
    this.errorFit,
    this.errorScale,
    this.loading,
    this.cacheDuration,
    this.showLogs = false,
  }) : super(key: key);

  @override
  State<GetImageCacheNetwork> createState() => _GetImageCacheNetworkState();
}

class _GetImageCacheNetworkState extends State<GetImageCacheNetwork> {
  final Dio _dio = Dio();

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    // Inizialize path provider
    AppPathProvider.initPath().then((value) {
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

      // Adding intercetors to handle cache and show logs
      _dio.interceptors.add(dioCacheInterceptor);
      if (widget.showLogs) {
        _dio.interceptors.add(dioInterceptor);
      }
    });

    super.initState();
  }

  /* Get image from network */
  Future<dartz.Either<Failure, Uint8List>> getImageFromNetwork() async {
    // doing request to get image
    try {
      final response = await _dio.get(
        widget.imageFromNetworkUrl,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
        ),
      );

      /* Convert bytes to Uint8List */
      Uint8List bytes = Uint8List.fromList(response.data);

      // Return image converted
      return dartz.Right(bytes);
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
                ? (snapshot.data as dartz.Either<Failure, Uint8List>).fold(
                    (failure) => Image.asset(
                      widget.imageFromAssetsUrl,
                      scale: widget.errorScale ?? widget.scale ?? 1,
                      fit: widget.errorFit ?? widget.fit ?? BoxFit.cover,
                      width: widget.errorWidth ?? widget.width ?? 64,
                      height: widget.errorHeight ?? widget.height ?? 64,
                    ),
                    (bytes) => Image.memory(
                      bytes,
                      scale: widget.scale ?? 1,
                      width: widget.width ?? 64,
                      height: widget.height ?? 64,
                      fit: widget.fit ?? BoxFit.cover,
                    ),
                  )
                : SizedBox(
                    height: widget.height ?? 64,
                    width: widget.width ?? 64,
                    child: Center(
                        child: widget.loading ??
                            const CircularProgressIndicator(
                                color: Color(0xff0abb87))));
          },
        ),
      ),
    );
  }
}
