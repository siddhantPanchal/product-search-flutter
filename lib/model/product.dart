import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Product {
  final String? title;
  final String? description;
  final String? funFact;
  Product({
    this.title,
    this.description,
    this.funFact,
  });

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source) as Map<String, dynamic>);

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      title: map['title'] != null ? map['title'] as String : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      funFact: map['fun_fact'] != null ? map['fun_fact'] as String : null,
    );
  }

  @override
  int get hashCode => title.hashCode ^ description.hashCode ^ funFact.hashCode;

  @override
  bool operator ==(covariant Product other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.description == description &&
        other.funFact == funFact;
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'funFact': funFact,
    };
  }
}
