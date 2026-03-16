import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../data/budget_templates.dart';

/// Onboarding screen 2/3: choose your life situation.
class LifeSituationScreen extends StatelessWidget {
  const LifeSituationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final options = [
      _SituationOption(
        icon: Icons.school,
        color: const Color(0xFF42A5F5),
        label: l10n.lifeSituationStudent,
        situation: LifeSituation.student,
      ),
      _SituationOption(
        icon: Icons.work,
        color: const Color(0xFF66BB6A),
        label: l10n.lifeSituationCareerStarter,
        situation: LifeSituation.careerStarter,
      ),
      _SituationOption(
        icon: Icons.family_restroom,
        color: const Color(0xFFEC407A),
        label: l10n.lifeSituationFamily,
        situation: LifeSituation.family,
      ),
      _SituationOption(
        icon: Icons.favorite,
        color: const Color(0xFFEF5350),
        label: l10n.lifeSituationCouple,
        situation: LifeSituation.couple,
      ),
      _SituationOption(
        icon: Icons.person,
        color: const Color(0xFF78909C),
        label: l10n.lifeSituationIndividual,
        situation: LifeSituation.individual,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.lifeSituationTitle,
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.lifeSituationSubtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final opt = options[index];
                    return _SituationCard(
                      option: opt,
                      onTap: () => context.go(
                        AppRoutes.onboardingCustomize,
                        extra: opt.situation.index,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SituationOption {
  final IconData icon;
  final Color color;
  final String label;
  final LifeSituation situation;

  const _SituationOption({
    required this.icon,
    required this.color,
    required this.label,
    required this.situation,
  });
}

class _SituationCard extends StatelessWidget {
  final _SituationOption option;
  final VoidCallback onTap;

  const _SituationCard({required this.option, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: option.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(option.icon, color: option.color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option.label,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color:
                    theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
