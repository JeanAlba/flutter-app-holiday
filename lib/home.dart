import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterapp/form_course.dart';
import 'package:flutterapp/holidays.dart'; // Certifique-se que FeriadosScreen está sendo importado corretamente.
import 'package:flutterapp/models/course_model.dart';
import 'package:flutterapp/repository/course_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final repository = CourseRepository();
  late Future<List<CourseModel>> courses;

  Future<List<CourseModel>> getCourses() async {
    return await repository.getAll();
  }

  @override
  void initState() {
    courses = getCourses();
    super.initState();
  }

  // Refatorando a função de atualização para ser mais limpa
  void _refreshCourses() {
    setState(() {
      courses = getCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Fundo da tela cinza claro
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              // Estilo do cabeçalho do Drawer
              decoration: BoxDecoration(
                color: Colors.grey[900],
              ), // Fundo cinza escuro
              child: const Text(
                'Menu Principal', // Título do Drawer
                style: TextStyle(
                  color: Colors.white, // Texto branco
                  fontSize: 24,
                  fontWeight: FontWeight.w400, // Fonte light
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.class_outlined,
                color: Colors.black87,
              ), // Ícone para cursos
              title: const Text(
                'Cursos',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ), // Texto preto quase total
              ),
              onTap: () {
                Navigator.pop(context); // Fecha o Drawer
                // Não precisa navegar para HomePage se já está nela
                // Se esta HomePage não é a raiz, você poderia usar Navigator.popUntil
                // ou apenas fechar o drawer.
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.event_note_outlined,
                color: Colors.black87,
              ), // Ícone para feriados
              title: const Text(
                'Feriados',
                style: TextStyle(color: Colors.black87, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context); // Fecha o Drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeriadosScreen()),
                );
              },
            ),
            // Você pode adicionar mais itens de menu aqui, seguindo o mesmo estilo
            // ListTile(
            //   leading: const Icon(Icons.settings_outlined, color: Colors.black87),
            //   title: const Text('Configurações', style: TextStyle(color: Colors.black87, fontSize: 16)),
            //   onTap: () {
            //     Navigator.pop(context);
            //     // Navegar para a tela de configurações
            //   },
            // ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text(
          "Lista de Cursos", // Título da AppBar
          style: TextStyle(
            color: Colors.white, // Texto do título branco
            fontWeight: FontWeight.w300, // Fonte light
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.grey[900]?.withOpacity(
          0.8,
        ), // AppBar cinza escuro transparente
        elevation: 0,
        centerTitle: true,
        //leading: O ícone do Drawer (hamburguer) já é o leading padrão,
        // então não precisamos definir um IconButton aqui a menos que queira um customizado.
      ),
      body: FutureBuilder<List<CourseModel>>(
        future: courses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.black54,
                ), // Cor cinza para o indicador
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "Erro ao carregar os cursos. Verifique sua conexão ou tente novamente.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ), // Texto de erro cinza escuro
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  "Nenhum curso encontrado. Que tal adicionar um?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54, // Texto de vazio cinza escuro
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            );
          }
          return buildCourseList(snapshot.data!); // Passando a lista não-nula
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FormCourse()),
          ).then((value) {
            _refreshCourses(); // Atualiza a lista após retornar do formulário
          });
        },
        backgroundColor: Colors.grey[900], // Fundo do FAB cinza escuro
        foregroundColor: Colors.white, // Ícone do FAB branco
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildCourseList(List<CourseModel> courses) {
    // Especificando o tipo da lista
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white, // Fundo do Card branco
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 1, // Sombra sutil
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Bordas retas
            side: BorderSide(
              color: Colors.black12,
              width: 1,
            ), // Borda fina e clara
          ),
          child: Slidable(
            key: ValueKey(
              courses[index].id,
            ), // Usar uma chave única é importante para Slidable
            endActionPane: ActionPane(
              motion: const ScrollMotion(), // const para otimização
              children: [
                SlidableAction(
                  onPressed: (context) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => FormCourse(courseEdit: courses[index]),
                      ),
                    ).then((value) {
                      _refreshCourses(); // Atualiza a lista após edição
                    });
                  },
                  icon: Icons.edit,
                  backgroundColor: Colors.black, // Cor de fundo da ação Editar
                  foregroundColor: Colors.white, // Cor do ícone e texto da ação
                  label: "Editar",
                ),
                SlidableAction(
                  onPressed: (context) async {
                    final confirm = await showDialog<bool>(
                      // Usando bool para o resultado do dialog
                      context: context,
                      builder:
                          (BuildContext context) => AlertDialog(
                            backgroundColor:
                                Colors.white, // Fundo do AlertDialog branco
                            title: const Text(
                              'Confirmação',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            content: const Text(
                              'Tem certeza que deseja excluir este Curso?', // Texto da confirmação
                              style: TextStyle(color: Colors.black54),
                            ),
                            actions: [
                              TextButton(
                                // Usando TextButton para botões mais minimalistas
                                onPressed:
                                    () => Navigator.pop(
                                      context,
                                      false,
                                    ), // Retorna false ao cancelar
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                              ElevatedButton(
                                // Mantendo ElevatedButton para o "OK" para dar mais destaque
                                onPressed:
                                    () => Navigator.pop(
                                      context,
                                      true,
                                    ), // Retorna true ao confirmar
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors
                                          .black87, // Fundo do botão OK preto quase total
                                  foregroundColor:
                                      Colors.white, // Texto do botão OK branco
                                ),
                                child: const Text(
                                  'Excluir',
                                ), // Texto mais direto para a ação
                              ),
                            ],
                          ),
                    );

                    if (confirm == true) {
                      // Verifica se a confirmação foi positiva
                      await repository.deleteCourse(courses[index].id!);
                      _refreshCourses(); // Atualiza a lista após exclusão
                    }
                  },
                  icon: Icons.delete,
                  backgroundColor: const Color(
                    0xFFFE4A49,
                  ), // Cor de fundo da ação Excluir (vermelho padrão Slidable) ou Colors.black para manter o padrão. Usei um vermelho para indicar deleção.
                  foregroundColor: Colors.white,
                  label: "Excluir",
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Padding interno do Card
              child: Row(
                children: <Widget>[
                  // Substituindo CircleAvatar por um ícone estilizado ou texto inicial simples
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          Colors
                              .grey[200], // Fundo claro para o ícone/texto inicial
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        courses[index].name != null &&
                                courses[index].name!.isNotEmpty
                            ? courses[index].name![0]
                                .toUpperCase() // Pega a primeira letra
                            : '?', // Caso o nome esteja vazio
                        style: const TextStyle(
                          color: Colors.black87, // Cor do texto inicial
                          fontWeight: FontWeight.w600, // Negrito
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          courses[index].name ??
                              'Curso sem nome', // Texto padrão
                          style: const TextStyle(
                            fontWeight: FontWeight.w400, // Fonte light
                            fontSize: 17,
                            color: Colors.black87, // Texto quase preto
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          courses[index].description ??
                              'Sem descrição', // Texto padrão
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54, // Cinza para o subtítulo
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black38, // Seta de avanço em cinza claro
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
}
