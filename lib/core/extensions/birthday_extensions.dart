import 'package:an_ki/data/models/birthday_model.dart';

extension BirthdaySection on List<BirthdayModel> {
  Map<String, List<BirthdayModel>> toSections() {
    final Map<String, List<BirthdayModel>> sections = {};

    for (final birthday in this) {
      final String key = birthday.category.name.toUpperCase();

      sections.putIfAbsent(key, () => []);
      sections[key]!.add(birthday);
    }

    return sections;
  }
}

extension BirthdayCategoryParser on String {
  BirthdayCategory toBirthdayCategory() {
    return BirthdayCategory.values.firstWhere(
      (BirthdayCategory category) => category.name == this,
      orElse: () => BirthdayCategory.other,
    );
  }
}
