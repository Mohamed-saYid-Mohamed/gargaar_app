enum IncidentType {
  accident,
  fire,
  crime,
}

extension IncidentTypeX on IncidentType {
  String get name {
    switch (this) {
      case IncidentType.accident:
        return 'Accident';
      case IncidentType.fire:
        return 'Fire';
      case IncidentType.crime:
        return 'Crime';
    }
  }

  String get icon {
    switch (this) {
      case IncidentType.accident:
        return '🚗';
      case IncidentType.fire:
        return '🔥';
      case IncidentType.crime:
        return '🚨';
    }
  }
}
