// lib/Admin/screens/admin_reports_screen.dart
import 'package:flutter/material.dart';
import 'package:mental_ease/Admin/providers/phycologist_report_provider.dart';

import 'package:provider/provider.dart';

import 'Report_list.dart';

class AdminReportsScreen extends StatefulWidget {
  @override
  _AdminReportsScreenState createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  late PsychologistReportsProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = PsychologistReportsProvider();
    _provider.fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PsychologistReportsProvider>.value(
      value: _provider,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PreferredSize(
      preferredSize: Size.fromHeight(size.height * 0.2),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(size.height * 0.03)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE0F7FA), Color(0xFF80DEEA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'User ',
                        style: TextStyle(
                          color: Color(0xFF006064),
                          fontSize: size.height * 0.035,
                          fontWeight: FontWeight.bold,
                          fontFamily: "CustomFont",
                        ),
                      ),
                      TextSpan(
                        text: 'Reports',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: size.height * 0.035,
                          fontWeight: FontWeight.bold,
                          fontFamily: "CustomFont",
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Divider(thickness: 2, indent: 50, endIndent: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<PsychologistReportsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.reports.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text(provider.error!));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [

              _buildSummaryCard(context, provider),
              SizedBox(height: 20),
              ReportsList(reports: provider.reports),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context, PsychologistReportsProvider provider) {
    final size = MediaQuery.of(context).size;
    final totalReports = provider.reports.length;
    final uniquePsychologists = provider.reports.map((r) => r.doctorId).toSet().length;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(size.width * 0.03)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.02,
        ),
        child: Column(
          children: [
            Text(
              'Reports Summary',
              style: TextStyle(
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006064),
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem(
                  context,
                  'Total Reports',
                  totalReports.toString(),
                  Icons.report,
                  Color(0xFF006064),
                ),
                _buildSummaryItem(
                  context,
                  'Psychologists',
                  uniquePsychologists.toString(),
                  Icons.people,
                  Color(0xFF006064),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String title, String value, IconData icon, Color color) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: width * 0.06, color: color),
        SizedBox(height: width * 0.02),
        Text(
          title,
          style: TextStyle(
            fontSize: width * 0.03,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: width * 0.01),
        Text(
          value,
          style: TextStyle(
            fontSize: width * 0.04,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}