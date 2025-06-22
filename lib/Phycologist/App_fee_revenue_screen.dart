import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' as services;

import 'Providers/App_Fee_Provider.dart';

class AppFeeRevenueScreen extends StatefulWidget {
  @override
  _AppFeeRevenueScreenState createState() => _AppFeeRevenueScreenState();
}

class _AppFeeRevenueScreenState extends State<AppFeeRevenueScreen> {
  late AppFeeProvider _provider;
  services.Uint8List? _appLogo;
  pw.Font? _pdfRegularFont;
  pw.Font? _pdfBoldFont;


  @override
  void initState() {
    super.initState();
    _provider = AppFeeProvider();
    _provider.fetchRevenueData();

    _loadAppLogo();
    _loadPdfFonts();
  }


  Future<void> _loadAppLogo() async {
    try {
      final services.ByteData data = await services.rootBundle.load('assets/images/bi_peace-fill.png');
      _appLogo = data.buffer.asUint8List();
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

// Add the PDF generation method
  Future<void> _generatePdf(AppFeeProvider provider) async {
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
          };
        }
        dailyData[dateKey]!['revenue'] += revenue.psychologistRevenue;
        dailyData[dateKey]!['appointments'] += 1;
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
                      'Platform Revenue Report',
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
                ['Total Platform Revenue', '\$${totalRevenue.toStringAsFixed(2)}'],
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
              headers: ['Date', 'Platform Revenue', 'Appointments'],
              data: sortedDates.map((date) => [
                date,
                '\$${dailyData[date]!['revenue'].toStringAsFixed(2)}',
                dailyData[date]!['appointments'].toString(),
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
              headers: ['Date', 'Time', 'Doctor ID', 'Platform Revenue', 'Total Fee'],
              data: provider.revenues.map((revenue) => [
                revenue.formattedDate,
                revenue.time,
                revenue.doctorId,
                '\$${revenue.psychologistRevenue.toStringAsFixed(2)}',
                '\$${revenue.fee.toStringAsFixed(2)}'
              ]).toList(),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Note: Platform earns 10% of each online appointment',
              style: pw.TextStyle(
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ],
        ),
      );

      // Save and open PDF
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/platform_revenue_${DateTime.now().millisecondsSinceEpoch}.pdf');
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
    return ChangeNotifierProvider<AppFeeProvider>.value(
      value: _provider,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(context),
        floatingActionButton: Consumer<AppFeeProvider>(
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
                        text: 'Platform ',
                        style: TextStyle(
                          color: Color(0xFF006064),
                          fontSize: size.height * 0.035,
                          fontWeight: FontWeight.bold,
                          fontFamily: "CustomFont",
                        ),
                      ),
                      TextSpan(
                        text: 'Revenue',
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
    return Consumer<AppFeeProvider>(
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
              _buildDateRangePicker(context, provider),
              SizedBox(height: 20),
              _buildRevenueChart(context, provider),
              SizedBox(height: 20),
              _buildRevenueSummary(context, provider),
              SizedBox(height: 20),
              // _buildAppointmentList(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateRangePicker(BuildContext context, AppFeeProvider provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
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

  Widget _buildRevenueChart(BuildContext context, AppFeeProvider provider) {
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
              'Platform Revenue Trend',
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
                primaryXAxis: CategoryAxis(labelRotation: 45),
                series: <ChartSeries<ChartData, String>>[
                  ColumnSeries<ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (ChartData data, _) => data.date,
                    yValueMapper: (ChartData data, _) => data.revenue,
                    color: Color(0xFF006064),
                    dataLabelSettings: DataLabelSettings(isVisible: true),
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

  Widget _buildRevenueSummary(BuildContext context, AppFeeProvider provider) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final totalRevenue = provider.revenues.fold(
      0.0,
          (sum, revenue) => sum + revenue.psychologistRevenue,
    );
    final totalAppointments = provider.revenues.length;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(width * 0.03)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.02,
        ),
        child: Column(
          children: [
            Text(
              'Summary',
              style: TextStyle(
                fontSize: width * 0.045,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006064),
              ),
            ),
            SizedBox(height: height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem(
                  context,
                  'Total Platform Revenue',
                  '\$. ${totalRevenue.toStringAsFixed(2)}',
                  Icons.attach_money,
                ),
                _buildSummaryItem(
                  context,
                  'Total Appointments',
                  totalAppointments.toString(),
                  Icons.event_note,
                ),
              ],
            ),
            SizedBox(height: height * 0.015),
            Divider(),
            SizedBox(height: height * 0.015),
            Text(
              'Platform earns 10% of each online appointment',
              style: TextStyle(
                fontSize: width * 0.03,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String title, String value, IconData icon) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: width * 0.08, color: Color(0xFF006064)),
        SizedBox(height: width * 0.02),
        Text(
          title,
          style: TextStyle(
            fontSize: width * 0.032,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: width * 0.01),
        Text(
          value,
          style: TextStyle(
            fontSize: width * 0.045,
            fontWeight: FontWeight.bold,
            color: Color(0xFF006064),
          ),
        ),
      ],
    );
  }


  Widget _buildAppointmentList(BuildContext context, AppFeeProvider provider) {
    if (provider.revenues.isEmpty) {
      return Center(
        child: Text(
          'No completed appointments found for selected period',
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
              'Appointment Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006064)),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: provider.revenues.length,
              itemBuilder: (context, index) {
                final revenue = provider.revenues[index];
                return _buildAppointmentItem(revenue);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentItem(AppointmentRevenue revenue) {
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
            Text('Doctor ID: ${revenue.doctorId}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Rs. ${revenue.psychologistRevenue.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006064)),
            ),
            Text('(Total: Rs.${revenue.fee.toStringAsFixed(2)})', style: TextStyle(fontSize: 12)),
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
