class AppointmentData {
  final String id;
  late final String doctorName;
  final String appointmentDay;
  final int createdAt;
  final String status;
  final String token;
  final String doctorId;
  final String userId;
  String? patientName;


  AppointmentData({
    required this.id,
    required this.doctorName,
    required this.appointmentDay,
    required this.createdAt,
    required this.status,
    required this.token,
    required this.doctorId,
    required this.userId,
    this.patientName
  });

  factory AppointmentData.fromMap(Map<dynamic, dynamic> map, String id) {
    return AppointmentData(
      id: id,
      doctorName: map['doctorName'] ?? 'Unknown',
      appointmentDay: map['appointmentDay'] ?? 'Not specified',
      createdAt: map['createdAt'] ?? 0,
      status: map['status']?.toLowerCase() ?? 'pending',
      token: map['token'] ?? 'N/A',
      doctorId: map['doctorId'] ?? '',
      userId: map['userId'] ?? '',
      patientName: map['patientnName'] ?? ''
    );
  }

  AppointmentData copyWith({
    String? status,
  }) {
    return AppointmentData(
      id: id,
      doctorName: doctorName,
      appointmentDay: appointmentDay,
      createdAt: createdAt,
      status: status ?? this.status,
      token: token,
      doctorId: doctorId,
      userId: userId,
      patientName: patientName
    );
  }
}


class AppointmentData1 {
  final String id;
  String doctorName; // Make this mutable
  final String date;
  final String time;
  final int createdAt;
  final String status;
  final String type;
  final String fee;
  final String paymentId;
  final String doctorId;
  final String userId;
  String? patientName;
  final bool requested;
  final int requestedAt;

  AppointmentData1({
    required this.id,
    required this.doctorName,
    required this.date,
    required this.time,
    required this.createdAt,
    required this.status,
    required this.type,
    required this.fee,
    required this.paymentId,
    required this.doctorId,
    required this.userId,
    this.patientName,
    required this.requested,
    required this.requestedAt,
  });

  factory AppointmentData1.empty() {
    return AppointmentData1(
      id: '',
      userId: '',
      doctorId: '',
      doctorName: '',
      patientName: '',
      date: '',
      time: '',
      type: '',
      fee: '',
      status: '',
      paymentId: '',
      createdAt: 0,
      requested: false,
      requestedAt: 0,
    );
  }

  factory AppointmentData1.fromOnlineMap(Map<dynamic, dynamic> map, String id) {
    return AppointmentData1(
      id: id,
      doctorName: map['doctorName'] ?? 'Loading...',
      date: map['date'] ?? 'Not specified',
      time: map['time'] ?? 'Not specified',
      createdAt: map['createdAt'] ?? 0,
      status: map['status']?.toLowerCase() ?? 'pending',
      type: map['type'] ?? 'online',
      fee: map['fee']?.toString() ?? '0',
      paymentId: map['paymentId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      userId: map['userId'] ?? '',
      patientName: map['patientName'] ?? '',
      requested: map['requested'] ?? false,
      requestedAt: map['requestedAt'] ?? 0,
    );
  }

  AppointmentData1 copyWith({
    String? id,
    String? doctorName,
    String? date,
    String? time,
    dynamic createdAt,
    String? status,
    String? type,
    String? fee,
    String? paymentId,
    String? doctorId,
    String? userId,
    String? patientName,
    bool? requested,
    int? requestedAt,
  }) {
    return AppointmentData1(
      id: id ?? this.id,
      doctorName: doctorName ?? this.doctorName,
      date: date ?? this.date,
      time: time ?? this.time,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      type: type ?? this.type,
      fee: fee ?? this.fee,
      paymentId: paymentId ?? this.paymentId,
      doctorId: doctorId ?? this.doctorId,
      userId: userId ?? this.userId,
      patientName: patientName ?? this.patientName,
      requested: requested ?? this.requested,
      requestedAt: requestedAt ?? this.requestedAt,
    );
  }
}