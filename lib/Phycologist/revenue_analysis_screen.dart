import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mental_ease/Phycologist/Providers/revenue_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' as services;

class RevenueAnalysisScreen extends StatefulWidget {
  @override
  _RevenueAnalysisScreenState createState() => _RevenueAnalysisScreenState();
}

class _RevenueAnalysisScreenState extends State<RevenueAnalysisScreen> {
  late RevenueProvider _provider;
  services.Uint8List? _appLogo;
  pw.Font? _pdfRegularFont;
  pw.Font? _pdfBoldFont;

  @override
  void initState() {
    super.initState();
    _provider = RevenueProvider();
    _provider.fetchRevenueData();
    _loadAppLogo();
    _loadPdfFonts();
  }

  Future<void> _loadAppLogo() async {
    try {
      final services.ByteData data = await services.rootBundle.load('assets/images/bi_peace-fill.png');
      _appLogo = data.buffer.asUint8List() as services.Uint8List?;
    } catch (e) {
      print("Error loading app logo: $e");
    }
  }

  Future<void> _loadPdfFonts() async {
    try {
      final regularFontData = await services.rootBundle.load('assets/fonts/PlaypenSans-Regular.ttf');
      final boldFontData = await services.rootBundle.load('assets/fonts/PlaypenSans-Bold.ttf');
      _pdfRegularFont = pw.Font.ttf(regularFontData);
      _pdfBoldFont = pw.Font.ttf(boldFontData);
    } catch (e) {
      print('Error loading fonts: $e');
      _pdfRegularFont = pw.Font.helvetica();
      _pdfBoldFont = pw.Font.helveticaBold();
    }
  }

  Future<void> _generatePdf(RevenueProvider provider) async {
    try {
      // Ensure fonts are loaded
      final regularFont = _pdfRegularFont ?? pw.Font.helvetica();
      final boldFont = _pdfBoldFont ?? pw.Font.helveticaBold();

      if (provider.revenues.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No data available to generate PDF')),
        );
        return;
      }

      // Calculate daily revenue and appointment counts
      final dailyData = <String, Map<String, dynamic>>{};
      for (final revenue in provider.revenues) {
        final dateKey = revenue.formattedDate;
        if (!dailyData.containsKey(dateKey)) {
          dailyData[dateKey] = {
            'revenue': 0.0,
            'appointments': 0,
            'completed': 0,
            'pending': 0,
          };
        }
        dailyData[dateKey]!['revenue'] += revenue.psychologistRevenue;
        dailyData[dateKey]!['appointments'] += 1;
        if (revenue.status == 'completed') {
          dailyData[dateKey]!['completed'] += 1;
        } else {
          dailyData[dateKey]!['pending'] += 1;
        }
      }

      // Sort daily data by date
      final sortedDates = dailyData.keys.toList()
        ..sort((a, b) => DateFormat('dd/MM/yyyy').parse(a).compareTo(DateFormat('dd/MM/yyyy').parse(b)));

      final totalRevenue = provider.revenues.fold(
          0.0, (sum, revenue) => sum + revenue.psychologistRevenue);
      final totalAppointments = provider.revenues.length;

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(
            base: regularFont,
            bold: boldFont,
          ),
          build: (pw.Context context) => [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                if (_appLogo != null)
                  pw.Column(
                      children: [
                        pw.Image(
                          pw.MemoryImage(_appLogo!),
                          height: 60,
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text("Mental Ease",
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        )
                      ]
                  ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Revenue Analysis Report',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Date Range: ${DateFormat('dd/MM/yyyy').format(provider.startDate)} - ${DateFormat('dd/MM/yyyy').format(provider.endDate)}',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                    pw.Text(
                      'Generated on: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Current Filter Status
            pw.Header(
              level: 1,
              text: 'Current Filters',
              textStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Table.fromTextArray(
              context: context,
              border: pw.TableBorder.all(),
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#006064'),
              ),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
              headers: ['Filter', 'Value'],
              data: [
                ['Date Range', '${DateFormat('dd/MM/yyyy').format(provider.startDate)} to ${DateFormat('dd/MM/yyyy').format(provider.endDate)}'],
                ['Appointment Status', provider.selectedStatus == 'all' ? 'All Appointments' : provider.selectedStatus[0].toUpperCase() + provider.selectedStatus.substring(1)],
              ],
            ),
            pw.SizedBox(height: 20),

            // Summary Section
            pw.Header(
              level: 1,
              text: 'Summary',
              textStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Table.fromTextArray(
              context: context,
              border: pw.TableBorder.all(),
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#006064'),
              ),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
              headers: ['Metric', 'Value'],
              data: [
                ['Total Revenue', '\$${totalRevenue.toStringAsFixed(2)}'],
                ['Total Appointments', totalAppointments.toString()],
                ['Average per Appointment', '\$${(totalAppointments > 0 ? totalRevenue / totalAppointments : 0).toStringAsFixed(2)}'],
              ],
            ),
            pw.SizedBox(height: 20),

            // Detailed Daily Revenue Trend
            pw.Header(
              level: 1,
              text: 'Daily Revenue Trend',
              textStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Table.fromTextArray(
              context: context,
              border: pw.TableBorder.all(),
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#006064'),
              ),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
              headers: ['Date', 'Revenue', 'Appointments', 'Completed', 'Pending'],
              data: sortedDates.map((date) => [
                date,
                '\$${dailyData[date]!['revenue'].toStringAsFixed(2)}',
                dailyData[date]!['appointments'].toString(),
                dailyData[date]!['completed'].toString(),
                dailyData[date]!['pending'].toString(),
              ]).toList(),
            ),
            pw.SizedBox(height: 20),

            // Appointment Details
            pw.Header(
              level: 1,
              text: 'Appointment Details',
              textStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Table.fromTextArray(
              context: context,
              border: pw.TableBorder.all(),
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#006064'),
              ),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
              headers: ['Date', 'Time', 'Status', 'Your Revenue', 'Total Fee'],
              data: provider.revenues.map((revenue) => [
                revenue.formattedDate,
                revenue.time,
                revenue.status[0].toUpperCase() + revenue.status.substring(1),
                '\$${revenue.psychologistRevenue.toStringAsFixed(2)}',
                '\$${revenue.fee.toStringAsFixed(2)}'
              ]).toList(),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Note: You receive 90% of each online appointment (10% platform fee)',
              style: pw.TextStyle(
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ],
        ),
      );

      // Save and open PDF
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/revenue_analysis_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate PDF: ${e.toString()}')),
      );
      print('PDF generation error: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(context),
        floatingActionButton: Consumer<RevenueProvider>(
          builder: (context, provider, child) {
            if (provider.revenues.isEmpty) return SizedBox.shrink();
            return FloatingActionButton.extended(
              onPressed: () => _generatePdf(provider),
              icon: Icon(Icons.picture_as_pdf, color: Colors.white),
              label: Text('Generate PDF', style: TextStyle(color: Colors.white)),
              backgroundColor: Color(0xFF006064),
            );
          },
        ),
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
                        text: 'Revenue ',
                        style: TextStyle(
                          color: Color(0xFF006064),
                          fontSize: size.height * 0.035,
                          fontWeight: FontWeight.bold,
                          fontFamily: "CustomFont",
                        ),
                      ),
                      TextSpan(
                        text: 'Analysis',
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
    return Consumer<RevenueProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text(provider.error!));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildFilters(context, provider),
              SizedBox(height: 20),
              _buildRevenueChart(context, provider),
              SizedBox(height: 20),
              _buildRevenueSummary(context, provider),
              SizedBox(height: 20),
              _buildAppointmentList(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilters(BuildContext context, RevenueProvider provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(
                    context,
                    'Start Date',
                    provider.startDate,
                        (date) => provider.setDateRange(date, provider.endDate),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildDatePicker(
                    context,
                    'End Date',
                    provider.endDate,
                        (date) => provider.setDateRange(provider.startDate, date),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            _buildStatusDropdown(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(
      BuildContext context,
      String label,
      DateTime date,
      Function(DateTime) onDateSelected,
      ) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(Duration(days: 365)),
        );
        if (selectedDate != null) {
          onDateSelected(selectedDate);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          DateFormat('dd/MM/yyyy').format(date),
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(RevenueProvider provider) {
    return DropdownButtonFormField<String>(
      value: provider.selectedStatus,
      decoration: InputDecoration(
        labelText: 'Appointment Status',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.filter_alt),
      ),
      items: ['completed', 'pending'].map((status) {
        return DropdownMenuItem<String>(
          value: status,
          child: Text(
            status[0].toUpperCase() + status.substring(1),
            style: TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          provider.setSelectedStatus(value);
        }
      },
    );
  }

  Widget _buildRevenueChart(BuildContext context, RevenueProvider provider) {
    final Map<String, double> dailyRevenue = {};
    for (final revenue in provider.revenues) {
      final dateKey = revenue.formattedDate;
      dailyRevenue[dateKey] = (dailyRevenue[dateKey] ?? 0) + revenue.psychologistRevenue;
    }

    final chartData = dailyRevenue.entries.map((entry) {
      return ChartData(entry.key, entry.value);
    }).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006064),
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(labelRotation: 45, labelStyle: TextStyle(fontSize: 10)),
                series: <ChartSeries<ChartData, String>>[
                  ColumnSeries<ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (ChartData data, _) => data.date,
                    yValueMapper: (ChartData data, _) => data.revenue,
                    color: Color(0xFF006064),
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.top,
                    ),
                  )
                ],
                tooltipBehavior: TooltipBehavior(enable: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueSummary(BuildContext context, RevenueProvider provider) {
    final totalRevenue = provider.revenues.fold(
      0.0,
          (sum, revenue) => sum + revenue.psychologistRevenue,
    );
    final totalAppointments = provider.revenues.length;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006064)),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(context, 'Total Revenue', '\$. ${totalRevenue.toStringAsFixed(2)}', Icons.attach_money),
                _buildSummaryItem(context, 'Total Appointments', totalAppointments.toString(), Icons.event_note),
              ],
            ),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 8),
            Text(
              'Note: You receive 90% of the appointment fee (10% deducted as platform fee)',
              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Color(0xFF006064)),
        SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006064))),
      ],
    );
  }

  Widget _buildAppointmentList(BuildContext context, RevenueProvider provider) {
    if (provider.revenues.isEmpty) {
      return Center(
        child: Text(
          'No appointments found for selected criteria',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Online Appointment Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006064)),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: provider.revenues.length,
              itemBuilder: (context, index) {
                final revenue = provider.revenues[index];
                return _buildAppointmentItem(context, revenue);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentItem(BuildContext context, AppointmentRevenue revenue) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text('Date: ${revenue.formattedDate}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time: ${revenue.time}'),
            Text('Status: ${revenue.status[0].toUpperCase()}${revenue.status.substring(1)}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('\$ ${revenue.psychologistRevenue.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006064))),

          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String date;
  final double revenue;

  ChartData(this.date, this.revenue);
}
