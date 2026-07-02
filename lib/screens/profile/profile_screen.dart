import 'package:clothx/controllers/auth_controller.dart';
import 'package:clothx/core/theme/app_theme.dart';
import 'package:clothx/screens/auth/auth_screen.dart';
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

  void showEditDialog(
    BuildContext context,
    AuthController auth,
  ) {
    final user = auth.currentUserData;

    if (user == null) return;

    final nameController =
        TextEditingController(
      text: user.name,
    );

    final phoneController =
        TextEditingController(
      text: user.phone,
    );

    final addressController =
        TextEditingController(
      text: user.address,
    );

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title:
              const Text("Edit Profile"),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              TextField(
                controller:
                    nameController,
                decoration:
                    const InputDecoration(
                  labelText: "Name",
                ),
              ),
              TextField(
                controller:
                    phoneController,
                decoration:
                    const InputDecoration(
                  labelText: "Phone",
                ),
              ),
              TextField(
                controller:
                    addressController,
                decoration:
                    const InputDecoration(
                  labelText: "Address",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child:
                  const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName =
    nameController.text.trim();

final newPhone =
    phoneController.text.trim();

final newAddress =
    addressController.text.trim();

// Prevent unnecessary writes
if (newName == user.name &&
    newPhone == user.phone &&
    newAddress == user.address) {
  Navigator.pop(context);
  return;
}

final success =
    await auth.updateProfile(
  name: newName,
  phone: newPhone,
  address: newAddress,
);

                if (!mounted) return;

                if (success) {
                  Navigator.pop(
                    context,
                  );
                }
              },
              child:
                  const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth =
        context.watch<AuthController>();

    final user =
        auth.currentUserData;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Profile"),
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
                        child:
                            CircleAvatar(
                          radius: 50,
                          child: Text(
                            user.name
                                    .isNotEmpty
                                ? user.name[0]
                                    .toUpperCase()
                                : "?",
                            style:
                                const TextStyle(
                              fontSize:
                                  30,
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
                        height: 30,
                      ),

                      SizedBox(
                        width:
                            double.infinity,
                        child:
                            ElevatedButton(
                          onPressed: () {
                            showEditDialog(
                              context,
                              auth,
                            );
                          },
                          child:
                              const Text(
                            "Edit Profile",
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 15,
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

                            if (!mounted) {
                              return;
                            }

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const AuthScreen(),
                              ),
                              (
                                route,
                              ) =>
                                  false,
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