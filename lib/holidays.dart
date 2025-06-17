import 'package:flutter/material.dart';
import 'package:flutterapp/models/holidays_model.dart';
import 'package:flutterapp/repository/holidays_repository.dart';

class FeriadosScreen extends StatefulWidget {
  @override
  _FeriadosScreenState createState() => _FeriadosScreenState();
}

class _FeriadosScreenState extends State<FeriadosScreen> {
  late Future<List<HolidaysModel>> feriados;

  @override
  void initState() {
    super.initState();
    feriados = FeriadoService().getFeriados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Feriados Nacionais 2023")),
      body: FutureBuilder<List<HolidaysModel>>(
        future: feriados,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Nenhum feriado encontrado."));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final feriado = snapshot.data![index];
                return ListTile(
                  leading: Icon(Icons.flag),
                  title: Text(feriado.name ?? ''),
                  subtitle: Text(feriado.date ?? ''),
                );
              },
            );
          }
        },
      ),
    );
  }
}
