import 'package:clothx/controllers/auth_controller.dart';
import 'package:clothx/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final auth =
          context.read<AuthController>();

      if (auth.currentUser != null &&
          auth.currentUserData == null) {
        await auth.getUserData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth =
        context.watch<AuthController>();

    final user = auth.currentUserData;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: auth.isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : user == null
              ? Center(
                  child: Text(
                    "No user data",
                    style:
                        AppTheme.subHeading,
                  ),
                )
              : SingleChildScrollView(
                  padding:
                      const EdgeInsets.all(
                    20,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          child: Text(
                            user.name[0]
                                .toUpperCase(),
                            style:
                                const TextStyle(
                              fontSize: 30,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      buildTile(
                        "Name",
                        user.name,
                      ),
                      buildTile(
                        "Email",
                        user.email,
                      ),
                      buildTile(
                        "Phone",
                        user.phone,
                      ),
                      buildTile(
                        "Address",
                        user.address,
                      ),

                      const SizedBox(
                        height: 40,
                      ),

                      SizedBox(
                        width:
                            double.infinity,
                        child:
                            ElevatedButton(
                          onPressed:
                              () async {
                            await auth
                                .logout();

                            if (!mounted) return;

                            Navigator.pop(
                              context,
                            );
                          },
                          child:
                              const Text(
                            "Logout",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget buildTile(
    String title,
    String value,
  ) {
    return Card(
      margin:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}