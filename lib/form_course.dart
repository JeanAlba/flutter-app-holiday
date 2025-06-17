import 'package:flutter/material.dart';
import 'package:flutterapp/models/course_model.dart';
import 'package:flutterapp/repository/course_repository.dart';
import 'package:intl/intl.dart';

class FormCourse extends StatefulWidget {
  FormCourse({super.key, this.courseEdit});

  final CourseModel?
  courseEdit; // Alterado para 'final' pois não será reatribuído

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
      // A data precisa ser formatada de volta para dd/MM/yyyy ao carregar para edição
      // Assumindo que widget.courseEdit.startAt vem em formato ISO 8601 (yyyy-MM-ddTHH:mm:ss.SSSZ)
      if (widget.courseEdit?.startAt != null &&
          widget.courseEdit!.startAt!.isNotEmpty) {
        try {
          final dateTime = DateTime.parse(widget.courseEdit!.startAt!);
          textStartAtController.text = DateFormat(
            'dd/MM/yyyy',
          ).format(dateTime);
        } catch (e) {
          textStartAtController.text =
              'Data inválida'; // Tratar erro de parse, se houver
        }
      }
      id = widget.courseEdit?.id ?? '';
    }
  }

  @override
  void dispose() {
    // Descartar os controladores quando o widget for removido da árvore
    textNameController.dispose();
    textDescController.dispose();
    textStartAtController.dispose();
    super.dispose();
  }

  // Função para converter data de dd/MM/yyyy para yyyy-MM-ddTHH:mm:ss.SSSZ
  String _formatDatePtBrToApi(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        // Usar DateTime.utc para garantir que a data seja tratada como UTC ao ser formatada para ISO 8601
        final dateTime = DateTime.utc(year, month, day);
        return dateTime.toIso8601String(); // Formato esperado pela API
      }
    } catch (e) {
      // Em caso de erro na conversão, você pode querer retornar algo ou lançar um erro
      print('Erro ao formatar data para API: $e');
    }
    return ''; // Retorna vazio em caso de falha
  }

  Future<void> _saveCourse() async {
    if (!formKey.currentState!.validate()) {
      return; // Se a validação falhar, não faz nada
    }

    final course = CourseModel(
      id: widget.courseEdit != null ? id : null, // ID apenas para atualização
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
      Navigator.pop(context); // Volta para a tela anterior
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar os dados: $e'),
          backgroundColor: Colors.red[700], // Fundo vermelho para erros
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
      backgroundColor: Colors.grey[100], // Fundo cinza claro
      appBar: AppBar(
        title: Text(
          appBarTitle, // Título dinâmico (Editar ou Novo)
          style: const TextStyle(
            color: Colors.white, // Texto do título branco
            fontWeight: FontWeight.w300, // Fonte light
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.grey[900]?.withOpacity(
          0.8,
        ), // AppBar cinza escuro transparente
        elevation: 0, // Sem sombra
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ), // Seta de voltar branca
          onPressed: () {
            Navigator.pop(context); // Volta para a tela anterior
          },
        ),
      ),
      body: SingleChildScrollView(
        // Permite rolar o formulário
        padding: const EdgeInsets.all(24.0), // Padding geral para o formulário
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Estica os campos horizontalmente
            children: [
              // Campo Nome do Curso
              TextFormField(
                controller: textNameController,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
                decoration: InputDecoration(
                  labelText: "Nome do Curso", // Label flutuante
                  labelStyle: const TextStyle(
                    color: Colors.black54,
                  ), // Estilo do label
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
                    // Borda para erro
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.red, width: 1),
                  ),
                  focusedErrorBorder: const OutlineInputBorder(
                    // Borda para erro focado
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

              // Campo Descrição do Curso
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
                maxLines: 3, // Permite múltiplas linhas para a descrição
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "A descrição do curso é obrigatória";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Data de Início
              TextFormField(
                controller: textStartAtController,
                readOnly: true, // Impede a digitação direta no campo de data
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
                  ), // Ícone de calendário
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
                  // O `async` é importante para usar await no showDatePicker
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(
                      2000,
                    ), // Permite datas passadas para edição
                    lastDate: DateTime(2030),
                    builder: (context, child) {
                      return Theme(
                        // Estiliza o DatePicker
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Colors.grey, // Cor principal do DatePicker
                            onPrimary:
                                Colors
                                    .white, // Cor do texto/ícones na cor primária
                            onSurface:
                                Colors
                                    .black87, // Cor dos dias/texto no calendário
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  Colors
                                      .black87, // Cor dos botões "Cancelar" e "OK"
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
              const SizedBox(
                height: 32,
              ), // Espaçamento antes do botão de salvar
              // Botão Salvar
              SizedBox(
                height: 50,
                width: double.infinity, // Ocupa a largura total disponível
                child: ElevatedButton(
                  onPressed:
                      _saveCourse, // Chama a função unificada de salvar/atualizar
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.grey[900], // Fundo do botão cinza escuro
                    foregroundColor: Colors.white, // Texto do botão branco
                    elevation: 0, // Sem sombra
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // Bordas retas
                      side: BorderSide(
                        color: Colors.black12,
                        width: 1,
                      ), // Borda sutil
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: Text(
                    widget.courseEdit != null ? "Atualizar" : "Salvar",
                  ), // Texto dinâmico
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
