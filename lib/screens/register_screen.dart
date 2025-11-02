import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upih_pet_grooming/services/auth_service.dart';
import 'package:upih_pet_grooming/utils/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;

  void _signUp() async {
    if (_fullNameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = "All fields must be filled!";
      });
      return;
    }
    
    if (_passwordController.text.length < 6) {
      setState(() {
         _errorMessage = "Password must be at least 6 characters.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    
    String? error = await authService.signUp(
      _fullNameController.text,
      _emailController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (error == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sign up successful! Please log in."),
          backgroundColor: Colors.green[700],
        ),
      );
      
      Navigator.of(context).pop(); 

    } else {
      setState(() {
        _errorMessage = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign up for a new account"),
        backgroundColor: Colors.transparent, 
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.secondary),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 200,),
              SizedBox(height: 16),
              Text(
                "Create an Account",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                "Start your furry friend's journey 🐾",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 40),

              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                ),
                keyboardType: TextInputType.name,
              ),
              SizedBox(height: 16),
              
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock_outlined, color: AppColors.primary),
                  hintText: "Minimum 6 characters"
                ),
              ),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(height: 32),

              _isLoading
                  ? CircularProgressIndicator(color: AppColors.primary)
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textLight,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text("Sign Up Now", style: TextStyle(fontSize: 18)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}