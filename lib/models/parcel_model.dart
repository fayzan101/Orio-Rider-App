class ParcelModel {
  final String shipmentNo;
  final String shipmentDate;
  final String tpcnno;
  final String tpname;
  final String shipmentReference;
  final String consigneeName;
  final String consigneeContact;
  final String productDetail;
  final String consigneeAddress;
  final String destinationCity;
  final String peices;
  final String weight;
  final String cashCollect;
  final String createdBy;

  ParcelModel({
    required this.shipmentNo,
    required this.shipmentDate,
    required this.tpcnno,
    required this.tpname,
    required this.shipmentReference,
    required this.consigneeName,
    required this.consigneeContact,
    required this.productDetail,
    required this.consigneeAddress,
    required this.destinationCity,
    required this.peices,
    required this.weight,
    required this.cashCollect,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'shipment_no': shipmentNo,
      'shipment_date': shipmentDate,
      'tpcnno': tpcnno,
      'tpname': tpname,
      'shipment_reference': shipmentReference,
      'consignee_name': consigneeName,
      'consignee_contact': consigneeContact,
      'product_detail': productDetail,
      'consignee_address': consigneeAddress,
      'destination_city': destinationCity,
      'peices': peices,
      'weight': weight,
      'cash_collect': cashCollect,
      'created_by': createdBy,
    };
  }

  factory ParcelModel.fromJson(Map<String, dynamic> json) {
    return ParcelModel(
      shipmentNo: json['shipment_no'] ?? '',
      shipmentDate: json['shipment_date'] ?? '',
      tpcnno: json['tpcnno'] ?? '',
      tpname: json['tpname'] ?? '',
      shipmentReference: json['shipment_reference'] ?? '',
      consigneeName: json['consignee_name'] ?? '',
      consigneeContact: json['consignee_contact'] ?? '',
      productDetail: json['product_detail'] ?? '',
      consigneeAddress: json['consignee_address'] ?? '',
      destinationCity: json['destination_city'] ?? '',
      peices: json['peices']?.toString() ?? '',
      weight: json['weight']?.toString() ?? '',
      cashCollect: json['cash_collect']?.toString() ?? '',
      createdBy: json['created_by'] ?? '',
    );
  }

  ParcelModel copyWith({
    String? shipmentNo,
    String? shipmentDate,
    String? tpcnno,
    String? tpname,
    String? shipmentReference,
    String? consigneeName,
    String? consigneeContact,
    String? productDetail,
    String? consigneeAddress,
    String? destinationCity,
    String? peices,
    String? weight,
    String? cashCollect,
    String? createdBy,
  }) {
    return ParcelModel(
      shipmentNo: shipmentNo ?? this.shipmentNo,
      shipmentDate: shipmentDate ?? this.shipmentDate,
      tpcnno: tpcnno ?? this.tpcnno,
      tpname: tpname ?? this.tpname,
      shipmentReference: shipmentReference ?? this.shipmentReference,
      consigneeName: consigneeName ?? this.consigneeName,
      consigneeContact: consigneeContact ?? this.consigneeContact,
      productDetail: productDetail ?? this.productDetail,
      consigneeAddress: consigneeAddress ?? this.consigneeAddress,
      destinationCity: destinationCity ?? this.destinationCity,
      peices: peices ?? this.peices,
      weight: weight ?? this.weight,
      cashCollect: cashCollect ?? this.cashCollect,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  String toString() {
    return 'ParcelModel(shipmentNo: $shipmentNo, shipmentReference: $shipmentReference, status: $shipmentDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParcelModel && other.shipmentNo == shipmentNo;
  }

  @override
  int get hashCode => shipmentNo.hashCode;
} 