part of 'store_boxes.dart';

@HiveType(typeId: HiveTypeIds.searchConfig)
class SearchConfig {
  SearchConfig({
    required this.stared,
    required this.sort,
    required this.target,
    required this.startDate,
    required this.endDate,
  });

  // Today to One Week Ago
  SearchConfig.defaultConfig()
      : stared = staredNum[0],
        sort = illustsSort[0],
        target = searchTargets[0],
        startDate = DateTime.now(),
        endDate = DateTime.now().add(const Duration(days: -7));

  SearchConfig.copyWith(SearchConfig config)
      : stared = config.stared,
        sort = config.sort,
        target = config.target,
        startDate = config.startDate,
        endDate = config.endDate;

  @HiveField(0)
  int? stared;

  @HiveField(1)
  String sort;

  @HiveField(2)
  String target;

  @HiveField(3)
  DateTime startDate;

  @HiveField(4)
  DateTime endDate;
}
