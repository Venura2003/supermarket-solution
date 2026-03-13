class Supplier {
  final int id;
  final String name;
  final String? contactNo;
  final String? address;

  Supplier({
    required this.id, 
    required this.name, 
    this.contactNo, 
    this.address
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      name: json['name'],
      contactNo: json['contactNo'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contactNo': contactNo,
      'address': address,
    };
  }
}
