import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/widgets/add_update_option_cards.dart';

class ProjectPhaseUpdate {
  const ProjectPhaseUpdate({
    required this.id,
    required this.stage,
    required this.assignedTeam,
    required this.startDate,
    required this.dueDate,
    required this.progress,
    required this.status,
    required this.updatedAt,
  });

  final String id;
  final String stage;
  final String assignedTeam;
  final DateTime? startDate;
  final DateTime? dueDate;
  final int progress;
  final String status;
  final DateTime updatedAt;

  ProjectPhaseUpdate copyWith({
    String? stage,
    String? assignedTeam,
    DateTime? startDate,
    DateTime? dueDate,
    int? progress,
    String? status,
    DateTime? updatedAt,
  }) {
    return ProjectPhaseUpdate(
      id: id,
      stage: stage ?? this.stage,
      assignedTeam: assignedTeam ?? this.assignedTeam,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MediaUpdate {
  const MediaUpdate({
    required this.id,
    required this.type,
    required this.description,
    required this.updatedAt,
  });

  final String id;
  final AddUpdateOptionType type;
  final String description;
  final DateTime updatedAt;

  MediaUpdate copyWith({
    String? description,
    DateTime? updatedAt,
  }) {
    return MediaUpdate(
      id: id,
      type: type,
      description: description ?? this.description,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class SavedUpdateEntry {
  SavedUpdateEntry.projectPhase(this.projectPhase)
      : media = null,
        type = AddUpdateOptionType.projectPhase;

  SavedUpdateEntry.media(this.media)
      : projectPhase = null,
        type = media!.type;

  final AddUpdateOptionType type;
  final ProjectPhaseUpdate? projectPhase;
  final MediaUpdate? media;

  String get id => projectPhase?.id ?? media!.id;

  String get title {
    if (projectPhase != null) {
      return projectPhase!.stage;
    }
    final description = media!.description.trim();
    if (description.isEmpty) {
      return type == AddUpdateOptionType.statusStories
          ? 'Status & Stories update'
          : 'Construction media update';
    }
    if (description.length <= 48) return description;
    return '${description.substring(0, 48)}...';
  }

  String get subtitle {
    if (projectPhase != null) {
      final phase = projectPhase!;
      return '${phase.assignedTeam} • ${phase.progress}% • ${phase.status}';
    }
    return type == AddUpdateOptionType.statusStories
        ? 'Status & Stories'
        : 'Construction Photos & Videos';
  }

  DateTime get updatedAt =>
      projectPhase?.updatedAt ?? media!.updatedAt;
}
