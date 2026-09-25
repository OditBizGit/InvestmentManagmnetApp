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
    this.stageId,
    this.description = '',
  });

  final String id;
  final int? stageId;
  final String stage;
  final String assignedTeam;
  final DateTime? startDate;
  final DateTime? dueDate;
  final int progress;
  final String status;
  final String description;
  final DateTime updatedAt;

  ProjectPhaseUpdate copyWith({
    int? stageId,
    String? stage,
    String? assignedTeam,
    DateTime? startDate,
    DateTime? dueDate,
    int? progress,
    String? status,
    String? description,
    DateTime? updatedAt,
  }) {
    return ProjectPhaseUpdate(
      id: id,
      stageId: stageId ?? this.stageId,
      stage: stage ?? this.stage,
      assignedTeam: assignedTeam ?? this.assignedTeam,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      description: description ?? this.description,
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
      return switch (type) {
        AddUpdateOptionType.statusStories => 'Status & Stories update',
        AddUpdateOptionType.constructionMedia => 'Construction media update',
        AddUpdateOptionType.banner => 'Banner update',
        AddUpdateOptionType.projectPhase => 'Project phase update',
      };
    }
    if (description.length <= 48) return description;
    return '${description.substring(0, 48)}...';
  }

  String get subtitle {
    if (projectPhase != null) {
      final phase = projectPhase!;
      return '${phase.assignedTeam} • ${phase.progress}% • ${phase.status}';
    }
    return switch (type) {
      AddUpdateOptionType.statusStories => 'Status & Stories',
      AddUpdateOptionType.constructionMedia => 'Construction Photos & Videos',
      AddUpdateOptionType.banner => 'Banner',
      AddUpdateOptionType.projectPhase => 'Project Phase',
    };
  }

  DateTime get updatedAt =>
      projectPhase?.updatedAt ?? media!.updatedAt;
}
