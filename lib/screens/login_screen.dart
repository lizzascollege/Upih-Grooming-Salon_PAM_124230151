import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upih_pet_grooming/screens/main_wrapper.dart';
import 'package:upih_pet_grooming/screens/register_screen.dart'; 
import 'package:upih_pet_grooming/services/auth_service.dart';
import 'package:upih_pet_grooming/utils/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = "Email and Password cannot be empty!";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    String? error = await authService.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (error == null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainWrapper(initialIndex: 0,)),
      );
    } else {

      setState(() {
        _errorMessage = error ?? "Login failed. Please check your email & password.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 200),
              SizedBox(height: 16),
              Text(
                "Welcome!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                "Log in to your account",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 40),

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
                        onPressed: _login, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textLight,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text("Login", style: TextStyle(fontSize: 18)),
                      ),
                    ),
              
              SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: Text(
                  "Don't have an account? Register here",
                  style: TextStyle(color: AppColors.secondary),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}