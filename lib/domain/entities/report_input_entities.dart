import 'reference_entities.dart';

final class GakkumInputOption {
  const GakkumInputOption({
    required this.versionId,
    required this.code,
    required this.name,
    required this.displayOrder,
  });

  final String versionId;
  final String code;
  final String name;
  final int displayOrder;
}

final class ViolationInputOption {
  const ViolationInputOption({
    required this.versionId,
    required this.code,
    required this.name,
    required this.category,
    required this.displayOrder,
  });

  final String versionId;
  final String code;
  final String name;
  final String category;
  final int displayOrder;
}

final class CriminalOffenseInputOption {
  const CriminalOffenseInputOption({
    required this.versionId,
    required this.sourceNumber,
    required this.name,
    required this.displayOrder,
  });

  final String versionId;
  final int sourceNumber;
  final String name;
  final int displayOrder;
}

final class ReportInputCatalog {
  const ReportInputCatalog({
    required this.pomdams,
    required this.periods,
    required this.personnelCategories,
    required this.simTypes,
    required this.accidentTypes,
    required this.victimOutcomes,
    required this.vehicleCategories,
    required this.materialDamageTypes,
    required this.educationStatuses,
    required this.provosStrengthMeasures,
    required this.gakkum,
    required this.violations,
    required this.criminalOffenses,
  });

  final List<Pomdam> pomdams;
  final List<ReportPeriod> periods;
  final List<PersonnelCategory> personnelCategories;
  final List<SimType> simTypes;
  final List<AccidentType> accidentTypes;
  final List<VictimOutcome> victimOutcomes;
  final List<VehicleCategory> vehicleCategories;
  final List<MaterialDamageType> materialDamageTypes;
  final List<EducationStatus> educationStatuses;
  final List<ProvosStrengthMeasure> provosStrengthMeasures;
  final List<GakkumInputOption> gakkum;
  final List<ViolationInputOption> violations;
  final List<CriminalOffenseInputOption> criminalOffenses;
}

final class ReportInputSubmission {
  const ReportInputSubmission({
    required this.status,
    required this.submissionId,
    required this.reportType,
    required this.periodId,
    required this.pomdamId,
  });

  final String status;
  final String submissionId;
  final String reportType;
  final String periodId;
  final String pomdamId;

  factory ReportInputSubmission.fromMap(Map<String, dynamic> map) {
    return ReportInputSubmission(
      status: map['status'] as String? ?? '',
      submissionId: map['submission_id'] as String? ?? '',
      reportType: map['report_type'] as String? ?? '',
      periodId: map['period_id'] as String? ?? '',
      pomdamId: map['pomdam_id'] as String? ?? '',
    );
  }
}
