import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'otp_verification_screen.dart';
import '../state/profile_provider.dart';
import '../../incidents/presentation/map_picker_screen.dart';
import '../../../core/models/saved_location.dart';
import '../../../core/models/medical_info.dart';
import '../../auth/state/auth_provider.dart';
import '../../settings/presentation/settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _pickProfileImage(WidgetRef ref) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image == null) return;

    ref.read(profileProvider.notifier).updateProfileImage(image.path);
  }

  void _showEditMedicalDialog(BuildContext context, WidgetRef ref) {
    final user = ref.read(profileProvider).user;

    final bloodController =
        TextEditingController(text: user.medicalInfo.bloodGroup);

    final allergiesController =
        TextEditingController(text: user.medicalInfo.allergies);

    final chronicController =
        TextEditingController(text: user.medicalInfo.chronicDiseases);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Medical Information"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bloodController,
                decoration: const InputDecoration(labelText: "Blood Group"),
              ),
              TextField(
                controller: allergiesController,
                decoration: const InputDecoration(labelText: "Allergies"),
              ),
              TextField(
                controller: chronicController,
                decoration:
                    const InputDecoration(labelText: "Chronic Diseases"),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                ref.read(profileProvider.notifier).updateMedicalInfo(
                      MedicalInfo(
                        bloodGroup: bloodController.text.trim(),
                        allergies: allergiesController.text.trim(),
                        chronicDiseases: chronicController.text.trim(),
                      ),
                    );
                Navigator.pop(context);
              },
              child: const Text("Save"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final profileState = ref.watch(profileProvider);

    final user =
        profileState.user.id.isEmpty ? authState.user! : profileState.user;
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          /// -------------------------
          /// PROFILE HEADER
          /// -------------------------
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              // title: Text(user.name),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.primary,
                      color.primaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),

                      /// PROFILE IMAGE
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.white,
                            backgroundImage: user.profileImagePath != null
                                ? FileImage(File(user.profileImagePath!))
                                : null,
                            child: user.profileImagePath == null
                                ? const Icon(Icons.person, size: 48)
                                : null,
                          ),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.black,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 14,
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () => _pickProfileImage(ref),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      /// EMAIL VERIFICATION
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            user.isEmailVerified
                                ? Icons.verified
                                : Icons.warning,
                            size: 18,
                            color: user.isEmailVerified
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            user.isEmailVerified
                                ? "Email Verified"
                                : "Email Not Verified",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (!user.isEmailVerified)
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OtpVerificationScreen(
                                      email: user.email ?? '',
                                    ),
                                  ),
                                );
                              },
                              child: const Text("Verify"),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// -------------------------
          /// BODY
          /// -------------------------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// BASIC INFO
                  _SectionCard(
                    title: "Basic Information",
                    children: [
                      _ModernInfoRow(
                        icon: Icons.badge_outlined,
                        label: "National ID",
                        value: user.nationalId,
                      ),
                      _ModernInfoRow(
                        icon: Icons.phone,
                        label: "Phone",
                        value: user.phone,
                      ),
                      _ModernInfoRow(
                        icon: Icons.email_outlined,
                        label: "Email",
                        value: user.email ?? "—",
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// MEDICAL INFO
                  _SectionCard(
                    title: "Medical Information",
                    action: TextButton(
                      onPressed: () => _showEditMedicalDialog(context, ref),
                      child: const Text("Edit"),
                    ),
                    children: [
                      _ModernInfoRow(
                        icon: Icons.bloodtype,
                        label: "Blood Group",
                        value: user.medicalInfo.bloodGroup.isEmpty
                            ? "Not set"
                            : user.medicalInfo.bloodGroup,
                      ),
                      _ModernInfoRow(
                        icon: Icons.warning_amber,
                        label: "Allergies",
                        value: user.medicalInfo.allergies.isEmpty
                            ? "None"
                            : user.medicalInfo.allergies,
                      ),
                      _ModernInfoRow(
                        icon: Icons.health_and_safety,
                        label: "Chronic Diseases",
                        value: user.medicalInfo.chronicDiseases.isEmpty
                            ? "None"
                            : user.medicalInfo.chronicDiseases,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// SAVED LOCATIONS
                  _SectionCard(
                    title: "Saved Locations",
                    children: [
                      if (user.savedLocations.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text("No saved locations"),
                        )
                      else
                        ...user.savedLocations.map((location) {
                          return ListTile(
                            leading: const Icon(Icons.location_on),
                            title: Text(location.label),
                            subtitle: Text(location.address),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                ref
                                    .read(profileProvider.notifier)
                                    .removeLocation(location.id);
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MapPickerScreen(
                                    initialLat: location.latitude,
                                    initialLng: location.longitude,
                                    readOnly: true,
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MapPickerScreen(
                                onConfirm: (lat, lng, label, address) {
                                  ref
                                      .read(profileProvider.notifier)
                                      .addLocation(
                                        SavedLocation(
                                          id: DateTime.now()
                                              .millisecondsSinceEpoch
                                              .toString(),
                                          label: label,
                                          address: address,
                                          latitude: lat,
                                          longitude: lng,
                                        ),
                                      );
                                },
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_location_alt),
                        label: const Text("Add Location"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// LOGOUT
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        ref.read(authProvider.notifier).logout();
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// SECTION CARD

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? action;

  const _SectionCard({
    required this.title,
    required this.children,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (action != null) action!,
              ],
            ),
            const Divider(),
            ...children
          ],
        ),
      ),
    );
  }
}

/// MODERN INFO ROW

class _ModernInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ModernInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
