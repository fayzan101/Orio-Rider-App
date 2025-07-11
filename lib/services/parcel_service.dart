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
      print('API response: \n[32m${response.data}[0m');
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

  static Future<Response?> createLoadsheet(String shipmentNo) async {
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
      
      final trimmedShipmentNo = shipmentNo.trim();
      print('Creating loadsheet for shipment: "$trimmedShipmentNo"');
      print('Using authorization: $authHeader');
      
      final response = await dio.post(
        url,
        data: {'shipment_no': trimmedShipmentNo},
        options: Options(headers: headers),
      );
      return response;
    } catch (e) {
      print('API error: $e');
      return null;
    }
  }
}