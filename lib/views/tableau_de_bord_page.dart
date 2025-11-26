import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import '../controllers/crud_services.dart';

class TableauDeBordPage extends StatefulWidget {
  const TableauDeBordPage({super.key});

  @override
  State<TableauDeBordPage> createState() => _TableauDeBordPageState();
}

class _TableauDeBordPageState extends State<TableauDeBordPage> {
  final CrudServices _crudServices = CrudServices();
  DateTimeRange? _selectedDateRange;
  Map<String, int> _contactsPerDay = {};
  Map<String, int> _qualificationsPerDay = {};
  Map<String, int> _resultatsDistribution = {};
  Map<int, int> _satisfactionDistribution = {};
  double _averageSatisfaction = 0.0;
  int _totalContacts = 0;
  int _totalQualifications = 0;
  bool _isLoading = false;

  final List<String> _resultatsAppelOptions = [
    "Non appelé",
    "N'a pas répondu",
    "Pas satisfait",
    "Ne veut pas faire d'avis",
    "0 étoiles",
    "1 étoile",
    "2 étoiles",
    "3 étoiles",
    "4 étoiles",
    "5 étoiles",
  ];

  final Map<String, Color> _resultatsColors = {
    "Non appelé": Colors.blue,
    "N'a pas répondu": Colors.grey,
    "Pas satisfait": Colors.red,
    "Ne veut pas faire d'avis": Colors.blueGrey,
    "0 étoiles": Colors.red.shade900,
    "1 étoile": Colors.deepOrange,
    "2 étoiles": Colors.orange,
    "3 étoiles": Colors.amber,
    "4 étoiles": Colors.lightGreen,
    "5 étoiles": Colors.green,
  };

  @override
  void initState() {
    super.initState();
    // Default to current month
    DateTime now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );
    _loadData();
  }

  Future<void> _selectDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (_selectedDateRange == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot snapshot = await _crudServices.getContactsSnapshot();
      Map<String, int> contactsPerDay = {};
      Map<String, int> qualificationsPerDay = {};
      Map<String, int> resultatsDistribution = {};
      Map<int, int> satisfactionDistribution = {};
      int totalContacts = 0;
      int totalQualifications = 0;
      int totalSatisfactionSum = 0;
      int satisfactionCount = 0;

      // Initialize all result types with 0
      for (String option in _resultatsAppelOptions) {
        resultatsDistribution[option] = 0;
      }

      // Initialize satisfaction levels 0-10
      for (int i = 0; i <= 10; i++) {
        satisfactionDistribution[i] = 0;
      }

      DateTime startOfDay = DateTime(
        _selectedDateRange!.start.year,
        _selectedDateRange!.start.month,
        _selectedDateRange!.start.day,
      );
      DateTime endOfDay = DateTime(
        _selectedDateRange!.end.year,
        _selectedDateRange!.end.month,
        _selectedDateRange!.end.day,
        23,
        59,
        59,
      );

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Count contacts created
        DateTime? contactDate;
        if (data['dateCreation'] != null) {
          contactDate = (data['dateCreation'] as Timestamp).toDate();
        } else if (data['dateArrivee'] != null) {
          contactDate = (data['dateArrivee'] as Timestamp).toDate();
        }

        if (contactDate != null) {
          if (contactDate.isAfter(startOfDay.subtract(Duration(seconds: 1))) &&
              contactDate.isBefore(endOfDay.add(Duration(seconds: 1)))) {
            String dateKey =
                '${contactDate.day}/${contactDate.month}/${contactDate.year}';
            contactsPerDay[dateKey] = (contactsPerDay[dateKey] ?? 0) + 1;
            totalContacts++;

            // Count current statutAppel for contacts in date range (for pie chart)
            String currentStatut = data['statutAppel'] ?? 'Non appelé';
            if (resultatsDistribution.containsKey(currentStatut)) {
              resultatsDistribution[currentStatut] =
                  (resultatsDistribution[currentStatut] ?? 0) + 1;
            }

            // Count satisfaction distribution (0-10)
            int satisfaction = data['degreSatisfaction'] ?? 0;
            if (satisfaction >= 0 && satisfaction <= 10) {
              satisfactionDistribution[satisfaction] =
                  (satisfactionDistribution[satisfaction] ?? 0) + 1;
              totalSatisfactionSum += satisfaction;
              satisfactionCount++;
            }
          }
        }

        // Count qualifications (from resultatsAppels)
        if (data['resultatsAppels'] != null) {
          List<dynamic> resultats = data['resultatsAppels'] as List<dynamic>;
          for (var resultat in resultats) {
            if (resultat['date'] != null) {
              DateTime qualifDate = (resultat['date'] as Timestamp).toDate();
              if (qualifDate.isAfter(
                    startOfDay.subtract(Duration(seconds: 1)),
                  ) &&
                  qualifDate.isBefore(endOfDay.add(Duration(seconds: 1)))) {
                String dateKey =
                    '${qualifDate.day}/${qualifDate.month}/${qualifDate.year}';
                qualificationsPerDay[dateKey] =
                    (qualificationsPerDay[dateKey] ?? 0) + 1;
                totalQualifications++;
              }
            }
          }
        }
      }

      setState(() {
        _contactsPerDay = contactsPerDay;
        _qualificationsPerDay = qualificationsPerDay;
        _resultatsDistribution = resultatsDistribution;
        _satisfactionDistribution = satisfactionDistribution;
        _averageSatisfaction = satisfactionCount > 0
            ? totalSatisfactionSum / satisfactionCount
            : 0.0;
        _totalContacts = totalContacts;
        _totalQualifications = totalQualifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  List<MapEntry<DateTime, int>> _getSortedData() {
    List<MapEntry<DateTime, int>> sortedData = [];

    _contactsPerDay.forEach((dateStr, count) {
      List<String> parts = dateStr.split('/');
      if (parts.length == 3) {
        DateTime date = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
        sortedData.add(MapEntry(date, count));
      }
    });

    sortedData.sort((a, b) => a.key.compareTo(b.key));
    return sortedData;
  }

  List<MapEntry<DateTime, int>> _getSortedQualificationData() {
    List<MapEntry<DateTime, int>> sortedData = [];

    _qualificationsPerDay.forEach((dateStr, count) {
      List<String> parts = dateStr.split('/');
      if (parts.length == 3) {
        DateTime date = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
        sortedData.add(MapEntry(date, count));
      }
    });

    sortedData.sort((a, b) => a.key.compareTo(b.key));
    return sortedData;
  }

  @override
  Widget build(BuildContext context) {
    List<MapEntry<DateTime, int>> sortedData = _getSortedData();
    List<MapEntry<DateTime, int>> sortedQualifData =
        _getSortedQualificationData();
    int maxCount = sortedData.isEmpty
        ? 1
        : sortedData.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    int maxQualifCount = sortedQualifData.isEmpty
        ? 1
        : sortedQualifData.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tableau de Bord',
          style: GoogleFonts.sora(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Date range selector
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Column(
                children: [
                  Text(
                    'Sélectionner la période',
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  SizedBox(height: 12),
                  InkWell(
                    onTap: _selectDateRange,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month, color: Colors.blue),
                          SizedBox(width: 12),
                          Text(
                            _selectedDateRange != null
                                ? '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}'
                                : 'Choisir une période',
                            style: GoogleFonts.sora(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_drop_down, color: Colors.blue),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Stats summary - Contacts
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Contacts Ajoutés',
                      _totalContacts.toString(),
                      Icons.people,
                      Colors.blue,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Qualifications',
                      _totalQualifications.toString(),
                      Icons.phone_callback,
                      Colors.green,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Moy. Qualif/jour',
                      _qualificationsPerDay.isEmpty
                          ? '0'
                          : (_totalQualifications /
                                    _qualificationsPerDay.length)
                                .toStringAsFixed(1),
                      Icons.trending_up,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            // Chart title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.bar_chart, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Contacts ajoutés par jour',
                    style: GoogleFonts.sora(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8),

            // Chart
            _isLoading
                ? Container(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : sortedData.isEmpty
                ? Container(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.insert_chart_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Aucune donnée pour cette période',
                            style: GoogleFonts.sora(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.all(16),
                    child: Container(
                      height: 280,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: sortedData.map((entry) {
                          double barHeight = (entry.value / maxCount) * 200;
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Count label
                                Text(
                                  entry.value.toString(),
                                  style: GoogleFonts.sora(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                                SizedBox(height: 4),
                                // Bar
                                Container(
                                  width: 40,
                                  height: barHeight < 20 ? 20 : barHeight,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.blue.shade700,
                                        Colors.blue.shade400,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(6),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8),
                                // Date label
                                RotatedBox(
                                  quarterTurns: -1,
                                  child: Text(
                                    '${entry.key.day}/${entry.key.month}',
                                    style: GoogleFonts.sora(
                                      fontSize: 10,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

            // Data table for contacts
            if (!_isLoading && sortedData.isNotEmpty)
              Container(
                height: 200,
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Date',
                              style: GoogleFonts.sora(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Contacts',
                              style: GoogleFonts.sora(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: sortedData.length,
                        separatorBuilder: (context, index) =>
                            Divider(height: 1),
                        itemBuilder: (context, index) {
                          var entry = sortedData[index];
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${entry.key.day}/${entry.key.month}/${entry.key.year}',
                                    style: GoogleFonts.sora(),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      entry.value.toString(),
                                      style: GoogleFonts.sora(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Divider
            Divider(thickness: 2, color: Colors.grey.shade300),

            // Qualification Chart Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.phone_callback, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Qualifications de fiche par jour',
                    style: GoogleFonts.sora(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ),

            // Qualification Chart
            _isLoading
                ? Container(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : sortedQualifData.isEmpty
                ? Container(
                    height: 150,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phone_disabled,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Aucune qualification pour cette période',
                            style: GoogleFonts.sora(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.all(16),
                    child: Container(
                      height: 280,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: sortedQualifData.map((entry) {
                          double barHeight =
                              (entry.value / maxQualifCount) * 200;
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Count label
                                Text(
                                  entry.value.toString(),
                                  style: GoogleFonts.sora(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                                SizedBox(height: 4),
                                // Bar
                                Container(
                                  width: 40,
                                  height: barHeight < 20 ? 20 : barHeight,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.green.shade700,
                                        Colors.green.shade400,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(6),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8),
                                // Date label
                                RotatedBox(
                                  quarterTurns: -1,
                                  child: Text(
                                    '${entry.key.day}/${entry.key.month}',
                                    style: GoogleFonts.sora(
                                      fontSize: 10,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

            // Qualification Data table
            if (!_isLoading && sortedQualifData.isNotEmpty)
              Container(
                height: 200,
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Date',
                              style: GoogleFonts.sora(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Qualifications',
                              style: GoogleFonts.sora(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: sortedQualifData.length,
                        separatorBuilder: (context, index) =>
                            Divider(height: 1),
                        itemBuilder: (context, index) {
                          var entry = sortedQualifData[index];
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${entry.key.day}/${entry.key.month}/${entry.key.year}',
                                    style: GoogleFonts.sora(),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      entry.value.toString(),
                                      style: GoogleFonts.sora(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade800,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 20),

            // Divider
            Divider(thickness: 2, color: Colors.grey.shade300),

            // Pie Chart Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.pie_chart, color: Colors.purple),
                  SizedBox(width: 8),
                  Text(
                    'Répartition des résultats d\'appel',
                    style: GoogleFonts.sora(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade800,
                    ),
                  ),
                ],
              ),
            ),

            // Pie Chart
            _isLoading
                ? Container(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _totalQualifications == 0
                    ? Container(
                        height: 150,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.pie_chart_outline,
                                size: 60,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Aucune donnée pour cette période',
                                style: GoogleFonts.sora(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Custom Pie Chart
                            Container(
                              height: 200,
                              width: 200,
                              child: CustomPaint(
                                painter: PieChartPainter(
                                  data: _resultatsDistribution,
                                  colors: _resultatsColors,
                                  total: _totalQualifications,
                                ),
                              ),
                            ),
                            SizedBox(height: 24),
                            // Legend
                            Wrap(
                              spacing: 16,
                              runSpacing: 12,
                              alignment: WrapAlignment.center,
                              children: _resultatsAppelOptions.map((option) {
                                int count = _resultatsDistribution[option] ?? 0;
                                if (count == 0) return SizedBox.shrink();
                                double percentage =
                                    (count / _totalQualifications) * 100;
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _resultatsColors[option]!
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _resultatsColors[option]!
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: _resultatsColors[option],
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '$option: $count (${percentage.toStringAsFixed(1)}%)',
                                        style: GoogleFonts.sora(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

            SizedBox(height: 20),

            // Divider
            Divider(thickness: 2, color: Colors.grey.shade300),

            // Satisfaction Distribution Chart Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Progression des Avis - Degré de Satisfaction',
                      style: GoogleFonts.sora(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Average satisfaction card
            if (!_isLoading && _totalContacts > 0)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade100, Colors.orange.shade100],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 32),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Moyenne de Satisfaction',
                          style: GoogleFonts.sora(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _averageSatisfaction.toStringAsFixed(1),
                              style: GoogleFonts.sora(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade800,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 6),
                              child: Text(
                                ' / 10',
                                style: GoogleFonts.sora(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(width: 20),
                    // Visual stars
                    Column(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            double threshold = (index + 1) * 2;
                            return Icon(
                              _averageSatisfaction >= threshold
                                  ? Icons.star
                                  : _averageSatisfaction >= threshold - 1
                                      ? Icons.star_half
                                      : Icons.star_border,
                              color: Colors.amber,
                              size: 24,
                            );
                          }),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Sur $_totalContacts contacts',
                          style: GoogleFonts.sora(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Satisfaction Bar Chart
            _isLoading
                ? Container(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _totalContacts == 0
                    ? Container(
                        height: 150,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bar_chart,
                                size: 60,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Aucune donnée pour cette période',
                                style: GoogleFonts.sora(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _buildSatisfactionChart(),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSatisfactionChart() {
    int maxSatisfactionCount = _satisfactionDistribution.values.isEmpty
        ? 1
        : _satisfactionDistribution.values.reduce((a, b) => a > b ? a : b);
    if (maxSatisfactionCount == 0) maxSatisfactionCount = 1;

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Bar Chart
          Container(
            height: 280,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(11, (index) {
                int count = _satisfactionDistribution[index] ?? 0;
                double barHeight = (count / maxSatisfactionCount) * 200;

                // Color gradient from red (0) to green (10)
                Color barColor = Color.lerp(
                  Colors.red,
                  Colors.green,
                  index / 10,
                )!;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Count label
                        Text(
                          count.toString(),
                          style: GoogleFonts.sora(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: barColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        // Bar
                        Container(
                          width: double.infinity,
                          height: barHeight < 20 ? 20 : barHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                barColor.withOpacity(0.8),
                                barColor,
                              ],
                            ),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: barColor.withOpacity(0.3),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        // Level label
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: barColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$index',
                            style: GoogleFonts.sora(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: barColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.red, 'Insatisfait (0-3)'),
              SizedBox(width: 16),
              _buildLegendItem(Colors.amber, 'Neutre (4-6)'),
              SizedBox(width: 16),
              _buildLegendItem(Colors.green, 'Satisfait (7-10)'),
            ],
          ),
          SizedBox(height: 16),
          // Distribution summary
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDistributionStat(
                  'Insatisfaits',
                  _getCountForRange(0, 3),
                  Colors.red,
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                _buildDistributionStat(
                  'Neutres',
                  _getCountForRange(4, 6),
                  Colors.amber,
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                _buildDistributionStat(
                  'Satisfaits',
                  _getCountForRange(7, 10),
                  Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.sora(fontSize: 10, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildDistributionStat(String label, int count, Color color) {
    double percentage = _totalContacts > 0 ? (count / _totalContacts) * 100 : 0;
    return Column(
      children: [
        Text(
          count.toString(),
          style: GoogleFonts.sora(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: GoogleFonts.sora(fontSize: 12, color: Colors.grey.shade600),
        ),
        Text(
          label,
          style: GoogleFonts.sora(fontSize: 10, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  int _getCountForRange(int start, int end) {
    int count = 0;
    for (int i = start; i <= end; i++) {
      count += _satisfactionDistribution[i] ?? 0;
    }
    return count;
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.sora(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.sora(fontSize: 10, color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Custom Pie Chart Painter
class PieChartPainter extends CustomPainter {
  final Map<String, int> data;
  final Map<String, Color> colors;
  final int total;

  PieChartPainter({
    required this.data,
    required this.colors,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    double startAngle = -math.pi / 2; // Start from top

    final paint = Paint()
      ..style = PaintingStyle.fill;

    data.forEach((key, value) {
      if (value > 0) {
        final sweepAngle = (value / total) * 2 * math.pi;
        paint.color = colors[key] ?? Colors.grey;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          true,
          paint,
        );

        // Draw border
        final borderPaint = Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.white
          ..strokeWidth = 2;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          true,
          borderPaint,
        );

        startAngle += sweepAngle;
      }
    });

    // Draw center circle for donut effect
    final centerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    canvas.drawCircle(center, radius * 0.5, centerPaint);

    // Draw total in center
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$total',
        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
