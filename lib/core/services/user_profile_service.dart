import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:diplomka/core/models/app_user.dart';
import 'package:diplomka/core/services/auth_service.dart';
import 'package:diplomka/core/services/firebase_bootstrap.dart';
import 'package:diplomka/register/logo_page.dart';

class UserProfileService {
  UserProfileService._();
  static final UserProfileService instance = UserProfileService._();

  AppUser? _cached;

  AppUser? get current => _cached;

  void cacheUser(AppUser user) => _cached = user;

  Future<AppUser?> load() async {
    if (!FirebaseBootstrap.isReady) {
      await FirebaseBootstrap.initialize();
    }
    if (!FirebaseBootstrap.isReady) return null;

    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      _cached = null;
      return null;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(authUser.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        _cached = AppUser.fromFirestore(authUser.uid, doc.data()!);
      } else {
        _cached = AppUser(
          uid: authUser.uid,
          fullName: authUser.displayName ?? authUser.email?.split('@').first ?? 'User',
          email: authUser.email ?? '',
          phone: '',
        );
      }
      return _cached;
    } catch (e) {
      debugPrint('[Profile] load failed: $e');
      _cached = AppUser(
        uid: authUser.uid,
        fullName: authUser.displayName ?? 'User',
        email: authUser.email ?? '',
        phone: '',
      );
      return _cached;
    }
  }

  Future<void> save(AppUser profile) async {
    if (!FirebaseBootstrap.isReady) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(profile.uid)
        .set(profile.toFirestore(), SetOptions(merge: true));
    _cached = profile;
    await FirebaseAuth.instance.currentUser?.updateDisplayName(profile.fullName);
  }

  void clear() => _cached = null;

  Future<void> logout(BuildContext context) async {
    await AuthService.instance.signOut();
    clear();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LogoPage()),
        (_) => false,
      );
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    await AuthService.instance.deleteAccount();
    clear();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LogoPage()),
        (_) => false,
      );
    }
  }
}
