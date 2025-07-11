import 'package:get/get.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/Pickup.dart';

class DashboardCardController extends GetxController {
  var showManifest = false.obs;
  var showDeManifest = false.obs;
  var showCreateSheet = false.obs;
  var showDelivery = false.obs;
  var showTracking = false.obs;
  var showReport = false.obs;
  var showPickup = false.obs;
  var showArrival = false.obs;
  var pickupList = <PickupItem>[].obs;

  Timer? _pollingTimer;

  @override
  void onInit() {
    super.onInit();
    fetchFlags();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchFlags();
    });
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    super.onClose();
  }

  Future<void> fetchFlags() async {
    final prefs = await SharedPreferences.getInstance();
    showManifest.value = (prefs.getInt('manifest') ?? 0) == 1;
    showReport.value = (prefs.getInt('report') ?? 0) == 1;
    showDeManifest.value = (prefs.getInt('de_manifest') ?? 0) == 1;
    showCreateSheet.value = (prefs.getInt('create_sheet') ?? 0) == 1;
    showDelivery.value = (prefs.getInt('delivery') ?? 0) == 1;
    showTracking.value = (prefs.getInt('tracking') ?? 0) == 1;
    showPickup.value = (prefs.getInt('loadsheet') ?? 0) == 1;
    int arrival = int.tryParse(prefs.getString('arrival') ?? '0') ?? 1;
    showArrival.value = arrival == 1;
  }
} 