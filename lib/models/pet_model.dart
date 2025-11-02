// lib/models/pet_model.dart
import 'package:hive/hive.dart';

part 'pet_model.g.dart'; // Ini biarkan

@HiveType(typeId: 0)
class PetModel extends HiveObject {
  
  // 🔽 HAPUS 'final' AGAR BISA DI-EDIT 🔽
  @HiveField(0)
  String name;

  @HiveField(1)
  String type;

  @HiveField(2)
  String breed;
  
  // 🔽 TAMBAHKAN FIELD 'age' YANG BARU 🔽
  @HiveField(3)
  int age;

  PetModel({
    required this.name,
    required this.type,
    required this.breed,
    required this.age, // Tambahkan 'age' di constructor
  });
}