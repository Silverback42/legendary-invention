/// Life situations for the onboarding template picker.
enum LifeSituation {
  student,
  careerStarter,
  family,
  couple,
  individual,
}

/// A single category within a budget template.
class TemplateCategory {
  final String name;
  final String code;
  final String icon;
  final int colorValue;
  final double suggestedBudget; // EUR, 0 = no suggestion

  const TemplateCategory({
    required this.name,
    required this.code,
    required this.icon,
    required this.colorValue,
    this.suggestedBudget = 0,
  });
}

/// Budget template for a life situation.
class BudgetTemplate {
  final LifeSituation situation;
  final List<TemplateCategory> categories;

  const BudgetTemplate({
    required this.situation,
    required this.categories,
  });

  double get totalBudget =>
      categories.fold(0, (sum, c) => sum + c.suggestedBudget);
}

// ---------------------------------------------------------------------------
// Template definitions
// ---------------------------------------------------------------------------

const _groceries = TemplateCategory(
  name: 'Lebensmittel', code: 'groceries',
  icon: 'shopping_cart', colorValue: 0xFF4CAF82,
);
const _housing = TemplateCategory(
  name: 'Wohnen', code: 'housing',
  icon: 'home', colorValue: 0xFF5C6BC0,
);
const _transport = TemplateCategory(
  name: 'Transport', code: 'transport',
  icon: 'directions_car', colorValue: 0xFF26A69A,
);
const _leisure = TemplateCategory(
  name: 'Freizeit', code: 'leisure',
  icon: 'sports_soccer', colorValue: 0xFFAB47BC,
);
const _health = TemplateCategory(
  name: 'Gesundheit', code: 'health',
  icon: 'favorite', colorValue: 0xFFEF5350,
);
const _shopping = TemplateCategory(
  name: 'Shopping', code: 'shopping',
  icon: 'local_mall', colorValue: 0xFFFF7043,
);
const _dineOut = TemplateCategory(
  name: 'Essen gehen', code: 'dine_out',
  icon: 'restaurant', colorValue: 0xFFFFB300,
);
const _other = TemplateCategory(
  name: 'Sonstiges', code: 'other',
  icon: 'more_horiz', colorValue: 0xFF78909C,
);

/// All budget templates indexed by [LifeSituation].
final Map<LifeSituation, BudgetTemplate> budgetTemplates = {
  LifeSituation.student: BudgetTemplate(
    situation: LifeSituation.student,
    categories: [
      _groceries.withBudget(200),
      _housing.withBudget(400),
      _transport.withBudget(50),
      _leisure.withBudget(80),
      _health.withBudget(30),
      const TemplateCategory(
        name: 'Uni / Bildung', code: 'education',
        icon: 'school', colorValue: 0xFF42A5F5,
        suggestedBudget: 30,
      ),
      _dineOut.withBudget(50),
      _other.withBudget(60),
    ],
  ),

  LifeSituation.careerStarter: BudgetTemplate(
    situation: LifeSituation.careerStarter,
    categories: [
      _groceries.withBudget(250),
      _housing.withBudget(700),
      _transport.withBudget(100),
      _leisure.withBudget(150),
      _health.withBudget(50),
      _shopping.withBudget(100),
      _dineOut.withBudget(100),
      const TemplateCategory(
        name: 'Sparen', code: 'savings',
        icon: 'savings', colorValue: 0xFF66BB6A,
        suggestedBudget: 200,
      ),
      _other.withBudget(100),
    ],
  ),

  LifeSituation.family: BudgetTemplate(
    situation: LifeSituation.family,
    categories: [
      _groceries.withBudget(500),
      _housing.withBudget(1200),
      _transport.withBudget(200),
      const TemplateCategory(
        name: 'Kinder', code: 'children',
        icon: 'child_care', colorValue: 0xFFEC407A,
        suggestedBudget: 300,
      ),
      _health.withBudget(100),
      _shopping.withBudget(150),
      _leisure.withBudget(150),
      const TemplateCategory(
        name: 'Versicherungen', code: 'insurance',
        icon: 'shield', colorValue: 0xFF7E57C2,
        suggestedBudget: 200,
      ),
      _other.withBudget(100),
    ],
  ),

  LifeSituation.couple: BudgetTemplate(
    situation: LifeSituation.couple,
    categories: [
      _groceries.withBudget(400),
      _housing.withBudget(900),
      _transport.withBudget(150),
      _leisure.withBudget(200),
      _health.withBudget(80),
      _shopping.withBudget(150),
      _dineOut.withBudget(150),
      const TemplateCategory(
        name: 'Urlaub', code: 'vacation',
        icon: 'beach_access', colorValue: 0xFF29B6F6,
        suggestedBudget: 150,
      ),
      _other.withBudget(100),
    ],
  ),

  LifeSituation.individual: const BudgetTemplate(
    situation: LifeSituation.individual,
    categories: [
      _groceries,
      _housing,
      _transport,
      _leisure,
      _health,
      _shopping,
      _dineOut,
      _other,
    ],
  ),
};

// ---------------------------------------------------------------------------
// Helper extension
// ---------------------------------------------------------------------------

extension _WithBudget on TemplateCategory {
  TemplateCategory withBudget(double budget) => TemplateCategory(
        name: name,
        code: code,
        icon: icon,
        colorValue: colorValue,
        suggestedBudget: budget,
      );
}
