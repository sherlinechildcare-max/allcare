import "package:flutter/material.dart";
import "package:supabase_flutter/supabase_flutter.dart";

import "../data/profile_model.dart";
import "../data/profile_repository.dart";

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Profile? _profile;
  bool _loading = true;
  bool _saving = false;

  late final TextEditingController _nameC;
  late final TextEditingController _phoneC;
  late final TextEditingController _cityC;
  late final TextEditingController _bioC;

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController();
    _phoneC = TextEditingController();
    _cityC = TextEditingController();
    _bioC = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _nameC.dispose();
    _phoneC.dispose();
    _cityC.dispose();
    _bioC.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final repo = ProfileRepository(Supabase.instance.client);
      final p = await repo.getOrCreateProfile(user.id);

      _nameC.text = p.fullName ?? "";
      _phoneC.text = p.phone ?? "";
      _cityC.text = p.city ?? "";
      _bioC.text = p.bio ?? "";

      setState(() {
        _profile = p;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to load profile: $e")));
      }
    }
  }

  Future<void> _save() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || _profile == null) return;

    setState(() => _saving = true);

    try {
      final repo = ProfileRepository(Supabase.instance.client);

      final updated = _profile!.copyWith(
        fullName: _nameC.text.trim().isEmpty ? null : _nameC.text.trim(),
        phone: _phoneC.text.trim().isEmpty ? null : _phoneC.text.trim(),
        city: _cityC.text.trim().isEmpty ? null : _cityC.text.trim(),
        bio: _bioC.text.trim().isEmpty ? null : _bioC.text.trim(),
      );

      await repo.updateProfile(updated);

      setState(() {
        _profile = updated;
        _saving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("✅ Profile saved")));
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Save failed: $e")));
      }
    }
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Signed out")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (user == null)
          ? const Center(child: Text("Not signed in"))
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundImage: (_profile?.avatarUrl != null)
                            ? NetworkImage(_profile!.avatarUrl!)
                            : null,
                        child: (_profile?.avatarUrl == null)
                            ? const Icon(Icons.person, size: 34)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nameC.text.isEmpty ? "Your name" : _nameC.text,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Signed in as: ${user.email ?? user.id}",
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  _field(
                    controller: _nameC,
                    label: "Full name",
                    icon: Icons.badge,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    controller: _phoneC,
                    label: "Phone",
                    icon: Icons.phone,
                    keyboard: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    controller: _cityC,
                    label: "City",
                    icon: Icons.location_city,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    controller: _bioC,
                    label: "Bio (optional)",
                    icon: Icons.info_outline,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 18),

                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Save"),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _signOut,
                    child: const Text("Sign out"),
                  ),

                  const SizedBox(height: 10),
                  Text(
                    "Avatar upload: enabled later (safe placeholder).",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
