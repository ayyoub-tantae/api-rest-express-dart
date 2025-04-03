import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// URL de base du serveur
const String baseUrl = 'http://localhost:3000';

// Classe représentant un produit
class Product {
  final String name;
  final double price;
  int? id;

  Product({required this.name, required this.price, this.id});

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        if (id != null) 'id': id,
      };

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      price: json['price'] is int ? json['price'].toDouble() : json['price'],
      id: json['id'],
    );
  }

  @override
  String toString() {
    return 'Produit #$id: $name - ${price.toStringAsFixed(2)}€';
  }
}

// Classe représentant une commande
class Order {
  final String product;
  final int quantity;
  int? id;
  String? date;

  Order({required this.product, required this.quantity, this.id, this.date});

  Map<String, dynamic> toJson() => {
        'product': product,
        'quantity': quantity,
        if (id != null) 'id': id,
        if (date != null) 'date': date,
      };

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      product: json['product'],
      quantity: json['quantity'],
      id: json['id'],
      date: json['date'],
    );
  }

  @override
  String toString() {
    return 'Commande #$id: $quantity x $product (${date != null ? date!.substring(0, 10) : "Non daté"})';
  }
}

// Fonction pour récupérer tous les produits
Future<List<Product>> getProducts() async {
  try {
    print('📥 Récupération des produits...');
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      List<Product> products =
          jsonList.map((json) => Product.fromJson(json)).toList();

      print('✅ ${products.length} produit(s) récupéré(s)');
      return products;
    } else {
      print(
          '❌ Erreur lors de la récupération des produits: ${response.statusCode}');
      print('   Réponse: ${response.body}');
      return [];
    }
  } catch (e) {
    print('❌ Exception: $e');
    return [];
  }
}

// Fonction pour ajouter un nouveau produit
Future<bool> addProduct(Product product) async {
  try {
    print('📤 Ajout du produit: ${product.name}...');
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 201) {
      print('✅ Produit ajouté avec succès');
      return true;
    } else {
      print('❌ Erreur lors de l\'ajout du produit: ${response.statusCode}');
      print('   Réponse: ${response.body}');
      return false;
    }
  } catch (e) {
    print('❌ Exception: $e');
    return false;
  }
}

// Fonction pour récupérer toutes les commandes
Future<List<Order>> getOrders() async {
  try {
    print('📥 Récupération des commandes...');
    final response = await http.get(Uri.parse('$baseUrl/orders'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      List<Order> orders =
          jsonList.map((json) => Order.fromJson(json)).toList();

      print('✅ ${orders.length} commande(s) récupérée(s)');
      return orders;
    } else {
      print(
          '❌ Erreur lors de la récupération des commandes: ${response.statusCode}');
      print('   Réponse: ${response.body}');
      return [];
    }
  } catch (e) {
    print('❌ Exception: $e');
    return [];
  }
}

// Fonction pour ajouter une nouvelle commande
Future<bool> addOrder(Order order) async {
  try {
    print('📤 Ajout de la commande: ${order.quantity}x ${order.product}...');
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode(order.toJson()),
    );

    if (response.statusCode == 201) {
      print('✅ Commande créée avec succès');
      return true;
    } else {
      print(
          '❌ Erreur lors de la création de la commande: ${response.statusCode}');
      print('   Réponse: ${response.body}');
      return false;
    }
  } catch (e) {
    print('❌ Exception: $e');
    return false;
  }
}

// Fonction pour afficher une liste d'éléments
void printItems<T>(List<T> items, String type) {
  if (items.isEmpty) {
    print('   Aucun $type disponible');
  } else {
    for (var item in items) {
      print('   - $item');
    }
  }
  print('');
}

// Fonction principale pour tester toutes les fonctionnalités
void main() async {
  print('\n🚀 DÉMARRAGE DES TESTS DE L\'API CLIENT DART 🚀\n');

  // 1. Récupérer et afficher tous les produits (devrait être vide au début)
  print('\n📊 TEST #1: RÉCUPÉRATION DES PRODUITS INITIAUX');
  var products = await getProducts();
  printItems(products, 'produit');

  // 2. Ajouter des nouveaux produits
  print('📊 TEST #2: AJOUT DE NOUVEAUX PRODUITS');
  await addProduct(Product(name: 'Laptop', price: 999.99));
  await addProduct(Product(name: 'Smartphone', price: 499.50));
  await addProduct(Product(name: 'Écouteurs', price: 79.99));

  // 3. Vérifier que les produits ont été ajoutés
  print('\n📊 TEST #3: VÉRIFICATION DE L\'AJOUT DES PRODUITS');
  products = await getProducts();
  printItems(products, 'produit');

  // 4. Récupérer et afficher toutes les commandes (devrait être vide au début)
  print('📊 TEST #4: RÉCUPÉRATION DES COMMANDES INITIALES');
  var orders = await getOrders();
  printItems(orders, 'commande');

  // 5. Ajouter des nouvelles commandes
  print('📊 TEST #5: AJOUT DE NOUVELLES COMMANDES');
  await addOrder(Order(product: 'Laptop', quantity: 1));
  await addOrder(Order(product: 'Smartphone', quantity: 2));
  await addOrder(Order(product: 'Écouteurs', quantity: 3));

  // 6. Vérifier que les commandes ont été ajoutées
  print('\n📊 TEST #6: VÉRIFICATION DE L\'AJOUT DES COMMANDES');
  orders = await getOrders();
  printItems(orders, 'commande');

  print('🏁 TESTS TERMINÉS AVEC SUCCÈS! 🏁');
}
