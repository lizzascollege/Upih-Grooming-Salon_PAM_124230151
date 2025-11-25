// lib/models/pet_model.dart
import 'package:hive/hive.dart';

part 'pet_model.g.dart'; 

@HiveType(typeId: 0)
class PetModel extends HiveObject {
  
  @HiveField(0)
  String name;

  @HiveField(1)
  String type;

  @HiveField(2)
  String breed;
  
  @HiveField(3)
  int age;

  // 🔽 FIELD BARU UNTUK MENYIMPAN FOTO 🔽
  // Tipe String karena kita menyimpan kode Base64 (teks panjang)
  // Tanda tanya (?) artinya boleh kosong jika user tidak upload foto
  @HiveField(4)
  String? imageBase64;

  PetModel({
    required this.name,
    required this.type,
    required this.breed,
    required this.age,
    this.imageBase64, // Tambahkan di sini (opsional)
  });
}