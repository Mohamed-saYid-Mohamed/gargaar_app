enum ReportStatus {
  pending,
  submitted,
  responding,
  resolved,
  cancelled,
}

extension ReportStatusX on ReportStatus {
  String get label {
    switch (this) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.submitted:
        return 'Submitted';
      case ReportStatus.responding:
        return 'Responding';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get stepIndex {
    switch (this) {
      case ReportStatus.pending:
        return 0;
      case ReportStatus.submitted:
        return 1;
      case ReportStatus.responding:
        return 2;
      case ReportStatus.resolved:
        return 3;
      case ReportStatus.cancelled:
        return 4;
    }
  }
}
