import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'register_patient.dart';
import 'registered_patients.dart';
import 'request_details.dart';
import 'register_nurse.dart';
import 'registered_nurses.dart';

const Color stationTeal = Color(0xFF1B8B7F);
const Color stationDark = Color(0xFF08756F);
const Color stationBg = Color(0xFFF1FAF9);
const Color stationText = Color(0xFF173F57);

enum StationSection {
  dashboard,
  callQueue,
  pendingRequests,
  activeRequests,
  completedRequests,
  roomStatus,
  reports,
  registerPatient,
  createNurse,
  registeredPatients,
  registeredNurses,
  settings,
}

class StationHomePage extends StatefulWidget {
  const StationHomePage({super.key});

  @override
  State<StationHomePage> createState() => _StationHomePageState();
}

class _StationHomePageState extends State<StationHomePage> {
  StationSection selectedSection = StationSection.dashboard;

  String get pageTitle {
    switch (selectedSection) {
      case StationSection.dashboard:
        return 'Dashboard';
      case StationSection.callQueue:
        return 'Call Queue';
      case StationSection.pendingRequests:
        return 'Pending Requests';
      case StationSection.activeRequests:
        return 'Active Requests';
      case StationSection.completedRequests:
        return 'Completed Requests';
      case StationSection.roomStatus:
        return 'Room Status';
      case StationSection.reports:
        return 'Reports';
      case StationSection.registerPatient:
        return 'Register Patient';
      case StationSection.createNurse:
        return 'Create Nurse Account';
      case StationSection.registeredPatients:
        return 'Registered Patients';
      case StationSection.registeredNurses:
        return 'Registered Nurses';
      case StationSection.settings:
        return 'Settings';
    }
  }

  void openSection(StationSection section) {
    setState(() => selectedSection = section);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: stationBg,
      body: Row(
        children: [
          // LEFT SIDEBAR

          Container(
            width: 225,
            color: stationDark,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ROOMCALL HEADER
                  const Padding(
                    padding: EdgeInsets.fromLTRB(18, 24, 12, 28),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_hospital_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'RoomCall',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'MAIN STATION',
                                style: TextStyle(
                                  color: Color(0xFFB6F1E9),
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // SCROLLABLE NAVIGATION
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _navItem(
                            icon: Icons.dashboard_rounded,
                            label: 'Dashboard',
                            section: StationSection.dashboard,
                          ),
                          _navItem(
                            icon: Icons.notifications_active_rounded,
                            label: 'Call Queue',
                            section: StationSection.callQueue,
                          ),
                          _navItem(
                            icon: Icons.bed_rounded,
                            label: 'Room Status',
                            section: StationSection.roomStatus,
                          ),
                          _navItem(
                            icon: Icons.bar_chart_rounded,
                            label: 'Reports',
                            section: StationSection.reports,
                          ),

                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 22, 12, 10),
                            child: Text(
                              'PATIENT & STAFF',
                              style: TextStyle(
                                color: Color(0xFFB6F1E9),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),

                          _navItem(
                            icon: Icons.person_add_alt_1_rounded,
                            label: 'Register Patient',
                            section: StationSection.registerPatient,
                          ),
                          _navItem(
                            icon: Icons.medical_services_rounded,
                            label: 'Create Nurse Account',
                            section: StationSection.createNurse,
                          ),
                          _navItem(
                            icon: Icons.people_alt_rounded,
                            label: 'Registered Patients',
                            section: StationSection.registeredPatients,
                          ),
                          _navItem(
                            icon: Icons.medical_services_rounded,
                            label: 'Registered Nurses',
                            section: StationSection.registeredNurses,
                          ),
                          _navItem(
                            icon: Icons.settings_rounded,
                            label: 'Settings',
                            section: StationSection.settings,
                          ),

                          const Padding(
                            padding: EdgeInsets.all(18),
                            child: Text(
                              'RoomCall • Station',
                              style: TextStyle(
                                color: Color(0xFFB6F1E9),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),


          // RIGHT CONTENT AREA
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 66,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFE4EEEE),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (selectedSection != StationSection.dashboard) ...[
                        IconButton(
                          tooltip: 'Back to Dashboard',
                          onPressed: () => openSection(StationSection.dashboard),
                          icon: const Icon(Icons.arrow_back_rounded, color: stationTeal),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          pageTitle,
                          style: const TextStyle(
                            color: stationText,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Open Call Queue',
                        onPressed: () =>
                            openSection(StationSection.callQueue),
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: stationTeal,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const CircleAvatar(
                        backgroundColor: Color(0xFFD9F1ED),
                        child: Icon(
                          Icons.person_rounded,
                          color: stationTeal,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Station Admin',
                        style: TextStyle(
                          color: stationText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: StreamBuilder<
                      QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('requests')
                        .orderBy(
                      'createdAt',
                      descending: true,
                    )
                        .snapshots(),
                    builder: (context, requestSnapshot) {
                      if (requestSnapshot.hasError) {
                        return _errorView(
                          'Unable to load requests. '
                              'Check your Firestore connection.',
                        );
                      }

                      if (requestSnapshot.connectionState ==
                          ConnectionState.waiting &&
                          !requestSnapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: stationTeal,
                          ),
                        );
                      }

                      final requests =
                          requestSnapshot.data?.docs ?? [];

                      return StreamBuilder<
                          QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('patients')
                            .snapshots(),
                        builder: (context, patientSnapshot) {
                          if (patientSnapshot.hasError) {
                            return _errorView(
                              'Unable to load patient information.',
                            );
                          }

                          final patients =
                              patientSnapshot.data?.docs ?? [];

                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: _buildPage(
                              requests: requests,
                              patients: patients,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required StationSection section,
  }) {
    final selected = selectedSection == section;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 3,
      ),
      child: Material(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => openSection(section),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 12,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: selected ? stationTeal : Colors.white,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? stationTeal : Colors.white,
                      fontSize: 12,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>>
    requests,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>>
    patients,
  }) {
    switch (selectedSection) {
      case StationSection.dashboard:
        return _dashboard(requests, patients);

      case StationSection.callQueue:
        return _callQueue(requests);

      case StationSection.pendingRequests:
        return _requestStatusPage(requests, 'PENDING', 'Pending Requests');

      case StationSection.activeRequests:
        return _requestStatusPage(requests, 'ACTIVE', 'Active Requests');

      case StationSection.completedRequests:
        return _requestStatusPage(requests, 'COMPLETED', 'Completed Requests');

      case StationSection.roomStatus:
        return _roomStatus(requests, patients);

      case StationSection.reports:
        return _reports(requests, patients);

      case StationSection.registerPatient:
        return _managementPanel(
          title: 'Register New Patient',
          description:
          'Add a patient and assign their room and bed.',
          icon: Icons.person_add_alt_1_rounded,
          buttonLabel: 'Open Patient Registration',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RegisterPatientPage(),
            ),
          ),
        );

      case StationSection.createNurse:
        return _managementPanel(
          title: 'Create Nurse Account',
          description:
          'Open the existing nurse account registration page.',
          icon: Icons.medical_services_rounded,
          buttonLabel: 'Open Nurse Registration',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RegisterNursePage(),
            ),
          ),
        );

      case StationSection.registeredPatients:
        return _managementPanel(
          title: 'Registered Patients',
          description:
          'View the patient records already registered in RoomCall.',
          icon: Icons.people_alt_rounded,
          buttonLabel: 'View Registered Patients',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RegisteredPatientsPage(),
            ),
          ),
        );

      case StationSection.registeredNurses:
        return _managementPanel(
          title: 'Registered Nurses',
          description:
          'View nurse names, Nurse IDs, emails, and account status.',
          icon: Icons.medical_services_rounded,
          buttonLabel: 'View Registered Nurses',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RegisteredNursesPage(),
            ),
          ),
        );

      case StationSection.settings:
        return _settings();
    }
  }

  // DASHBOARD
  Widget _dashboard(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> requests,
      List<QueryDocumentSnapshot<Map<String, dynamic>>> patients,
      ) {
    final pending = requests
        .where((r) => r.data()['status'] == 'PENDING')
        .toList();

    final active = requests.where((r) {
      final status = r.data()['status'];
      return status == 'ACKNOWLEDGED' ||
          status == 'RESPONDING';
    }).toList();

    final completed = requests
        .where((r) => r.data()['status'] == 'COMPLETED')
        .toList();

    final current = requests.where((r) {
      final status = r.data()['status'];
      return status == 'PENDING' ||
          status == 'ACKNOWLEDGED' ||
          status == 'RESPONDING';
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome to RoomCall',
          style: TextStyle(
            color: stationText,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Monitor patient assistance requests.',
          style: TextStyle(color: Colors.blueGrey),
        ),
        const SizedBox(height: 24),

        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900
                ? 4
                : constraints.maxWidth >= 520
                ? 2
                : 1;

            final width = (constraints.maxWidth -
                (columns - 1) * 14) /
                columns;

            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                SizedBox(
                  width: width,
                  child: _statCard(
                    'Patients',
                    patients.length,
                    Icons.bed_rounded,
                    stationTeal,
                    onTap: () => openSection(
                      StationSection.registeredPatients,
                    ),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _statCard(
                    'Pending',
                    pending.length,
                    Icons.notifications_active_rounded,
                    const Color(0xFFF59E0B),
                    onTap: () =>
                        openSection(StationSection.pendingRequests),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _statCard(
                    'Active',
                    active.length,
                    Icons.medical_services_rounded,
                    const Color(0xFF2196F3),
                    onTap: () =>
                        openSection(StationSection.activeRequests),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _statCard(
                    'Completed',
                    completed.length,
                    Icons.check_circle_rounded,
                    const Color(0xFF159B70),
                    onTap: () =>
                        openSection(StationSection.completedRequests),
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 24),

        LayoutBuilder(
          builder: (context, constraints) {
            final panels = constraints.maxWidth < 650
                ? Column(
              children: [
                _currentRequests(current),
                const SizedBox(height: 18),
                _roomSummary(requests, patients),
              ],
            )

                : IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _currentRequests(current),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _roomSummary(requests, patients),
                  ),
                ],
              ),
            );


            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                panels,
                const SizedBox(height: 18),
                _recentActivity(requests),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _statCard(
      String title,
      int value,
      IconData icon,
      Color color, {
        VoidCallback? onTap,
      }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0xFFDCEDEC)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$value',
                      style: TextStyle(
                        color: color,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        color: stationText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panel({
    required String title,
    required Widget child,
    VoidCallback? onViewAll,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFDCEDEC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: stationText,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text(
                      'View All  ›',
                      style: TextStyle(color: stationTeal),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE7EEEE)),
          child,
        ],
      ),
    );
  }

  Widget _currentRequests(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> requests,
      ) {
    final visible = requests.take(6).toList();

    return _panel(
      title: 'Current Requests',
      onViewAll: () => openSection(StationSection.callQueue),
      child: visible.isEmpty
          ? const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No current requests.',
            style: TextStyle(color: Colors.blueGrey),
          ),
        ),
      )
          : Column(
        children: visible.map((request) {
          final data = request.data();
          final type =
          (data['requestType'] ?? 'UNKNOWN').toString();
          final status =
          (data['status'] ?? 'UNKNOWN').toString();

          return ListTile(
            onTap: () => _openDetails(request),
            leading: Icon(
              type == 'EMERGENCY'
                  ? Icons.emergency_rounded
                  : Icons.notifications_active_rounded,
              color: _requestColor(type),
            ),
            title: Text(
              type,
              style: const TextStyle(
                color: stationText,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${_roomText(data)}\n$status',
            ),
            isThreeLine: true,
            trailing: const Icon(
              Icons.chevron_right_rounded,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _roomSummary(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> requests,
      List<QueryDocumentSnapshot<Map<String, dynamic>>> patients,
      ) {
    final roomNames = <String>{};

    for (final patient in patients) {
      final room =
      (patient.data()['room'] ?? '').toString().trim();
      if (room.isNotEmpty) roomNames.add(room);
    }

    final rooms = roomNames.toList()..sort();

    return _panel(
      title: 'Room Status',
      onViewAll: () => openSection(StationSection.roomStatus),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: rooms.isEmpty
            ? const Text(
          'No registered room information yet.',
          style: TextStyle(color: Colors.blueGrey),
        )
            : Wrap(
          spacing: 10,
          runSpacing: 10,
          children: rooms.take(8).map((room) {
            final openCalls = requests.where((r) {
              final data = r.data();
              final status = data['status'];

              return (data['room'] ?? '').toString() == room &&
                  (status == 'PENDING' ||
                      status == 'ACKNOWLEDGED' ||
                      status == 'RESPONDING');
            }).toList();

            final emergency = openCalls.any(
                  (r) =>
              r.data()['requestType'] == 'EMERGENCY',
            );

            final color = openCalls.isEmpty
                ? const Color(0xFF159B70)
                : emergency
                ? const Color(0xFFFF5252)
                : const Color(0xFFF59E0B);

            final label = openCalls.isEmpty
                ? 'Clear'
                : emergency
                ? 'Emergency'
                : 'Active Call';

            return Container(
              width: 85,
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    room,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _recentActivity(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> requests,
      ) {
    final recent = requests.take(5).toList();

    return _panel(
      title: 'Recent Activity',
      child: recent.isEmpty
          ? const Padding(
        padding: EdgeInsets.all(20),
        child: Text('No recent activity.'),
      )
          : Column(
        children: recent.map((request) {
          final data = request.data();
          final type =
          (data['requestType'] ?? 'Request').toString();
          final status =
          (data['status'] ?? 'UNKNOWN').toString();

          return ListTile(
            dense: true,
            leading: Icon(
              Icons.circle,
              size: 12,
              color: _requestColor(type),
            ),
            title: Text(
              '$type • ${_roomText(data)}',
              style: const TextStyle(
                color: stationText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              status,
              style: const TextStyle(fontSize: 11),
            ),
            onTap: () => _openDetails(request),
          );
        }).toList(),
      ),
    );
  }

  // INDIVIDUAL REQUEST STATUS PAGES
  Widget _requestStatusPage(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> requests,
      String filter,
      String title,
      ) {
    final filtered = requests.where((request) {
      final status = (request.data()['status'] ?? '').toString();
      if (filter == 'ACTIVE') {
        return status == 'ACKNOWLEDGED' || status == 'RESPONDING';
      }
      return status == filter;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(
          color: stationText, fontSize: 24, fontWeight: FontWeight.bold,
        )),
        const SizedBox(height: 6),
        const Text('Select a request to view its details.',
            style: TextStyle(color: Colors.blueGrey)),
        const SizedBox(height: 22),
        _panel(
          title: '$title (${filtered.length})',
          child: filtered.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(28),
            child: Center(child: Text('No requests in this category.')),
          )
              : Column(
            children: filtered.map((request) {
              final data = request.data();
              final type = (data['requestType'] ?? 'UNKNOWN').toString();
              final status = (data['status'] ?? 'UNKNOWN').toString();
              return ListTile(
                leading: Icon(
                  status == 'COMPLETED'
                      ? Icons.check_circle_rounded
                      : type == 'EMERGENCY'
                      ? Icons.emergency_rounded
                      : Icons.notifications_active_rounded,
                  color: _requestColor(type),
                ),
                title: Text(type, style: const TextStyle(
                  color: stationText, fontWeight: FontWeight.bold,
                )),
                subtitle: Text('${_roomText(data)}\nStatus: $status'),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _openDetails(request),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // CALL QUEUE
  Widget _callQueue(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> requests,
      ) {
    final open = requests.where((r) {
      final status = r.data()['status'];
      return status == 'PENDING' ||
          status == 'ACKNOWLEDGED' ||
          status == 'RESPONDING';
    }).toList();

    final completed = requests
        .where((r) => r.data()['status'] == 'COMPLETED')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Patient Call Queue',
          style: TextStyle(
            color: stationText,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'View current and completed assistance requests.',
          style: TextStyle(color: Colors.blueGrey),
        ),
        const SizedBox(height: 22),

        _panel(
          title: 'Open Requests (${open.length})',
          child: open.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(28),
            child: Center(child: Text('No open requests.')),
          )
              : Column(
            children: open.map((request) {
              final data = request.data();
              final type =
              (data['requestType'] ?? 'UNKNOWN').toString();
              final status =
              (data['status'] ?? 'UNKNOWN').toString();

              return ListTile(
                leading: Icon(
                  type == 'EMERGENCY'
                      ? Icons.emergency_rounded
                      : Icons.notifications_active_rounded,
                  color: _requestColor(type),
                ),
                title: Text(
                  type,
                  style: const TextStyle(
                    color: stationText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${_roomText(data)}\nStatus: $status',
                ),
                isThreeLine: true,
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                ),
                onTap: () => _openDetails(request),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 22),

        _panel(
          title: 'Completed Requests (${completed.length})',
          child: completed.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(22),
            child: Text('No completed requests yet.'),
          )
              : Column(
            children: completed.take(15).map((request) {
              final data = request.data();

              return ListTile(
                leading: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF159B70),
                ),
                title: Text(
                  (data['requestType'] ?? 'UNKNOWN').toString(),
                ),
                subtitle: Text(_roomText(data)),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                ),
                onTap: () => _openDetails(request),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ROOM STATUS
  Widget _roomStatus(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> requests,
      List<QueryDocumentSnapshot<Map<String, dynamic>>> patients,
      ) {
    final roomNames = <String>{};

    for (final patient in patients) {
      final room =
      (patient.data()['room'] ?? '').toString().trim();
      if (room.isNotEmpty) roomNames.add(room);
    }

    for (final request in requests) {
      final room =
      (request.data()['room'] ?? '').toString().trim();
      if (room.isNotEmpty) roomNames.add(room);
    }

    final rooms = roomNames.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Room Status',
          style: TextStyle(
            color: stationText,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Room activity based on patient records and open requests.',
          style: TextStyle(color: Colors.blueGrey),
        ),
        const SizedBox(height: 24),

        if (rooms.isEmpty)
          const Text('No room information available.')
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900
                  ? 4
                  : constraints.maxWidth >= 560
                  ? 3
                  : 2;

              final width = (constraints.maxWidth -
                  (columns - 1) * 14) /
                  columns;

              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: rooms.map((room) {
                  final roomRequests = requests.where((r) {
                    final data = r.data();
                    final status = data['status'];

                    return (data['room'] ?? '').toString() == room &&
                        (status == 'PENDING' ||
                            status == 'ACKNOWLEDGED' ||
                            status == 'RESPONDING');
                  }).toList();

                  final emergency = roomRequests.any(
                        (r) =>
                    r.data()['requestType'] == 'EMERGENCY',
                  );

                  final color = roomRequests.isEmpty
                      ? const Color(0xFF159B70)
                      : emergency
                      ? const Color(0xFFFF5252)
                      : const Color(0xFFF59E0B);

                  return SizedBox(
                    width: width,
                    child: Card(
                      color: color.withValues(alpha: 0.10),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.bed_rounded,
                              color: color,
                              size: 30,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Room $room',
                              style: TextStyle(
                                color: color,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              roomRequests.isEmpty
                                  ? 'No open calls'
                                  : '${roomRequests.length} open call(s)',
                              style: TextStyle(color: color),
                            ),
                            if (roomRequests.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              ...roomRequests.map((r) {
                                final data = r.data();

                                return TextButton(
                                  onPressed: () => _openDetails(r),
                                  child: Text(
                                    (data['requestType'] ?? 'Request')
                                        .toString(),
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }

  // REPORTS
  Widget _reports(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> requests,
      List<QueryDocumentSnapshot<Map<String, dynamic>>> patients,
      ) {
    final pending =
        requests.where((r) => r.data()['status'] == 'PENDING').length;

    final acknowledged = requests
        .where((r) => r.data()['status'] == 'ACKNOWLEDGED')
        .length;

    final responding = requests
        .where((r) => r.data()['status'] == 'RESPONDING')
        .length;

    final completed =
        requests.where((r) => r.data()['status'] == 'COMPLETED').length;

    final types = <String, int>{};

    for (final request in requests) {
      final type =
      (request.data()['requestType'] ?? 'UNKNOWN').toString();
      types[type] = (types[type] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reports',
          style: TextStyle(
            color: stationText,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Summary of the request records currently in Firestore.',
          style: TextStyle(color: Colors.blueGrey),
        ),
        const SizedBox(height: 24),

        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _reportTile('Total Requests', requests.length),
            _reportTile('Registered Patients', patients.length),
            _reportTile('Pending', pending),
            _reportTile('Acknowledged', acknowledged),
            _reportTile('Responding', responding),
            _reportTile('Completed', completed),
          ],
        ),

        const SizedBox(height: 24),

        _panel(
          title: 'Requests by Type',
          child: types.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(20),
            child: Text('No request records available.'),
          )
              : Column(
            children: types.entries.map((entry) {
              return ListTile(
                leading: const Icon(
                  Icons.circle,
                  color: stationTeal,
                  size: 12,
                ),
                title: Text(entry.key),
                trailing: Text(
                  '${entry.value}',
                  style: const TextStyle(
                    color: stationTeal,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),
        const Text(
          'These totals are not filtered by date.',
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _reportTile(String title, int count) {
    return SizedBox(
      width: 190,
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFDCEDEC)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  color: stationTeal,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(color: stationText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MANAGEMENT PAGES
  Widget _managementPanel({
    required String title,
    required String description,
    required IconData icon,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFDCEDEC)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: stationTeal.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: stationTeal,
                  size: 38,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: stationText,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.blueGrey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onPressed,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: Text(buttonLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: stationTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // SETTINGS
  Widget _settings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            color: stationText,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Station information and management shortcuts.',
          style: TextStyle(color: Colors.blueGrey),
        ),
        const SizedBox(height: 24),

        _panel(
          title: 'Patient Management',
          child: ListTile(
            leading: const Icon(
              Icons.person_add_alt_1_rounded,
              color: stationTeal,
            ),
            title: const Text('Register New Patient'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => openSection(
              StationSection.registerPatient,
            ),
          ),
        ),

        const SizedBox(height: 16),

        _panel(
          title: 'Nurse Management',
          child: ListTile(
            leading: const Icon(
              Icons.medical_services_rounded,
              color: stationTeal,
            ),
            title: const Text('Create Nurse Account'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => openSection(
              StationSection.createNurse,
            ),
          ),
        ),

        const SizedBox(height: 16),

        _panel(
          title: 'Registered Patients',
          child: ListTile(
            leading: const Icon(
              Icons.people_alt_rounded,
              color: stationTeal,
            ),
            title: const Text('View Registered Patients'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => openSection(
              StationSection.registeredPatients,
            ),
          ),
        ),
      ],
    );
  }

  Widget _errorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  String _roomText(Map<String, dynamic> data) {
    return '${data['room'] ?? 'Unknown Room'} • '
        '${data['bed'] ?? 'Unknown Bed'}';
  }

  Color _requestColor(String type) {
    switch (type) {
      case 'EMERGENCY':
        return const Color(0xFFFF5252);
      case 'MEDICATION / PAIN':
        return const Color(0xFFF59E0B);
      case 'BATHROOM ASSIST':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF159B70);
    }
  }

  void _openDetails(
      QueryDocumentSnapshot<Map<String, dynamic>> request,
      ) {
    final data = request.data();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RequestDetailsPage(
          requestType:
          (data['requestType'] ?? 'UNKNOWN').toString(),
          room: _roomText(data),
          status: (data['status'] ?? 'UNKNOWN').toString(),
          requestId: request.id,
        ),
      ),
    );
  }
}
