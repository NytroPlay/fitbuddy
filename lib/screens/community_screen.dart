import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Datos de ejemplo para posts
  final List<Map<String, dynamic>> _posts = [
    {
      'user': 'María González',
      'avatar': 'M',
      'time': 'Hace 2 horas',
      'content':
          '¡Acabo de completar mi rutina de cardio! 🔥 30 minutos de HIIT y me siento increíble. ¿Quién más se anima hoy?',
      'likes': 15,
      'comments': 3,
      'liked': false,
      'type': 'workout',
      'workout': 'Cardio HIIT - 30 min',
      'calories': 280,
    },
    {
      'user': 'Carlos Ruiz',
      'avatar': 'C',
      'time': 'Hace 4 horas',
      'content':
          'Nuevo récord personal en peso muerto: 120kg! 💪 El trabajo duro siempre da frutos.',
      'likes': 28,
      'comments': 7,
      'liked': true,
      'type': 'achievement',
      'achievement': 'Nuevo PR en Peso Muerto',
      'weight': '120kg',
    },
    {
      'user': 'Ana Martín',
      'avatar': 'A',
      'time': 'Hace 6 horas',
      'content':
          'Día de yoga y meditación. A veces el descanso activo es lo que más necesitamos 🧘‍♀️',
      'likes': 12,
      'comments': 2,
      'liked': false,
      'type': 'wellness',
    },
  ];

  // Datos de ejemplo para leaderboard
  final List<Map<String, dynamic>> _leaderboard = [
    {'name': 'Carlos Ruiz', 'points': 1250, 'avatar': 'C', 'rank': 1},
    {'name': 'María González', 'points': 1180, 'avatar': 'M', 'rank': 2},
    {'name': 'Ana Martín', 'points': 1050, 'avatar': 'A', 'rank': 3},
    {'name': 'Luis Torres', 'points': 980, 'avatar': 'L', 'rank': 4},
    {'name': 'Sofia López', 'points': 920, 'avatar': 'S', 'rank': 5},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Notificaciones próximamente'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
          ),
        ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildFeedTab() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await Future.delayed(Duration(seconds: 1));
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Feed actualizado'),
            backgroundColor: AppColors.success,
          ),
        );
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return _buildPostCard(_posts[index], index);
        },
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Header del ranking
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRankingStat('Tu posición', '#8', Icons.emoji_events),
                _buildRankingStat('Puntos', '850', Icons.star),
                _buildRankingStat('Esta semana', '+120', Icons.trending_up),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Top 3
          Container(
            padding: EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top 3 de la Semana',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPodiumPosition(_leaderboard[1], 2),
                    _buildPodiumPosition(_leaderboard[0], 1),
                    _buildPodiumPosition(_leaderboard[2], 3),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Lista completa del ranking
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Ranking Completo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                ...List.generate(_leaderboard.length, (index) {
                  return _buildRankingItem(_leaderboard[index]);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsTab() {
    final groups = [
      {
        'name': 'Runners FitBuddy',
        'members': 245,
        'description': 'Grupo para amantes del running',
        'icon': Icons.directions_run,
        'color': AppColors.primary,
      },
      {
        'name': 'Fuerza y Músculo',
        'members': 189,
        'description': 'Entrenamientos de fuerza y hipertrofia',
        'icon': Icons.fitness_center,
        'color': AppColors.error,
      },
      {
        'name': 'Yoga y Mindfulness',
        'members': 156,
        'description': 'Bienestar mental y físico',
        'icon': Icons.self_improvement,
        'color': AppColors.success,
      },
      {
        'name': 'Principiantes',
        'members': 312,
        'description': 'Para quienes están empezando',
        'icon': Icons.school,
        'color': AppColors.warning,
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
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
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${group['members']} miembros',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
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
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildPostCard(Map<String, dynamic> post, int index) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del post
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    post['avatar'],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['user'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        post['time'],
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Contenido del post
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post['content'],
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),

          // Información adicional según el tipo
          if (post['type'] == 'workout') ...[
            SizedBox(height: 12),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.fitness_center,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      post['workout'],
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '${post['calories']} cal',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (post['type'] == 'achievement') ...[
            SizedBox(height: 12),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.emoji_events, color: AppColors.warning, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      post['achievement'],
                      style: TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    post['weight'],
                    style: TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Acciones del post
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      post['liked'] = !post['liked'];
                      if (post['liked']) {
                        post['likes']++;
                      } else {
                        post['likes']--;
                      }
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        post['liked'] ? Icons.favorite : Icons.favorite_border,
                        color: post['liked']
                            ? AppColors.error
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${post['likes']}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 24),
                Row(
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${post['comments']}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Icon(
                  Icons.share_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          // ignore: deprecated_member_use
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildPodiumPosition(Map<String, dynamic> user, int position) {
    final colors = [
      AppColors.warning,
      AppColors.textSecondary,
      // ignore: deprecated_member_use
      AppColors.warning.withOpacity(0.7),
    ];
    final heights = [80.0, 100.0, 70.0];

    return Column(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.primary,
          radius: position == 1 ? 30 : 25,
          child: Text(
            user['avatar'],
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: position == 1 ? 20 : 16,
            ),
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: 60,
          height: heights[position - 1],
          decoration: BoxDecoration(
            color: colors[position - 1],
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#$position',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                '${user['points']}',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          user['name'].split(' ')[0],
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildRankingItem(Map<String, dynamic> user) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: user['rank'] <= 3
                  ? AppColors.primary
                  : AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${user['rank']}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          CircleAvatar(
            // ignore: deprecated_member_use
            backgroundColor: AppColors.primary.withOpacity(0.1),
            radius: 20,
            child: Text(
              user['avatar'],
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              user['name'],
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '${user['points']} pts',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
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
              onPressed: () {
                if (contentController.text.isNotEmpty) {
                  Navigator.of(context).pop();
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

extension on Object? {
  withOpacity(double d) {}
}
