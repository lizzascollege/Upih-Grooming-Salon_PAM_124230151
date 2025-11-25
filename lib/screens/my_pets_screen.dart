import 'dart:convert'; // Untuk mengubah gambar ke Base64
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart'; // Wajib import ini
import 'package:upih_pet_grooming/models/pet_model.dart';
import 'package:upih_pet_grooming/utils/app_colors.dart';

class MyPetsScreen extends StatefulWidget {
  const MyPetsScreen({super.key});

  @override
  _MyPetsScreenState createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  final Box<PetModel> _petBox = Hive.box<PetModel>('myPetsBox');
  final ImagePicker _picker = ImagePicker();

  // Variabel sementara untuk menampung foto saat di dalam Dialog
  String? _tempSelectedImageBase64;

  // Fungsi untuk mengambil gambar dan mengubahnya jadi String (Base64)
  Future<void> _pickImage(StateSetter setStateDialog) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Kompres biar tidak berat di Hive
    );

    if (image != null) {
      // Baca file sebagai bytes
      final bytes = await image.readAsBytes();
      // Ubah ke string base64 agar bisa disimpan di Hive
      final base64String = base64Encode(bytes);
      
      // Update tampilan di dalam Dialog
      setStateDialog(() {
        _tempSelectedImageBase64 = base64String;
      });
    }
  }

  void _showAddPetDialog({PetModel? petToEdit}) {
    final bool isEditing = petToEdit != null;
    final nameController = TextEditingController(text: petToEdit?.name);
    final typeController = TextEditingController(text: petToEdit?.type);
    final breedController = TextEditingController(text: petToEdit?.breed);
    final ageController = TextEditingController(text: petToEdit?.age.toString());

    // Jika sedang edit, ambil gambar lama. Jika tambah baru, kosong.
    _tempSelectedImageBase64 = petToEdit?.imageBase64;

    showDialog(
      context: context,
      builder: (context) {
        // Gunakan StatefulBuilder agar kita bisa update tampilan (preview foto) di dalam Dialog
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(isEditing ? "Edit Pets" : "Add Pets"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- AREA FOTO PET ---
                    GestureDetector(
                      onTap: () => _pickImage(setStateDialog),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.lightGrey,
                        backgroundImage: _tempSelectedImageBase64 != null
                            ? MemoryImage(base64Decode(_tempSelectedImageBase64!))
                            : null,
                        child: _tempSelectedImageBase64 == null
                            ? Icon(Icons.add_a_photo, color: AppColors.mediumGrey)
                            : null,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text("Tap to add photo", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(height: 16),
                    // ---------------------

                    TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
                    SizedBox(height: 8),
                    TextField(controller: typeController, decoration: InputDecoration(labelText: "Type (Cat/Dog)")),
                    SizedBox(height: 8),
                    TextField(controller: breedController, decoration: InputDecoration(labelText: "Breed")),
                    SizedBox(height: 8),
                    TextField(controller: ageController, decoration: InputDecoration(labelText: "Age"), keyboardType: TextInputType.number),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(), 
                  child: Text("Cancel")
                ),
                ElevatedButton(
                  onPressed: () {
                    // Validasi input sederhana
                    if (nameController.text.isEmpty) return;

                    final newPet = PetModel(
                      name: nameController.text,
                      type: typeController.text,
                      breed: breedController.text,
                      age: int.tryParse(ageController.text) ?? 0,
                      imageBase64: _tempSelectedImageBase64, // Simpan string fotonya
                    );
                    
                    if (isEditing) {
                      petToEdit!.name = newPet.name;
                      petToEdit.type = newPet.type;
                      petToEdit.breed = newPet.breed;
                      petToEdit.age = newPet.age;
                      petToEdit.imageBase64 = newPet.imageBase64; // Update foto
                      petToEdit.save(); 
                    } else {
                      _petBox.add(newPet); 
                    }
                    
                    Navigator.of(context).pop();
                  },
                  child: Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Pets 🐶"),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: () => _showAddPetDialog(),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _petBox.listenable(),
        builder: (context, Box<PetModel> box, _) {
          if (box.values.isEmpty) {
            return Center(
              child: Text(
                "You don't have any pet data yet.\nClick '+' to add.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final pet = box.getAt(index);
              if (pet == null) return SizedBox.shrink();

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    // LOGIKA TAMPILAN GAMBAR:
                    // Jika ada gambar Base64 -> Decode dan tampilkan
                    // Jika tidak ada -> Tampilkan Emoji seperti sebelumnya
                    backgroundImage: pet.imageBase64 != null
                        ? MemoryImage(base64Decode(pet.imageBase64!))
                        : null,
                    child: pet.imageBase64 == null
                        ? Text(
                            pet.type.toLowerCase().startsWith("k") ? "🐱" : "🐶",
                            style: TextStyle(fontSize: 24),
                          )
                        : null,
                  ),
                  title: Text(pet.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${pet.breed} - ${pet.age} years"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: AppColors.secondary, size: 20),
                        onPressed: () => _showAddPetDialog(petToEdit: pet),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () {
                          pet.delete(); 
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}