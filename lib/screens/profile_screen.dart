import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upih_pet_grooming/screens/login_screen.dart';
import 'package:upih_pet_grooming/screens/my_pets_screen.dart';
import 'package:upih_pet_grooming/services/api_service.dart';
import 'package:upih_pet_grooming/services/auth_service.dart';
import 'package:upih_pet_grooming/utils/app_colors.dart';
import 'package:upih_pet_grooming/screens/history_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _fullName = "User";
  String _email = "Loading...";
  String? _avatarUrl;
  bool _isLoadingPage = true;
  bool _isUploading = false;

  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() { _isLoadingPage = true; });

    final authService = Provider.of<AuthService>(context, listen: false);
    final User? user = await authService.getCurrentUser();

    if (user != null && mounted) {
      setState(() {
        _fullName = user.userMetadata?['full_name'] ?? 'No Name';
        _email = user.email ?? 'No Email';
        _avatarUrl = user.userMetadata?['avatar_url'];
        _isLoadingPage = false;
      });
    } else {
      setState(() {
        _isLoadingPage = false;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (_isUploading) return;

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image == null) return; 

    setState(() { _isUploading = true; });

    try {
      final newUrl = await _apiService.uploadProfileImage(image);
      if (newUrl == null) throw Exception("Failed to get URL");
      
      final authService = Provider.of<AuthService>(context, listen: false);
      final error = await authService.updateUserProfile(newUrl);

      if (error == null && mounted) {
        setState(() {
          _avatarUrl = newUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile picture updated!"), backgroundColor: Colors.green),
        );
      } else {
        throw Exception(error);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload image: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isUploading = false; });
      }
    }
  }


  void _logout(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
    
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _showFeedbackDialog(BuildContext context){
    const String staticFeedbackContent = "Selama saya mengerjakan tugas ini, saya merasa hari dalam satu minggu tidak lagi berjumlah tujuh, kadang terasa cuma 1 hari saja untuk mengerjakan tugas. Saya belajar banyak, bukan hanya tentang bagaimana membuat aplikasi, tetapi juga bagaimana mengelola rasa panik secara professional, sambil tetap mempertanyakan pilihan hidup dengan slaay~~. Meski sering terasa seperti sedang mengikuti bootcamp developer dalam satu semester, pengalaman ini pada akhirnya membuka mata saya bahwa dunia IT sepertinya bukan dunia saya. Walaupun aplikasi yang saya buat masih sederhana dibandingkan teman-teman lain, pekerjaan ini saya selesaikan dengan sisa tenaga, kreativitas, dan rasa tanggung jawab yang tersisa. Semoga ke depannya pak bagus bisa terus mengajar sambal bercanda seperti sekarang, tapi kalau bisa—deadlinenya ikut bercanda juga. Terimakasih banyak pak, semoga kita tidak bertemu tahun depan.";

    showDialog(
      context: context,
      builder:(context) {
        return AlertDialog(
          title: Text("Lesson Feedback"),
          content: SingleChildScrollView(
            child: Text(
              staticFeedbackContent,
              style: TextStyle(fontSize: 16),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(),
            child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
        automaticallyImplyLeading: false,
      ),
      body: _isLoadingPage 
        ? Center(child: CircularProgressIndicator(color: AppColors.primary))
        : ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Column(
            children: [
              GestureDetector(
                onTap: _pickAndUploadImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.lightGrey,
                      backgroundImage: _avatarUrl != null
                          ? NetworkImage(_avatarUrl!)
                          : null,
                      child: _avatarUrl == null && !_isUploading
                          ? Icon(Icons.person, size: 50, color: AppColors.mediumGrey)
                          : null,
                    ),
                    if (_isUploading)
                      CircularProgressIndicator(color: AppColors.primary),
                    if (!_isUploading)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2)
                          ),
                          child: Icon(Icons.edit, color: Colors.white, size: 16),
                        ),
                      )
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text(
                _fullName,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                _email,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 32),
          
          _buildProfileMenu(
            context,
            icon: Icons.pets,
            title: "My Pets",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => MyPetsScreen()),
              );
            },
          ),
          _buildProfileMenu(
            context,
            icon: Icons.history,
            title: "Booking History",
            onTap: () { 
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
          ),
          Divider(height: 32),
          _buildProfileMenu(
            context,
            icon: Icons.rate_review_outlined,
            title: "Lesson Feedback",
            onTap: () => _showFeedbackDialog(context),
          ),

          _buildProfileMenu(
            context,
            icon: Icons.logout,
            title: "Logout",
            color: Colors.red,
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap,
      Color? color}) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.primary),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.textDark,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}