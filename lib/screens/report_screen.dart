import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/parcel_service.dart';
import '../widgets/custom_date_selector.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _loading = false;
  List<dynamic> _sheetData = [];
  List<dynamic> _filteredSheetData = [];
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'Load Sheet';
  final List<String> _typeOptions = ['Load Sheet'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = now;
    _endDate = now;
    _fetchReport();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSheetData = List.from(_sheetData);
      } else {
        _filteredSheetData = _sheetData.map((sheet) {
          if (sheet['detail'] is List) {
            final filteredDetails = (sheet['detail'] as List).where((shipment) {
              return shipment.entries.any((entry) =>
                entry.value != null && entry.value.toString().toLowerCase().contains(query)
              );
            }).toList();
            if (filteredDetails.isNotEmpty) {
              return {...sheet, 'detail': filteredDetails};
            }
          }
          return null;
        }).where((sheet) => sheet != null).toList();
      }
    });
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart ? (_startDate ?? now) : (_endDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _fetchReport() async {
    if (_startDate == null || _endDate == null) return;
    setState(() { _loading = true; });
    final data = await ParcelService.getSheetwiseReport(
      startDate: _dateFormat.format(_startDate!),
      endDate: _dateFormat.format(_endDate!),
      type: _selectedType,
    );
    setState(() {
      _loading = false;
      _sheetData = [];
      final body = data != null && data['data'] != null ? data['data']['body'] : null;
      if (body is List) {
        _sheetData = List.from(body);
      } else {
        print('body is not a List, it is: \\${body.runtimeType}');
      }
      _filteredSheetData = List.from(_sheetData);
    });
  }

  String _formatLabel(String key) {
    return key
        .split('_')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sheetwise Report', style: GoogleFonts.poppins()),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDialog<DateTimeRange>(
                context: context,
                barrierDismissible: true,
                builder: (context) {
                  return Center(
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: CustomDateSelector(
                          initialStartDate: _startDate ?? DateTime.now(),
                          initialEndDate: _endDate ?? DateTime.now(),
                          fieldFillColor: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              );
              if (picked != null) {
                setState(() {
                  _startDate = picked.start;
                  _endDate = picked.end;
                });
                _fetchReport();
              }
            },
            tooltip: 'Pick Date Range',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type dropdown
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: _typeOptions.map((type) => DropdownMenuItem(
                value: type,
                child: Text(type, style: GoogleFonts.poppins()),
              )).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedType = val;
                  });
                  _fetchReport();
                }
              },
              decoration: InputDecoration(
                labelText: 'Select Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF3F3F3),
              ),
            ),
            const SizedBox(height: 16),
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Shipment No',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF3F3F3),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text('Start: ' + (_startDate != null ? _dateFormat.format(_startDate!) : 'Not selected'),
                      style: GoogleFonts.poppins()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('End: ' + (_endDate != null ? _dateFormat.format(_endDate!) : 'Not selected'),
                      style: GoogleFonts.poppins()),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: _filteredSheetData.isEmpty
                        ? Center(child: Text('No data', style: GoogleFonts.poppins()))
                        : ListView.builder(
                            itemCount: _filteredSheetData.length,
                            itemBuilder: (context, sheetIndex) {
                              final sheet = _filteredSheetData[sheetIndex];
                              return Card(
                                child: ExpansionTile(
                                  title: Text(
                                    sheet['sheet_no'] != null ? 'Sheet No: ${sheet['sheet_no']}' : 'Sheet',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: sheet['sheet_date'] != null
                                      ? Text('Created at: 	${sheet['sheet_date']}', style: GoogleFonts.poppins())
                                      : null,
                                  children: [
                                    if (sheet['detail'] is List)
                                      ...List.generate((sheet['detail'] as List).length, (shipmentIndex) {
                                        final shipment = sheet['detail'][shipmentIndex];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Card(
                                            color: const Color(0xFFE3F2FD), // Light blue
                                            margin: const EdgeInsets.symmetric(vertical: 4),
                                            child: ExpansionTile(
                                              title: Text(
                                                shipment['shipment_no'] != null
                                                    ? 'Shipment No: ${shipment['shipment_no']}'
                                                    : 'Shipment',
                                                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                                              ),
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      for (final entry in shipment.entries)
                                                        if (entry.value != null && entry.value.toString().isNotEmpty)
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(vertical: 2),
                                                            child: Text(
                                                              '${_formatLabel(entry.key)}: ${entry.value}',
                                                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                                                            ),
                                                          ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }
} 