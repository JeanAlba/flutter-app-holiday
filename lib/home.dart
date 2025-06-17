import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterapp/form_course.dart';
import 'package:flutterapp/holidays.dart';
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

  void _refreshCourses() {
    setState(() {
      courses = getCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.grey[900]),
              child: const Text(
                'Menu Principal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.class_outlined, color: Colors.black87),
              title: const Text(
                'Cursos',
                style: TextStyle(color: Colors.black87, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.event_note_outlined,
                color: Colors.black87,
              ),
              title: const Text(
                'Feriados',
                style: TextStyle(color: Colors.black87, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeriadosScreen()),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text(
          "Lista de Cursos",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w300,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.grey[900]?.withOpacity(0.8),
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<CourseModel>>(
        future: courses,
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
                  "Erro ao carregar os cursos. Verifique sua conexão ou tente novamente.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
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
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            );
          }
          return buildCourseList(snapshot.data!);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FormCourse()),
          ).then((value) {
            _refreshCourses();
          });
        },
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildCourseList(List<CourseModel> courses) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 1,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: Colors.black12, width: 1),
          ),
          child: Slidable(
            key: ValueKey(courses[index].id),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
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
                      _refreshCourses();
                    });
                  },
                  icon: Icons.edit,
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  label: "Editar",
                ),
                SlidableAction(
                  onPressed: (context) async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (BuildContext context) => AlertDialog(
                            backgroundColor: Colors.white,
                            title: const Text(
                              'Confirmação',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            content: const Text(
                              'Tem certeza que deseja excluir este Curso?',
                              style: TextStyle(color: Colors.black54),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black87,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Excluir'),
                              ),
                            ],
                          ),
                    );

                    if (confirm == true) {
                      await repository.deleteCourse(courses[index].id!);
                      _refreshCourses();
                    }
                  },
                  icon: Icons.delete,
                  backgroundColor: const Color(0xFFFE4A49),
                  foregroundColor: Colors.white,
                  label: "Excluir",
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        courses[index].name != null &&
                                courses[index].name!.isNotEmpty
                            ? courses[index].name![0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
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
                          courses[index].name ?? 'Curso sem nome',
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
                          courses[index].description ?? 'Sem descrição',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
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
}
