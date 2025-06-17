import 'package:flutter/material.dart';
import 'package:flutterapp/models/holidays_model.dart';
import 'package:flutterapp/repository/holidays_repository.dart';
import 'package:intl/intl.dart';

class FeriadosScreen extends StatefulWidget {
  @override
  _FeriadosScreenState createState() => _FeriadosScreenState();
}

class _FeriadosScreenState extends State<FeriadosScreen> {
  late Future<List<HolidaysModel>> feriados;
  int _selectedYear = 2023;

  @override
  void initState() {
    super.initState();
    _loadHolidays();
  }

  void _loadHolidays() {
    feriados = FeriadoService().getFeriados(year: _selectedYear);
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Data indisponível';
    }
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return 'Data inválida: $dateString';
    }
  }

  Future<void> _showYearPicker() async {
    final int currentYear = DateTime.now().year;
    List<int> years = List<int>.generate(10, (index) => currentYear - index);

    int? selected = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Selecionar Ano',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: years.length,
              itemBuilder: (context, index) {
                final year = years[index];
                return ListTile(
                  title: Text(
                    year.toString(),
                    style: TextStyle(
                      color:
                          year == _selectedYear
                              ? Colors.grey[900]
                              : Colors.black54,
                      fontWeight:
                          year == _selectedYear
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context, year);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
        );
      },
    );

    if (selected != null && selected != _selectedYear) {
      setState(() {
        _selectedYear = selected;
      });
      _loadHolidays();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Feriados Nacionais $_selectedYear",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w300,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.grey[900]?.withOpacity(0.8),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<HolidaysModel>>(
        future: feriados,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "Erro ao carregar os feriados. Verifique sua conexão ou tente novamente. Erro: ${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "Nenhum feriado encontrado para o ano de $_selectedYear.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final feriado = snapshot.data![index];
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 1,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(color: Colors.black12, width: 1),
                  ),
                  child: InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.calendar_month_outlined,
                            color: Colors.black54,
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  feriado.name ?? 'Feriado sem nome',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 17,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(feriado.date),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black38,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showYearPicker,
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        child: const Icon(Icons.calendar_today_outlined),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
