import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/db/database.dart';

/// Referral-Screen – Phase 1.5.
/// Einladungs-Link generieren und teilen.
class ReferralScreen extends ConsumerStatefulWidget {
  const ReferralScreen({super.key});

  @override
  ConsumerState<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends ConsumerState<ReferralScreen> {
  Referral? _referral;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrCreateReferral();
  }

  Future<void> _loadOrCreateReferral() async {
    final db = ref.read(databaseProvider);
    var referral = await db.getMyReferral();

    if (referral == null) {
      final code = _generateCode();
      final id = await db.insertReferral(ReferralsCompanion(
        referralCode: Value(code),
      ));
      referral = await (db.select(db.referrals)..where((r) => r.id.equals(id))).getSingle();
    }

    if (mounted) {
      setState(() {
        _referral = referral;
        _loading = false;
      });
    }
  }

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(8, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  String _referralLink() {
    final code = _referral?.referralCode;
    if (code == null || code.isEmpty) return '';
    return 'https://schlicht.app/invite/$code';
  }

  Future<void> _share() async {
    final link = _referralLink();
    if (link.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    await Share.share(
      '${l10n.referralShareText}\n\n$link',
      subject: l10n.referralShareSubject,
    );
  }

  void _copy() {
    final link = _referralLink();
    if (link.isEmpty) return;
    Clipboard.setData(ClipboardData(text: link));
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.referralCopied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.referralTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Icon(
                    Icons.card_giftcard_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.referralHeadline,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.referralDescription,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Code-Anzeige
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _referral?.referralCode ?? '',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                letterSpacing: 3,
                              ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: _copy,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Statistik
                  if (_referral != null && _referral!.successfulCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        l10n.referralSuccessCount(_referral!.successfulCount),
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const Spacer(),

                  // Teilen-Button
                  ElevatedButton.icon(
                    onPressed: _share,
                    icon: const Icon(Icons.share_outlined),
                    label: Text(l10n.referralShareButton),
                  ),
                ],
              ),
            ),
    );
  }
}
