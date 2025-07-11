import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sidebar_menu.dart';
import '../services/user_service.dart';
import '../services/parcel_service.dart';
import '../models/parcel_model.dart';
import 'dashboard.dart';
import 'login_screen.dart';
import 'forgot_password.dart';
import 'profile_screen.dart';
import 'qr_scanner_screen.dart';
import 'package:get/get.dart';
import '../widgets/detail_row.dart';
import '../widgets/custom_button.dart';
import '../widgets/poppins_text.dart';

class ShipmentItem {
  final ParcelModel parcel;
  bool selected;
  bool isExpanded;
  ShipmentItem({required this.parcel, this.selected = false, this.isExpanded = false});
}

class ArrivalScreen extends StatefulWidget {
  const ArrivalScreen({Key? key}) : super(key: key);

  @override
  State<ArrivalScreen> createState() => _ArrivalScreenState();
}

class _ArrivalScreenState extends State<ArrivalScreen> {
  String userName = '';
  final TextEditingController _shipmentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<ShipmentItem> _shipmentList = [];
  bool _selectAll = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  void _loadUserName() async {
    final user = await UserService.getUser();
    if (user != null && mounted) {
      setState(() {
        userName = user.fullName;
      });
    }
  }

  void _showSidebar() {
    Get.to(() => SidebarScreen(
      userName: userName,
      onProfile: () {
        Get.to(() => const ProfileScreen());
      },
      onResetPassword: () {
        Get.to(() => const ForgotPasswordScreen());
      },
      onLogout: () async {
        await UserService.logout();
        Get.offAll(() => const LoginScreen());
      },
    ));
  }

  void _addShipment() async {
    final trackingNumber = _shipmentController.text.trim();
    if (trackingNumber.isNotEmpty && !_shipmentList.any((item) => item.parcel.shipmentNo == trackingNumber)) {
      try {
        // Fetch parcel details from API
        final result = await ParcelService.getParcelByTrackingNumberWithResponse(trackingNumber);
        final parcel = result['parcel'];
        
        if (parcel != null) {
          setState(() {
            _shipmentList.add(ShipmentItem(parcel: parcel));
            _shipmentController.clear();
          });
          FocusScope.of(context).unfocus();
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Shipment added successfully: ${parcel.consigneeName}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Shipment not found. Please check the tracking number.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding shipment: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else if (_shipmentList.any((item) => item.parcel.shipmentNo == trackingNumber)) {
      // Show error if shipment already exists
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This shipment is already in the list.'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      for (var item in _shipmentList) {
        item.selected = _selectAll;
      }
    });
  }

  void _deleteSelected() {
    setState(() {
      _shipmentList.removeWhere((item) => item.selected);
      _selectAll = false;
    });
  }

  void _showDeleteDialog() {
    final selectedCount = _shipmentList.where((item) => item.selected).length;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.only(top: 80),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 56),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFE7E6F5),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(24),
                child: const Icon(Icons.delete_outline, color: Color(0xFF18136E), size: 56),
              ),
              const SizedBox(height: 24),
              Text(
                'Are you Sure',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black),
              ),
              const SizedBox(height: 8),
              Text(
                selectedCount == 1
                    ? 'You want to delete this shipment'
                    : 'You want to delete all shipments',
                style: GoogleFonts.poppins(color: Color(0xFF7B7B7B), fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F3F3),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('No', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF18136E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _deleteSelected();
                      },
                      child: Text('Yes', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.only(top: 80),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFE7E6F5),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(24),
                child: const Icon(Icons.check, color: Color(0xFF18136E), size: 56),
              ),
              const SizedBox(height: 24),
              Text(
                'Success!',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black),
              ),
              const SizedBox(height: 8),
              Text(
                'All Shipments have been created',
                style: GoogleFonts.poppins(color: Color(0xFF7B7B7B), fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF18136E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Ok', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openQrScanner() async {
    final result = await Get.to(() => QrScannerScreen(
      validIds: {},
      onScanSuccess: (trackingNumber) async {
        final result = await ParcelService.getParcelByTrackingNumberWithResponse(trackingNumber);
        final parcel = result['parcel'];
        if (parcel != null) {
          setState(() {
            _shipmentController.text = trackingNumber;
          });
        }
      },
      alreadySubmittedIds: <String>{},
    ));
  }

  List<ShipmentItem> get _filteredShipmentList {
    if (_searchQuery.isEmpty) return _shipmentList;
    return _shipmentList
        .where((item) => 
          item.parcel.shipmentNo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.parcel.consigneeName.toLowerCase().contains(_searchQuery.toLowerCase())
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final hasSelected = _shipmentList.any((item) => item.selected);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Arrival', style: GoogleFonts.poppins(color: Colors.black, fontSize: 18)),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: _showSidebar,
            ),
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Enter Shipment Number
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _shipmentController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter Shipment Number',
                          filled: true,
                          fillColor: const Color(0xFFF3F3F3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD9D9D9),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: _addShipment,
                        child: const Text('Add'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Scan by CN Dropdown
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: 'Scan by CN',
                    items: const [
                      DropdownMenuItem(
                        value: 'Scan by CN',
                        child: Text('Scan by CN'),
                      ),
                    ],
                    onChanged: null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    ),
                    icon: const Icon(Icons.arrow_drop_down),
                    disabledHint: const Text('Scan by CN'),
                  ),
                ),
                const SizedBox(height: 16),
                // Click to Scan
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: 'Click to Scan',
                          filled: true,
                          fillColor: const Color(0xFFF3F3F3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: _openQrScanner,
                        child: const Icon(Icons.qr_code_2, color: Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by tracking number or recipient name',
                          filled: true,
                          fillColor: const Color(0xFFF3F3F3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.search, color: Colors.black),
                    ),
                  ],
                ),
                if (_shipmentList.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _filteredShipmentList.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'No ID found',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      )
                    : Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _selectAll,
                                  onChanged: (val) => _toggleSelectAll(),
                                ),
                                Text(_selectAll ? 'Unselect All' : 'Select All',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                                const Spacer(),
                                if (hasSelected)
                                  CustomButton(
                                    text: 'Delete',
                                    onPressed: _showDeleteDialog,
                                    type: ButtonType.danger,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _filteredShipmentList.length,
                                itemBuilder: (context, index) {
                                  final item = _filteredShipmentList[index];
                                  return Card(
                                    color: item.selected ? Colors.grey[100] : Colors.white,
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    child: Column(
                                      children: [
                                        ListTile(
                                          leading: Checkbox(
                                            value: item.selected,
                                            onChanged: (val) {
                                              setState(() {
                                                item.selected = val ?? false;
                                                _selectAll = _shipmentList.isNotEmpty && _shipmentList.every((e) => e.selected);
                                              });
                                            },
                                          ),
                                          title: Text(
                                            item.parcel.shipmentNo,
                                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                          ),
                                          subtitle: Text(
                                            item.parcel.consigneeName,
                                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  item.isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                                  color: const Color(0xFF18136E),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    item.isExpanded = !item.isExpanded;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (item.isExpanded)
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[50],
                                              borderRadius: const BorderRadius.only(
                                                bottomLeft: Radius.circular(4),
                                                bottomRight: Radius.circular(4),
                                              ),
                                            ),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  DetailRow(label: 'Recipient', value: item.parcel.consigneeName),
                                                  DetailRow(label: 'Phone', value: item.parcel.consigneeContact),
                                                  DetailRow(label: 'Address', value: item.parcel.consigneeAddress),
                                                  const Divider(height: 16),
                                                  DetailRow(label: 'Sender', value: item.parcel.createdBy),
                                                  DetailRow(label: 'Weight', value: item.parcel.weight),
                                                  DetailRow(label: 'Product Detail', value: item.parcel.productDetail),
                                                  DetailRow(label: 'Destination City', value: item.parcel.destinationCity),
                                                  DetailRow(label: 'Shipment Date', value: item.parcel.shipmentDate),
                                                  DetailRow(label: 'Cash Collect', value: item.parcel.cashCollect),
                                                  DetailRow(label: 'TPCN No', value: item.parcel.tpcnno),
                                                  DetailRow(label: 'TP Name', value: item.parcel.tpname),
                                                  DetailRow(label: 'Shipment Reference', value: item.parcel.shipmentReference),
                                                  DetailRow(label: 'Pieces', value: item.parcel.peices),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                  if (_filteredShipmentList.isNotEmpty)
                    SafeArea(
                      top: false,
                      child: SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: 'Submit',
                          onPressed: _showSuccessDialog,
                          type: ButtonType.primary,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}