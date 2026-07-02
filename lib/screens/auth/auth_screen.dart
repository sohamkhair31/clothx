import 'package:clothx/controllers/auth_controller.dart';
import 'package:clothx/screens/bottom_nav_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() =>
      _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  final nameController =
      TextEditingController();
  final emailController =
      TextEditingController();
  final passwordController =
      TextEditingController();
  final phoneController =
      TextEditingController();
  final addressController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth =
        context.watch<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isLogin ? "Login" : "Signup",
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [
            if (!isLogin)
              TextField(
                controller: nameController,
                decoration:
                    const InputDecoration(
                  labelText: "Name",
                ),
              ),

            TextField(
              controller: emailController,
              decoration:
                  const InputDecoration(
                labelText: "Email",
              ),
            ),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration:
                  const InputDecoration(
                labelText: "Password",
              ),
            ),

            if (!isLogin)
              TextField(
                controller:
                    phoneController,
                decoration:
                    const InputDecoration(
                  labelText: "Phone",
                ),
              ),

            if (!isLogin)
              TextField(
                controller:
                    addressController,
                decoration:
                    const InputDecoration(
                  labelText: "Address",
                ),
              ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                bool success = false;

                if (isLogin) {
                  success = await auth.login(
                    email:
                        emailController.text,
                    password:
                        passwordController.text,
                  );
                } else {
                  success =
                      await auth.signUp(
                    name:
                        nameController.text,
                    email:
                        emailController.text,
                    password:
                        passwordController.text,
                    phone:
                        phoneController.text,
                    address:
                        addressController.text,
                  );
                }

                if (success &&
                    context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const BottomNavScreen()
                    ),
                  );
                }
              },
              child: Text(
                isLogin
                    ? "Login"
                    : "Signup",
              ),
            ),

            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                });
              },
              child: Text(
                isLogin
                    ? "Create account"
                    : "Already have account?",
              ),
            ),
          ],
        ),
      ),
    );
  }
}