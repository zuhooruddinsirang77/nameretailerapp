import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

class InquiryRepository {
  final ApiClient _apiClient;

  InquiryRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<String> submitInquiry({
    required String name,
    required String email,
    String? domain,
    required String message,
    String? phone,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.inquiries,
        data: {
          'name': name.trim(),
          'email': email.trim().toLowerCase(),
          if (domain != null && domain.trim().isNotEmpty) 'domain': domain.trim(),
          'message': message.trim(),
          if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        },
      );
      final data = response.data as Map<String, dynamic>;
      return data['message'] as String? ?? 'Inquiry submitted successfully.';
    } catch (e) {
      throw ApiException(_apiClient.extractErrorMessage(e));
    }
  }
}
