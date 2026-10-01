import '../entities/reference_entities.dart';

abstract interface class ReferenceDataRepository {
  Future<List<Pomdam>> getPomdams();
  Future<List<PomdamAlias>> getPomdamAliases();
  Future<List<ReportType>> getReportTypes();
  Future<List<ReportPeriod>> getReportPeriods();
  Future<List<PersonnelCategory>> getPersonnelCategories();
  Future<List<SimType>> getSimTypes();
  Future<List<AccidentType>> getAccidentTypes();
  Future<List<VictimOutcome>> getVictimOutcomes();
  Future<List<VehicleCategory>> getVehicleCategories();
  Future<List<MaterialDamageType>> getMaterialDamageTypes();
  Future<List<EducationStatus>> getEducationStatuses();
  Future<List<ProvosStrengthMeasure>> getProvosStrengthMeasures();
}
