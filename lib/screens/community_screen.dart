// lib/screens/community_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';
import '../models/post.dart';
import '../utils/community_prefs.dart';
import '../utils/group_prefs.dart';
import '../utils/user_prefs.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  List<Post> _posts = [];
  List<String> _joinedGroups = [];
  String? _userName;
  String? _userAvatar;
  String? _userEmail;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        setState(() => _selectedTab = _tabController.index);
      });
    _loadUser();
    _loadPosts();
    _loadGroups();
  }

  Future<void> _loadUser() async {
    final user = await UserPrefs.loadUser();
    final avatar = await UserPrefs.getProfileImage();
    setState(() {
      _userName = user?.name ?? 'Tú';
      _userAvatar = avatar;
      _userEmail = user?.email;
    });
  }

  Future<void> _loadPosts() async {
    final saved = await CommunityPrefs.loadPosts();
    setState(() => _posts = saved);
  }

  Future<void> _savePosts() async {
    await CommunityPrefs.savePosts(_posts);
  }

  Future<void> _addPost(String content, {String? group}) async {
    if (_userName == null) return;
    final now = DateTime.now();
    if (_posts.isNotEmpty &&
        _posts.first.content == content &&
        now.difference(_posts.first.date).inSeconds < 2) {
      return;
    }
    final post = Post(
      userName: _userName!,
      content: content,
      date: now,
      avatar: _userAvatar,
      email: _userEmail,
      likes: 0,
      liked: false,
      comments: [],
      group: group,
    );
    setState(() => _posts.insert(0, post));
    await _savePosts();
  }

  Future<void> _editPost(int index, String newContent) async {
    final orig = _posts[index];
    final updated = Post(
      userName: orig.userName,
      content: newContent,
      date: DateTime.now(),
      avatar: orig.avatar,
      email: orig.email,
      likes: orig.likes,
      liked: orig.liked,
      comments: List.from(orig.comments),
      group: orig.group,
    );
    setState(() => _posts[index] = updated);
    await _savePosts();
  }

  Future<void> _deletePost(int index) async {
    setState(() => _posts.removeAt(index));
    await _savePosts();
  }

  Future<void> _loadGroups() async {
    final joined = await GroupPrefs.loadGroups();
    setState(() => _joinedGroups = joined);
  }

  Future<void> _joinGroup(String groupName) async {
    if (!_joinedGroups.contains(groupName)) {
      setState(() => _joinedGroups.add(groupName));
      await GroupPrefs.saveGroups(_joinedGroups);
    }
  }

  void _showCreatePostDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.edit, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Crear Post',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: '¿Qué quieres compartir?',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: AppColors.error)),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = ctrl.text.trim();
              if (text.isNotEmpty) {
                await _addPost(text);
                if (!mounted) return;
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Publicar'),
          ),
        ],
      ),
    );
  }

  void _showCommentsDialog(int postIndex) {
    final post = _posts[postIndex];
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Comentarios',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              if (post.comments.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    itemCount: post.comments.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, i) => ListTile(
                      leading: Icon(
                        Icons.comment,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      title: Text(post.comments[i]),
                    ),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('Aún no hay comentarios'),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                decoration: InputDecoration(
                  hintText: 'Tu comentario...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  final text = ctrl.text.trim();
                  if (text.isNotEmpty) {
                    setState(() => post.comments.add(text));
                    _savePosts();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Enviar'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(Post p) {
    if (p.avatar != null && p.avatar!.isNotEmpty) {
      if (p.avatar!.startsWith('avatar:')) {
        return CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            p.avatar!.substring(7),
            style: const TextStyle(fontSize: 24),
          ),
        );
      } else if (File(p.avatar!).existsSync()) {
        return CircleAvatar(
          backgroundColor: AppColors.primary,
          backgroundImage: FileImage(File(p.avatar!)),
        );
      }
    }
    return CircleAvatar(
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.fitness_center, color: Colors.white),
    );
  }

  Widget _buildFeedTab() {
    return RefreshIndicator(
      onRefresh: _loadPosts,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _posts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final p = _posts[i];
          final mine = p.email == _userEmail;
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xfff6f9f6),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: AppColors.primary.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildAvatar(p),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        p.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      DateFormat('d/M/yyyy H:mm').format(p.date),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    if (mine)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20),
                        onSelected: (v) => v == 'edit'
                            ? _editPost(i, p.content)
                            : _deletePost(i),
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Editar')),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Eliminar'),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(p.content),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (!p.liked) {
                          setState(() {
                            p.liked = true;
                            p.likes += 1;
                          });
                          _savePosts();
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: p.liked ? Colors.red : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text('${p.likes}'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () => _showCommentsDialog(i),
                      child: Row(
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text('${p.comments.length}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRankingTab() {
    final lb = [
      {'name': 'Carlos Ruiz', 'pts': 1250},
      {'name': 'María González', 'pts': 1180},
      {'name': 'Ana Martín', 'pts': 1050},
      {'name': 'Luis Torres', 'pts': 980},
      {'name': 'Sofia López', 'pts': 920},
    ];
    final medals = [
      const Color(0xFFF4C542),
      const Color(0xFFB0B7C3),
      const Color(0xFFE27B36),
      AppColors.primary,
      // ignore: deprecated_member_use
      AppColors.primary.withOpacity(0.8),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: lb.length,
      itemBuilder: (_, i) {
        final entry = lb[i];
        final name = entry['name'] as String;
        final pts = entry['pts'] as int;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: medals[i], width: 1),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: medals[i].withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: medals[i],
              child: Text(name[0], style: const TextStyle(color: Colors.white)),
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              '$pts pts',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupsTab() {
    final groups = [
      {
        'name': 'Runners FitBuddy',
        'desc': 'Para amantes del running',
        'icon': Icons.directions_run,
        'color': AppColors.primary,
      },
      {
        'name': 'Fuerza y Músculo',
        'desc': 'Entrenamientos de fuerza',
        'icon': Icons.fitness_center,
        'color': AppColors.error,
      },
      {
        'name': 'Yoga y Mindfulness',
        'desc': 'Bienestar mental y físico',
        'icon': Icons.self_improvement,
        'color': AppColors.success,
      },
      {
        'name': 'Principiantes',
        'desc': 'Iniciando tu viaje',
        'icon': Icons.school,
        'color': AppColors.warning,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: groups.length,
      itemBuilder: (_, i) {
        final g = groups[i];
        final joined = _joinedGroups.contains(g['name']);
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: g['color'] as Color,
              child: Icon(g['icon'] as IconData, color: Colors.white),
            ),
            title: Text(g['name'] as String),
            subtitle: Text(g['desc'] as String),
            trailing: ElevatedButton(
              onPressed: () {
                if (!joined) {
                  _joinGroup(g['name'] as String);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupPostsScreen(
                        groupName: g['name'] as String,
                        userName: _userName ?? 'Tú',
                        posts: _posts,
                        onAddPost: _addPost,
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: joined
                    ? AppColors.primary
                    // ignore: deprecated_member_use
                    : AppColors.primary.withOpacity(0.7),
              ),
              child: Text(joined ? 'Entrar' : 'Unirse'),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Comunidad'),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Feed'),
            Tab(text: 'Ranking'),
            Tab(text: 'Grupos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFeedTab(), _buildRankingTab(), _buildGroupsTab()],
      ),
      floatingActionButton: _selectedTab == 0
          ? FloatingActionButton(
              onPressed: _showCreatePostDialog,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

/// ---------------------------------------------
/// Pantalla de posts de un grupo
/// ---------------------------------------------
class GroupPostsScreen extends StatefulWidget {
  final String groupName;
  final String userName;
  final List<Post> posts;
  final Future<void> Function(String content, {String? group}) onAddPost;

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
  Future<void> _showCreateInGroupDialog() async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.edit, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Nueva publicación',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: '¿Qué quieres compartir en el grupo?',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: AppColors.error)),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = ctrl.text.trim();
              if (text.isNotEmpty) {
                await widget.onAddPost(text, group: widget.groupName);
                if (!mounted) return;
                Navigator.pop(context);
                setState(() {});
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Publicar'),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(Post p) {
    if (p.avatar != null && p.avatar!.isNotEmpty) {
      if (p.avatar!.startsWith('avatar:')) {
        return CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            p.avatar!.substring(7),
            style: const TextStyle(fontSize: 24),
          ),
        );
      } else if (File(p.avatar!).existsSync()) {
        return CircleAvatar(
          backgroundColor: AppColors.primary,
          backgroundImage: FileImage(File(p.avatar!)),
        );
      }
    }
    return CircleAvatar(
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.fitness_center, color: Colors.white),
    );
  }

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
          ? const Center(child: Text('No hay publicaciones en este grupo.'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: groupPosts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final p = groupPosts[i];
                final mine = p.email == widget.userName;
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xfff6f9f6),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: AppColors.primary.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildAvatar(p),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              p.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            DateFormat('d/M/yyyy H:mm').format(p.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (mine)
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 20),
                              onSelected: (v) {
                                if (v == 'edit') {
                                  // por simplicidad llamamos _editPost con contenido actual
                                  _editPost(widget.posts.indexOf(p), p.content);
                                } else {
                                  _deletePost(widget.posts.indexOf(p));
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Editar'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Eliminar'),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(p.content),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (!p.liked) {
                                setState(() {
                                  p.liked = true;
                                  p.likes += 1;
                                });
                                CommunityPrefs.savePosts(widget.posts);
                              }
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.favorite,
                                  color: p.liked ? Colors.red : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text('${p.likes}'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          GestureDetector(
                            onTap: () {
                              // podrías reutilizar _showCommentsDialog
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.comment_outlined,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text('${p.comments.length}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateInGroupDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ignore: camel_case_types
class _deletePost {
  _deletePost(int indexOf);
}

// ignore: camel_case_types
class _editPost {
  _editPost(int indexOf, String content);
}
