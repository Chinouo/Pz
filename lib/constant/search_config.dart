// Search Filter
// Use Hive to Store.

const List<int> staredNum = <int>[
  0,
  100,
  250,
  500,
  1000,
  5000,
  10000,
  20000,
  30000,
  50000,
];

const List<String> illustsSort = <String>[
  "date_desc",
  "date_asc",
  "popular_desc",
];

const List<String> searchTargets = [
  "partial_match_for_tags",
  "exact_match_for_tags",
  "title_and_caption",
];

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

  int? stared;

  String sort;

  String target;

  DateTime startDate;

  DateTime endDate;
}
