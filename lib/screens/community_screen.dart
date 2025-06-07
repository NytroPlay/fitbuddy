import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../models/post.dart';
import '../utils/community_prefs.dart';
import '../utils/group_prefs.dart';
import '../utils/user_prefs.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Post> _posts = [];
  List<String> _joinedGroups = [];
  String? _userName;

  // Datos predeterminados
  final List<Post> _defaultPosts = [
    Post(
      userName: 'María González',
      content:
          '¡Acabo de completar mi rutina de cardio! 🔥 30 minutos de HIIT y me siento increíble. ¿Quién más se anima hoy?',
      date: DateTime.now().subtract(Duration(hours: 2)),
    ),
    Post(
      userName: 'Carlos Ruiz',
      content:
          'Nuevo récord personal en peso muerto: 120kg! 💪 El trabajo duro siempre da frutos.',
      date: DateTime.now().subtract(Duration(hours: 4)),
    ),
    Post(
      userName: 'Ana Martín',
      content:
          'Día de yoga y meditación. A veces el descanso activo es lo que más necesitamos 🧘‍♀️',
      date: DateTime.now().subtract(Duration(hours: 6)),
    ),
  ];

  final List<Map<String, dynamic>> _groups = [
    {
      'name': 'Runners FitBuddy',
      'description': 'Grupo para amantes del running',
      'icon': Icons.directions_run,
      'color': AppColors.primary,
    },
    {
      'name': 'Fuerza y Músculo',
      'description': 'Entrenamientos de fuerza y hipertrofia',
      'icon': Icons.fitness_center,
      'color': AppColors.error,
    },
    {
      'name': 'Yoga y Mindfulness',
      'description': 'Bienestar mental y físico',
      'icon': Icons.self_improvement,
      'color': AppColors.success,
    },
    {
      'name': 'Principiantes',
      'description': 'Para quienes están empezando',
      'icon': Icons.school,
      'color': AppColors.warning,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUser();
    _loadPosts();
    _loadGroups();
  }

  Future<void> _loadUser() async {
    final user = await UserPrefs.loadUser();
    setState(() {
      _userName = user?.name ?? 'Tú';
    });
  }

  Future<void> _loadPosts() async {
    final saved = await CommunityPrefs.loadPosts();
    setState(() {
      _posts = saved;
    });
  }

  Future<void> _savePosts() async {
    await CommunityPrefs.savePosts(_posts);
  }

  Future<void> _addPost(String content, {String? group}) async {
    if (_userName == null) return;
    final post = Post(
      userName: _userName!,
      content: content,
      date: DateTime.now(),
      group: group,
    );
    setState(() {
      _posts.insert(0, post);
    });
    await _savePosts();
  }

  Future<void> _editPost(int index, String newContent) async {
    setState(() {
      _posts[index] = Post(
        userName: _posts[index].userName,
        content: newContent,
        date: DateTime.now(),
        group: _posts[index].group,
      );
    });
    await _savePosts();
  }

  Future<void> _deletePost(int index) async {
    setState(() {
      _posts.removeAt(index);
    });
    await _savePosts();
  }

  Future<void> _loadGroups() async {
    final joined = await GroupPrefs.loadGroups();
    setState(() {
      _joinedGroups = joined;
    });
  }

  Future<void> _joinGroup(String groupName) async {
    if (!_joinedGroups.contains(groupName)) {
      setState(() {
        _joinedGroups.add(groupName);
      });
      await GroupPrefs.saveGroups(_joinedGroups);
    }
  }

  void _showCreatePostDialog({String? group}) {
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.create, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Crear Post', style: TextStyle(color: AppColors.primary)),
            ],
          ),
          content: TextField(
            controller: contentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: '¿Qué quieres compartir?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (contentController.text.isNotEmpty) {
                  await _addPost(contentController.text, group: group);
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Post publicado exitosamente'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text('Publicar'),
            ),
          ],
        );
      },
    );
  }

  void _showEditPostDialog(int index) {
    final contentController = TextEditingController(
      text: _posts[index].content,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar publicación'),
          content: TextField(
            controller: contentController,
            maxLines: 4,
            decoration: InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (contentController.text.isNotEmpty) {
                  await _editPost(index, contentController.text);
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                }
              },
              child: Text('Guardar'),
            ),
            TextButton(
              onPressed: () async {
                await _deletePost(index);
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              },
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Comunidad'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          // ignore: deprecated_member_use
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: [
            Tab(text: 'Feed'),
            Tab(text: 'Ranking'),
            Tab(text: 'Grupos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFeedTab(), _buildLeaderboardTab(), _buildGroupsTab()],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () => _showCreatePostDialog(),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildFeedTab() {
    // Feed: posts predeterminados + posts del usuario (sin grupo)
    final feedPosts = [
      ..._defaultPosts,
      ..._posts.where((p) => p.group == null),
    ];
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => await _loadPosts(),
      child: feedPosts.isEmpty
          ? Center(child: Text('No hay publicaciones aún.'))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: feedPosts.length,
              itemBuilder: (context, index) {
                final post = feedPosts[index];
                final isMine = post.userName == _userName;
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                        post.userName.isNotEmpty ? post.userName[0] : '?',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(post.userName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.content),
                        SizedBox(height: 4),
                        Text(
                          '${post.date.day}/${post.date.month}/${post.date.year} ${post.date.hour}:${post.date.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    trailing: isMine
                        ? PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                final realIndex = _posts.indexWhere(
                                  (p) => p == post,
                                );
                                if (realIndex != -1) {
                                  _showEditPostDialog(realIndex);
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Editar / Eliminar'),
                              ),
                            ],
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }

  Widget _buildLeaderboardTab() {
    final leaderboard = [
      {'name': 'Carlos Ruiz', 'points': 1250},
      {'name': 'María González', 'points': 1180},
      {'name': 'Ana Martín', 'points': 1050},
      {'name': 'Luis Torres', 'points': 980},
      {'name': 'Sofia López', 'points': 920},
    ];
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: leaderboard.length,
      itemBuilder: (context, index) {
        final user = leaderboard[index] as Map<String, dynamic>;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text(user['name'][0]),
          ),
          title: Text(user['name'] as String),
          trailing: Text(
            '${user['points']} pts',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  Widget _buildGroupsTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _groups.length,
      itemBuilder: (context, index) {
        final group = _groups[index];
        final joined = _joinedGroups.contains(group['name']);
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: group['color'],
              child: Icon(group['icon'], color: Colors.white),
            ),
            title: Text(group['name']),
            subtitle: Text(group['description']),
            trailing: joined
                ? ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroupPostsScreen(
                            groupName: group['name'],
                            userName: _userName ?? 'Tú',
                            posts: _posts,
                            onAddPost: (content) async {
                              await _addPost(content, group: group['name']);
                            },
                          ),
                        ),
                      );
                    },
                    child: Text('Entrar'),
                  )
                : ElevatedButton(
                    onPressed: () async {
                      await _joinGroup(group['name']);
                      setState(() {});
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Te has unido a ${group['name']}'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    child: Text('Unirse'),
                  ),
          ),
        );
      },
    );
  }
}

// Pantalla para ver y publicar en un grupo
class GroupPostsScreen extends StatefulWidget {
  final String groupName;
  final String userName;
  final List<Post> posts;
  final Future<void> Function(String content) onAddPost;

  const GroupPostsScreen({
    super.key,
    required this.groupName,
    required this.userName,
    required this.posts,
    required this.onAddPost,
  });

  @override
  State<GroupPostsScreen> createState() => _GroupPostsScreenState();
}

class _GroupPostsScreenState extends State<GroupPostsScreen> {
  @override
  Widget build(BuildContext context) {
    final groupPosts = widget.posts
        .where((p) => p.group == widget.groupName)
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        backgroundColor: AppColors.primary,
      ),
      body: groupPosts.isEmpty
          ? Center(child: Text('No hay publicaciones en este grupo.'))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: groupPosts.length,
              itemBuilder: (context, index) {
                final post = groupPosts[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                        post.userName.isNotEmpty ? post.userName[0] : '?',
                      ),
                    ),
                    title: Text(post.userName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.content),
                        SizedBox(height: 4),
                        Text(
                          '${post.date.day}/${post.date.month}/${post.date.year} ${post.date.hour}:${post.date.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final contentController = TextEditingController();
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Nueva publicación'),
              content: TextField(
                controller: contentController,
                maxLines: 4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '¿Qué quieres compartir en el grupo?',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (contentController.text.isNotEmpty) {
                      await widget.onAddPost(contentController.text);
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                      setState(() {});
                    }
                  },
                  child: Text('Publicar'),
                ),
              ],
            ),
          );
          setState(() {});
        },
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add),
      ),
    );
  }
}
