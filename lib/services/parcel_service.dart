import 'package:dio/dio.dart';
import '../models/parcel_model.dart';
import '../services/user_service.dart';

class ParcelService {
  static Future<Map<String, dynamic>> getParcelByTrackingNumberWithResponse(String trackingNumber) async {
    final dio = Dio();
    const url = 'https://thegoexpress.com/api/loadsheet_by_cn';

    try {
      // Get authorization header from saved credentials
      final authHeader = await UserService.getAuthorizationHeader();
      if (authHeader == null) {
        print('Error: No saved credentials found. Please login again.');
        return {'parcel': null, 'response': null};
      }
     
      final headers = {
        'Authorization': authHeader,
        'Content-Type': 'application/json',
      };
     
      final trimmedTrackingNumber = trackingNumber.toString().trim();
      print('Tracking number sent to API: "$trimmedTrackingNumber"');
      print('Using authorization: $authHeader');
     
      final response = await dio.post(
        url,
        data: {'shipment_no': trimmedTrackingNumber},
        options: Options(headers: headers),
      );
      print('API response: \n[32m${response.data}[0m');
      if (response.statusCode == 200 && response.data['status'] == 1) {
        final body = response.data['data']['body'];
        if (body is List && body.isNotEmpty) {
          final item = body[0];
          return {'parcel': ParcelModel(
            shipmentNo: item['shipment_no']?.toString() ?? '',
            shipmentDate: item['shipment_date']?.toString() ?? '',
            tpcnno: item['tpcnno']?.toString() ?? '',
            tpname: item['tpname']?.toString() ?? '',
            shipmentReference: item['shipment_reference']?.toString() ?? '',
            consigneeName: item['consignee_name']?.toString() ?? '',
            consigneeContact: item['consignee_contact']?.toString() ?? '',
            productDetail: item['product_detail']?.toString() ?? '',
            consigneeAddress: item['consignee_address']?.toString() ?? '',
            destinationCity: item['destination_city']?.toString() ?? '',
            peices: item['peices']?.toString() ?? '',
            weight: item['weight']?.toString() ?? '',
            cashCollect: item['cash_collect']?.toString() ?? '',
            createdBy: item['created_by']?.toString() ?? '',
          ), 'response': response};
        }
      }
      return {'parcel': null, 'response': response};
    } catch (e) {
      print('API error: $e');
      return {'parcel': null, 'response': null};
    }
  }

  static Future<Response?> createLoadsheet(String shipmentNos) async {
    final dio = Dio();
     const url = 'https://thegoexpress.com/api/create_loadsheet';
    try {
      // Get authorization header from saved credentials
      final authHeader = await UserService.getAuthorizationHeader();
      if (authHeader == null) {
        print('Error: No saved credentials found. Please login again.');
        return null;
      }
      final headers = {
        'Authorization': authHeader,
        'Content-Type': 'application/json',
      };
      final trimmedShipmentNos = shipmentNos.trim();
      print('Creating loadsheet for shipment(s): "$trimmedShipmentNos"');
      print('Using authorization: $authHeader');
      final response = await dio.post(
        url,
        data: {'shipment_no': trimmedShipmentNos},
        options: Options(headers: headers),
      );
      return response;
    } catch (e) {
      print('API error: $e');
      return null;
    }
  }

  static Future<dynamic> getSheetwiseReport({required String startDate, required String endDate, required String type}) async {
    final dioInstance = Dio();
    const url = 'https://thegoexpress.com/api/sheetwise_report';
    try {
      // Get authorization header from saved credentials
      final authHeader = await UserService.getAuthorizationHeader();
      if (authHeader == null) {
        print('Error: No saved credentials found. Please login again.');
        return null;
      }
      final headers = {
        'Authorization': authHeader,
        'Content-Type': 'application/json',
      };
      final response = await dioInstance.post(
        url,
        data: {
          'start_date': startDate,
          'end_date': endDate,
          'type': type,
        },
        options: Options(headers: headers),
      );
      print('Sheetwise report raw response: \n');
      print(response.data);
      print('Type of response.data: \n');
      print(response.data.runtimeType);
      if (response.data is Map && response.data['data'] != null) {
        print('Type of response.data[\'data\']: \n');
        print(response.data['data'].runtimeType);
        if (response.data['data'] is Map && response.data['data']['body'] != null) {
          print('Type of response.data[\'data\'][\'body\']: \n');
          print(response.data['data']['body'].runtimeType);
        }
      }
      return response.data;
    } catch (e) {
      print('Sheetwise report API error: $e');
      return null;
    }
  }
}