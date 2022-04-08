import 'package:all_in_one/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:all_in_one/constant/search_config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const double itemPickerHeight = 20;

const kMoveDuration = Duration(milliseconds: 200);

/// A PopupModalRoute to handle user change search config

class Filter extends StatefulWidget {
  const Filter({Key? key, required this.config}) : super(key: key);

  final SearchConfig config;

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  late SearchConfig config;

  @override
  void initState() {
    super.initState();
    config = SearchConfig.copyWith(widget.config);
  }

  @override
  Widget build(BuildContext context) {
    final cancelButtom = CupertinoButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: const Text("Cancel"),
    );

    final doneButtom = GestureDetector(
      onTap: () {
        Navigator.of(context).pop(config);
      },
      child: const Text("Done"),
    );

    final actions = Row(
      children: [
        cancelButtom,
        const Spacer(),
        doneButtom,
      ],
    );

    //final size = MediaQuery.of(context).size;

    final searchTargetSelector = <String, Widget>{
      searchTargets[0]:
          Center(child: Text(S.of(context).partial_match_for_tags)),
      searchTargets[1]: Center(child: Text(S.of(context).exact_match_for_tags)),
      searchTargets[2]: Center(child: Text(S.of(context).title_and_caption)),
    };

    final sortSelector = <String, Widget>{
      illustsSort[0]: Center(child: Text(S.of(context).date_desc)),
      illustsSort[1]: Center(child: Text(S.of(context).date_asc)),
      illustsSort[2]: Center(child: Text(S.of(context).popular_desc)),
    };

    final searchTargetSegment = CupertinoSlidingSegmentedControl<String>(
        children: searchTargetSelector,
        //groupValue: config.target,
        onValueChanged: (String? value) {
          debugPrint("select $value");
          config.target = value ?? searchTargets[0];
        });

    final illustsSortSegment = CupertinoSlidingSegmentedControl<String>(
        children: sortSelector,
        //groupValue: config.sort,
        onValueChanged: (String? value) {
          debugPrint("select $value");
          config.target = value ?? illustsSort[0];
        });

    final startDataPickerButtom = CupertinoButton(
        padding: EdgeInsets.all(2),
        child: Text(
            "${config.startDate.month}-${config.startDate.day}-${config.startDate.year}"),
        onPressed: () async {
          DateTime? selectorTime = await showCupertinoModalPopup<DateTime>(
              useRootNavigator: false,
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return DatePicker(
                  date: config.startDate,
                );
              });
          if (selectorTime != null) {
            setState(() {
              config.startDate = selectorTime;
            });
          }
        });

    final startDateResult = PickItems(
      children: [
        Text("start"),
        startDataPickerButtom,
      ],
    );

    final endDatePickerButtom = CupertinoButton(
        padding: EdgeInsets.all(2),
        child: Text(
            "${config.startDate.month}-${config.startDate.day}-${config.startDate.year}"),
        onPressed: () async {
          DateTime? selectorTime = await showCupertinoModalPopup<DateTime>(
              useRootNavigator: false,
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return DatePicker(
                  date: config.endDate,
                );
              });
          if (selectorTime != null) {
            setState(() {
              config.endDate = selectorTime;
            });
          }
        });

    final endDateResult = PickItems(
      children: [
        Text("end"),
        endDatePickerButtom,
      ],
    );

    return Material(
      child: SafeArea(
          top: true,
          child: SizedBox(
            height: 360,
            child: Wrap(
              runSpacing: 20,
              children: [
                actions,
                SizedBox(
                  width: 375,
                  child: searchTargetSegment,
                ),
                SizedBox(
                  width: 375,
                  child: illustsSortSegment,
                ),
                SizedBox(
                  width: 375,
                  child: startDateResult,
                ),
                SizedBox(
                  width: 375,
                  child: endDateResult,
                ),
              ],
            ),
          )),
    );
  }

  // The start to end must within one year.
  bool isVaildDate(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;

    final duration = start.difference(end);

    if (duration.inDays > 365) return false;

    return true;
  }
}

// 日期选择器
class DatePicker extends StatefulWidget {
  const DatePicker({
    Key? key,
    required this.date,
  }) : super(key: key);

  final DateTime date;
  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  late DateTime selectedData;

  @override
  void initState() {
    super.initState();
    selectedData = widget.date;
  }

  @override
  Widget build(BuildContext context) {
    final action = MaterialButton(onPressed: () {
      Navigator.of(context).pop(selectedData);
    });

    final datePicker = SizedBox(
      height: 180,
      child: CupertinoDatePicker(
        onDateTimeChanged: ((value) {
          selectedData = value;
        }),
      ),
    );

    return Material(
      child: Container(
        height: 260,
        child: Column(
          children: [
            action,
            datePicker,
          ],
        ),
      ),
    );
  }
}

class PickItems extends StatelessWidget {
  const PickItems({
    Key? key,
    required this.children,
  }) : super(key: key);

  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      decoration: const BoxDecoration(
          border: Border(
        top: BorderSide(width: 0, color: CupertinoColors.inactiveGray),
        bottom: BorderSide(width: 0, color: CupertinoColors.inactiveGray),
      )),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ),
      ),
    );
  }
}
