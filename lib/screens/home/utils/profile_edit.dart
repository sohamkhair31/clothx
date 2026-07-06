import 'package:clothx/controllers/auth_controller.dart';
import 'package:clothx/screens/collections/collections_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() =>
      _EditProfileDialogState();
}

class _EditProfileDialogState
    extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final user =
        context.read<AuthController>().currentUserData;

    _nameController = TextEditingController(
      text: user?.name ?? "",
    );

    _phoneController = TextEditingController(
      text: user?.phone ?? "",
    );

  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      await context.read<AuthController>().updateProfile(
            name: _nameController.text,
            phone: _phoneController.text,
          );

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final dialogWidth =
        width < 600 ? width * .92 : 520.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: NVColors.charcoal,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: NVColors.gold.withOpacity(.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.35),
              blurRadius: 30,
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Edit Profile",
                  style: TextStyle(
                    color: NVColors.ivory,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 28),

                _field(
                  controller: _nameController,
                  label: "Full Name",
                  icon: Icons.person_outline,
                ),

                const SizedBox(height: 18),

                _field(
                  controller: _phoneController,
                  label: "Phone",
                  icon: Icons.phone_outlined,
                  keyboard: TextInputType.phone,
                ),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: NVColors.ivory,
                          side: const BorderSide(
                            color: NVColors.gold,
                          ),
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              NVColors.gold,
                          foregroundColor:
                              NVColors.charcoal,
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Save",
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard =
        TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      style: const TextStyle(
        color: NVColors.ivory,
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return "Required";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: NVColors.softGray),
        prefixIcon: Icon(
          icon,
          color: NVColors.gold,
        ),
        filled: true,
        fillColor: NVColors.charcoalLight,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide: BorderSide(
            color:
                Colors.white.withOpacity(.08),
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(16)),
          borderSide:
              BorderSide(color: NVColors.gold),
        ),
      ),
    );
  }
}