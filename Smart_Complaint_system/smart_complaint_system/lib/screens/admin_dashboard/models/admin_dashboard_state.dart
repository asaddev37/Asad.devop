class AdminDashboardState {
  final bool isLoading;
  final String? errorMessage;
  final List<Map<String, dynamic>> batches;
  final List<Map<String, dynamic>> advisors;
  final List<Map<String, dynamic>> students;
  final List<Map<String, dynamic>> complaints;
  final Map<String, dynamic>? hodProfile;
  final Map<String, dynamic>? adminProfile;
  final int totalUsers;
  final int totalComplaints;
  final int resolvedComplaints;
  final double resolutionRate;
  final Map<String, int> statistics;
  final Map<String, dynamic>? hod;
  final List<Map<String, dynamic>> batchAdvisors;
  final Map<String, dynamic>? currentDepartment;

  const AdminDashboardState({
    this.isLoading = false,
    this.errorMessage,
    this.batches = const [],
    this.advisors = const [],
    this.students = const [],
    this.complaints = const [],
    this.hodProfile,
    this.adminProfile,
    this.totalUsers = 0,
    this.totalComplaints = 0,
    this.resolvedComplaints = 0,
    this.resolutionRate = 0.0,
    this.statistics = const {},
    this.hod,
    this.batchAdvisors = const [],
    this.currentDepartment,
  });

  factory AdminDashboardState.initial() {
    return const AdminDashboardState();
  }

  AdminDashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Map<String, dynamic>>? batches,
    List<Map<String, dynamic>>? advisors,
    List<Map<String, dynamic>>? students,
    List<Map<String, dynamic>>? complaints,
    Map<String, dynamic>? hodProfile,
    Map<String, dynamic>? adminProfile,
    int? totalUsers,
    int? totalComplaints,
    int? resolvedComplaints,
    double? resolutionRate,
    Map<String, int>? statistics,
    Map<String, dynamic>? hod,
    List<Map<String, dynamic>>? batchAdvisors,
    Map<String, dynamic>? currentDepartment,
  }) {
    return AdminDashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      batches: batches ?? this.batches,
      advisors: advisors ?? this.advisors,
      students: students ?? this.students,
      complaints: complaints ?? this.complaints,
      hodProfile: hodProfile ?? this.hodProfile,
      adminProfile: adminProfile ?? this.adminProfile,
      totalUsers: totalUsers ?? this.totalUsers,
      totalComplaints: totalComplaints ?? this.totalComplaints,
      resolvedComplaints: resolvedComplaints ?? this.resolvedComplaints,
      resolutionRate: resolutionRate ?? this.resolutionRate,
      statistics: statistics ?? this.statistics,
      hod: hod ?? this.hod,
      batchAdvisors: batchAdvisors ?? this.batchAdvisors,
      currentDepartment: currentDepartment ?? this.currentDepartment,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminDashboardState &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        other.batches == batches &&
        other.advisors == advisors &&
        other.students == students &&
        other.complaints == complaints &&
        other.hodProfile == hodProfile &&
        other.adminProfile == adminProfile &&
        other.totalUsers == totalUsers &&
        other.totalComplaints == totalComplaints &&
        other.resolvedComplaints == resolvedComplaints &&
        other.resolutionRate == resolutionRate &&
        other.statistics == statistics &&
        other.hod == hod &&
        other.batchAdvisors == batchAdvisors &&
        other.currentDepartment == currentDepartment;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^
        errorMessage.hashCode ^
        batches.hashCode ^
        advisors.hashCode ^
        students.hashCode ^
        complaints.hashCode ^
        hodProfile.hashCode ^
        adminProfile.hashCode ^
        totalUsers.hashCode ^
        totalComplaints.hashCode ^
        resolvedComplaints.hashCode ^
        resolutionRate.hashCode ^
        statistics.hashCode ^
        hod.hashCode ^
        batchAdvisors.hashCode ^
        currentDepartment.hashCode;
  }
}
