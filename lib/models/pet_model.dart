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

  @HiveField(4)
  String? imageBase64;

  PetModel({
    required this.name,
    required this.type,
    required this.breed,
    required this.age,
    this.imageBase64,
  });
}