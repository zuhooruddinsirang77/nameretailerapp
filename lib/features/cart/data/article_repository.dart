import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/core_providers.dart';
import '../models/article_file.dart';

final articleRepositoryProvider = Provider<ArticleRepository>(
  (ref) => ArticleRepository(ref.watch(apiClientProvider)),
);

class ArticleRepository {
  ArticleRepository(this._client);
  final ApiClient _client;

  Future<List<ArticleFile>> list() async {
    try {
      final response = await _client.dio.get(ApiConstants.articleFiles);
      return (response.data as List)
          .map((value) => ArticleFile.fromJson(value as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw ApiException(_client.extractErrorMessage(error));
    }
  }

  Future<ArticleFile> upload(String name, Uint8List bytes) async {
    if (bytes.isEmpty || bytes.length > 5 * 1024 * 1024) {
      throw ApiException(
        'Choose a nonempty PDF, DOC, DOCX or TXT file up to 5 MiB.',
      );
    }
    try {
      final response = await _client.dio.post(
        ApiConstants.articleFiles,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          sendTimeout: const Duration(seconds: 60),
        ),
        data: FormData.fromMap({
          'file': MultipartFile.fromBytes(bytes, filename: name),
        }),
      );
      return ArticleFile.fromJson(response.data as Map<String, dynamic>);
    } catch (error) {
      throw ApiException(_client.extractErrorMessage(error));
    }
  }

  Future<void> remove(String id) async {
    try {
      await _client.dio.delete('${ApiConstants.articleFiles}$id/');
    } catch (error) {
      throw ApiException(_client.extractErrorMessage(error));
    }
  }

  Future<Uint8List> download(String id) async {
    try {
      final response = await _client.dio.get<List<int>>(
        '${ApiConstants.articleFiles}$id/',
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data!);
    } catch (error) {
      throw ApiException(_client.extractErrorMessage(error));
    }
  }
}
