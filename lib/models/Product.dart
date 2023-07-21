class Product {
  int? id;
  String? title;
  String? description;
  int? price;
  int? stock;
  String? thumbnail;

  Product(
      {this.id,
        this.title,
        this.description,
        this.price,
        this.stock,
        this.thumbnail});

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    price = json['price'];
    stock = json['stock'];
    thumbnail = json['thumbnail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['price'] = this.price;
    data['stock'] = this.stock;
    data['thumbnail'] = this.thumbnail;
    return data;
  }
}