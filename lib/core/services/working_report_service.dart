import 'package:flutter/material.dart';
import 'package:flutterbasesource/core/models/working_report_main.dart';

class WorkingReportService with ChangeNotifier {
  WorkingReportMain _workingReportMain;

  WorkingReportMain get workingReportMain => _workingReportMain;

  addWorkingReport(WorkingReportMain data) {
    _workingReportMain = data;
    notifyListeners();
  }
}
