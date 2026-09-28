import 'package:flutter_test/flutter_test.dart';
import 'package:mana_pantalu/core/repository.dart';

void main() {
  test('AppRepository calculates current crop stage correctly', () {
    final repo = AppRepository.instance;
    final userCrop = UserCrop(
      id: "test1",
      cropId: "rice",
      sowingDate: DateTime.now().subtract(const Duration(days: 30)),
      fieldSizeAcres: 2.0,
      locationText: "Guntur",
    );

    final stage = repo.getCurrentStageFor(userCrop);
    expect(stage.stageOrder, equals(2));
    expect(stage.nameEn, equals('Tillering'));
  });

  test('AppRepository contains initial master crops and diseases', () {
    final repo = AppRepository.instance;
    expect(repo.crops.length, greaterThanOrEqualTo(8));
    expect(repo.diseases.containsKey('rice_brown_spot'), isTrue);
    expect(repo.diseases.containsKey('cotton_leaf_curl'), isTrue);
    expect(repo.diseases.containsKey('tomato_early_blight'), isTrue);
  });
}
