import 'package:clothx/controllers/address_controller.dart';
import 'package:clothx/models/address_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class AddressFormScreen extends StatefulWidget {
  final String userId;
  final AddressModel? existing;

  const AddressFormScreen({
    super.key,
    required this.userId,
    this.existing,
  });

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullName;
  late final TextEditingController _phone;
  late final TextEditingController _house;
  late final TextEditingController _area;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late final TextEditingController _pincode;
  late final TextEditingController _country;

  bool _isDefault = false;
  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _fullName = TextEditingController(text: e?.fullName ?? "");
    _phone = TextEditingController(text: e?.phone ?? "");
    _house = TextEditingController(text: e?.house ?? "");
    _area = TextEditingController(text: e?.area ?? "");
    _city = TextEditingController(text: e?.city ?? "");
    _state = TextEditingController(text: e?.state ?? "");
    _pincode = TextEditingController(text: e?.pincode ?? "");
    _country = TextEditingController(text: e?.country ?? "India");
    _isDefault = e?.isDefault ?? false;
  }

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _house.dispose();
    _area.dispose();
    _city.dispose();
    _state.dispose();
    _pincode.dispose();
    _country.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final controller = context.read<AddressController>();
    final id = widget.existing?.id ??
        DateTime.now().microsecondsSinceEpoch.toString();

    final address = AddressModel(
      id: id,
      fullName: _fullName.text.trim(),
      phone: _phone.text.trim(),
      house: _house.text.trim(),
      area: _area.text.trim(),
      city: _city.text.trim(),
      state: _state.text.trim(),
      pincode: _pincode.text.trim(),
      country: _country.text.trim(),
      isDefault: _isDefault,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    final success = _isEditing
        ? await controller.updateAddress(userId: widget.userId, address: address)
        : await controller.addAddress(userId: widget.userId, address: address);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    } else {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't save address")),
      );
    }
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? "Required" : null
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Edit address" : "Add address"),
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _field(_fullName, "Full name"),
              _field(_phone, "Phone", keyboardType: TextInputType.phone),
              _field(_house, "House / flat / building"),
              _field(_area, "Area / street"),
              Row(
                children: [
                  Expanded(child: _field(_city, "City")),
                  const SizedBox(width: 12),
                  Expanded(child: _field(_state, "State")),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      _pincode,
                      "Pincode",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _field(_country, "Country")),
                ],
              ),
              CheckboxListTile(
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v ?? false),
                title: const Text("Set as default address"),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Save address"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}