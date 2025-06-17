import 'package:flutter/material.dart';
import 'package:flutterapp/models/course_model.dart';
import 'package:flutterapp/repository/course_repository.dart';
import 'package:intl/intl.dart';

class FormCourse extends StatefulWidget {
  FormCourse({super.key, this.courseEdit});

  final CourseModel? courseEdit;

  @override
  State<FormCourse> createState() => _FormCourseState();
}

class _FormCourseState extends State<FormCourse> {
  String id = "";
  final TextEditingController textNameController = TextEditingController();
  final TextEditingController textDescController = TextEditingController();
  final TextEditingController textStartAtController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  final repository = CourseRepository();

  @override
  void initState() {
    super.initState();
    if (widget.courseEdit != null) {
      textNameController.text = widget.courseEdit?.name ?? '';
      textDescController.text = widget.courseEdit?.description ?? '';
      if (widget.courseEdit?.startAt != null &&
          widget.courseEdit!.startAt!.isNotEmpty) {
        try {
          final dateTime = DateTime.parse(widget.courseEdit!.startAt!);
          textStartAtController.text = DateFormat(
            'dd/MM/yyyy',
          ).format(dateTime);
        } catch (e) {
          textStartAtController.text = 'Data inválida';
        }
      }
      id = widget.courseEdit?.id ?? '';
    }
  }

  @override
  void dispose() {
    textNameController.dispose();
    textDescController.dispose();
    textStartAtController.dispose();
    super.dispose();
  }

  String _formatDatePtBrToApi(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final dateTime = DateTime.utc(year, month, day);
        return dateTime.toIso8601String();
      }
    } catch (e) {
      print('Erro ao formatar data para API: $e');
    }
    return '';
  }

  Future<void> _saveCourse() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final course = CourseModel(
      id: widget.courseEdit != null ? id : null,
      name: textNameController.text,
      description: textDescController.text,
      startAt: _formatDatePtBrToApi(textStartAtController.text),
    );

    try {
      if (widget.courseEdit != null) {
        await repository.putUpdateCourse(course);
      } else {
        await repository.postNewCourse(course);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados salvos com sucesso!'),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar os dados: $e'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String appBarTitle =
        widget.courseEdit != null ? "Editar Curso" : "Novo Curso";

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          appBarTitle,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: textNameController,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
                decoration: InputDecoration(
                  labelText: "Nome do Curso",
                  labelStyle: const TextStyle(color: Colors.black54),
                  hintText: "Ex: Desenvolvimento Web",
                  hintStyle: const TextStyle(color: Colors.black45),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.black12, width: 1),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.black12, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.black87, width: 1.5),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.red, width: 1),
                  ),
                  focusedErrorBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "O nome do curso é obrigatório";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: textDescController,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
                decoration: InputDecoration(
                  labelText: "Descrição do Curso",
                  labelStyle: const TextStyle(color: Colors.black54),
                  hintText: "Detalhes sobre o curso...",
                  hintStyle: const TextStyle(color: Colors.black45),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.black12, width: 1),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.black12, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.black87, width: 1.5),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.red, width: 1),
                  ),
                  focusedErrorBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "A descrição do curso é obrigatória";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: textStartAtController,
                readOnly: true,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
                decoration: InputDecoration(
                  labelText: "Data de Início",
                  labelStyle: const TextStyle(color: Colors.black54),
                  hintText: "Selecione a data",
                  hintStyle: const TextStyle(color: Colors.black45),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.black54,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.black12, width: 1),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.black12, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.black87, width: 1.5),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.red, width: 1),
                  ),
                  focusedErrorBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "A data de início é obrigatória";
                  }
                  return null;
                },
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2030),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Colors.grey,
                            onPrimary: Colors.white,
                            onSurface: Colors.black87,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black87,
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedDate != null) {
                    textStartAtController.text = DateFormat(
                      "dd/MM/yyyy",
                    ).format(pickedDate);
                  }
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveCourse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                      side: BorderSide(color: Colors.black12, width: 1),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: Text(
                    widget.courseEdit != null ? "Atualizar" : "Salvar",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
