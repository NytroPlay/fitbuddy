import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../models/post.dart';
import '../utils/community_prefs.dart';
import '../utils/user_prefs.dart';
import '../models/user.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Post> _posts = [];
  List<String> _joinedGroups = [];

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
    _loadPosts();
    _loadGroups();
  }

  Future<void> _loadPosts() async {
    _posts = await CommunityPrefs.loadPosts();
    setState(() {});
  }

  Future<void> _savePosts() async {
    await CommunityPrefs.savePosts(_posts);
  }

  Future<void> _addPost(String content) async {
    final user = await UserPrefs.loadUser();
    if (user == null) return;
    final post = Post(
      userName: user.name,
      content: content,
      date: DateTime.now(),
    );
    _posts.insert(0, post);
    await _savePosts();
    setState(() {});
  }

  Future<void> _loadGroups() async {
    // Puedes usar shared_preferences para guardar los grupos a los que se unió el usuario
    // Aquí lo hacemos simple con memoria local, pero puedes expandirlo
    setState(() {});
  }

  Future<void> _joinGroup(String groupName) async {
    if (!_joinedGroups.contains(groupName)) {
      setState(() {
        _joinedGroups.add(groupName);
      });
      // Aquí puedes guardar en shared_preferences si quieres persistencia real
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              onPressed: _showCreatePostDialog,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildFeedTab() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await _loadPosts();
      },
      child: _posts.isEmpty
          ? Center(child: Text('No hay posts aún. ¡Crea el primero!'))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return _buildPostCard(post);
              },
            ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            post.userName.isNotEmpty ? post.userName[0] : '?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          post.userName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.content),
            SizedBox(height: 4),
            Text(
              '${post.date.day}/${post.date.month}/${post.date.year} ${post.date.hour}:${post.date.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    // Puedes dejar tu leaderboard de ejemplo aquí
    return Center(child: Text('Ranking próximamente'));
  }

  Widget _buildGroupsTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _groups.length,
      itemBuilder: (context, index) {
        final group = _groups[index];
        final joined = _joinedGroups.contains(group['name']);
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: group['color']?.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  group['icon'] as IconData?,
                  color: group['color'] as Color,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group['name'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      group['description'] as String,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              joined
                  ? Text(
                      'Unido',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        _joinGroup(group['name']);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Te has unido a ${group['name']}'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: group['color'] as Color,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Unirse', style: TextStyle(fontSize: 12)),
                    ),
            ],
          ),
        );
      },
    );
  }

  void _showCreatePostDialog() {
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
              hintText: '¿Qué quieres compartir con la comunidad?',
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
                  await _addPost(contentController.text);
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
}
