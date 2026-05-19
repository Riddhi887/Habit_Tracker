import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/services/auth_service.dart';
import 'package:habit_tracker/screens/home_screen.dart';
import 'package:habit_tracker/screens/signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  //text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //create form key to validate form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //loading spinner and password hiding
  bool _isLoading = false;
  bool _obscurePassword = true;

  final AuthService _authService = AuthService();

  //dispose controller
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //while login check validation
  Future<void> _login() async {
    //if no validation : return : show error
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    //else
    final String? error = await _authService.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (error != null) {
      //show error in snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.purple[100]),
        );
      } else {
        //navigate to HomeScreen
        if (mounted) {
          Navigator.of(
            context,
          ).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
        }
      }
    }
  }

  //frontend
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.all(25.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //App title
                Text(
                  'HABIT TRACKER',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blueGrey[500]),
                ),

                //Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),

                  //validate email
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your email';
                    }
                    if (!value.contains('@')) return 'Enter valid email';
                    return null; //valid
                  },
                ),

                const SizedBox(height: 17),

                //Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),

                  //validate password field
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be of 6 or more characters';
                    }
                    return null; //if valid
                  },
                ),

                const SizedBox(height: 25),

                //Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(),
                        )
                      : const Text('Login', style: TextStyle(fontSize: 16)),
                ),

                const SizedBox(height: 17),

                //navigate to signup
                TextButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => SignUpScreen())),
                  child: const Text("Don't have an account ? Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
