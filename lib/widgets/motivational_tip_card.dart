import 'package:flutter/material.dart';
import '../models/motivational_tip.dart';
import '../services/motivational_tips_service.dart';
import '../utils/app_theme.dart';

enum TipDisplayStyle {
  card,
  banner,
  snackbar,
}

class MotivationalTipCard extends StatefulWidget {
  final MotivationalTip tip;
  final TipDisplayStyle style;
  final VoidCallback? onDismiss;
  final bool isDismissible;
  final EdgeInsets? margin;

  const MotivationalTipCard({
    Key? key,
    required this.tip,
    this.style = TipDisplayStyle.card,
    this.onDismiss,
    this.isDismissible = true,
    this.margin,
  }) : super(key: key);

  @override
  State<MotivationalTipCard> createState() => _MotivationalTipCardState();
}

class _MotivationalTipCardState extends State<MotivationalTipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismissTip() async {
    if (!widget.isDismissible) return;

    await _animationController.reverse();
    await MotivationalTipsService.dismissTip(widget.tip.id);
    
    if (mounted) {
      setState(() {
        _isVisible = false;
      });
      if (widget.onDismiss != null) {
        widget.onDismiss!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildTipWidget(),
          ),
        );
      },
    );
  }

  Widget _buildTipWidget() {
    switch (widget.style) {
      case TipDisplayStyle.banner:
        return _buildBannerStyle();
      case TipDisplayStyle.snackbar:
        return _buildSnackbarStyle();
      case TipDisplayStyle.card:
      default:
        return _buildCardStyle();
    }
  }

  Widget _buildCardStyle() {
    return Container(
      margin: widget.margin ?? const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.primaryLight.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    widget.tip.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tip del día',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.tip.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isDismissible)
                GestureDetector(
                  onTap: _dismissTip,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.tip.message,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getCategoryName(widget.tip.category),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              if (widget.isDismissible)
                GestureDetector(
                  onTap: _dismissTip,
                  child: Text(
                    'Entendido',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBannerStyle() {
    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            widget.tip.icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.tip.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.tip.message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (widget.isDismissible)
            GestureDetector(
              onTap: _dismissTip,
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSnackbarStyle() {
    return Container(
      margin: widget.margin ?? const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            widget.tip.icon,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.tip.message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (widget.isDismissible)
            TextButton(
              onPressed: _dismissTip,
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getCategoryName(TipCategory category) {
    switch (category) {
      case TipCategory.hydration:
        return 'Hidratación';
      case TipCategory.motivation:
        return 'Motivación';
      case TipCategory.technique:
        return 'Técnica';
      case TipCategory.nutrition:
        return 'Nutrición';
      case TipCategory.recovery:
        return 'Recuperación';
      case TipCategory.mindset:
        return 'Mentalidad';
      case TipCategory.beginner:
        return 'Principiante';
    }
  }
}

// Widget for displaying tips in different contexts
class DailyTipDisplay extends StatefulWidget {
  final TipDisplayStyle style;
  final EdgeInsets? margin;

  const DailyTipDisplay({
    Key? key,
    this.style = TipDisplayStyle.card,
    this.margin,
  }) : super(key: key);

  @override
  State<DailyTipDisplay> createState() => _DailyTipDisplayState();
}

class _DailyTipDisplayState extends State<DailyTipDisplay> {
  MotivationalTip? _dailyTip;
  bool _isLoading = true;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _loadDailyTip();
  }

  Future<void> _loadDailyTip() async {
    try {
      final tip = await MotivationalTipsService.getDailyTip();
      if (mounted) {
        setState(() {
          _dailyTip = tip;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onTipDismissed() {
    setState(() {
      _isDismissed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    if (_dailyTip == null || _isDismissed) {
      return const SizedBox.shrink();
    }

    return MotivationalTipCard(
      tip: _dailyTip!,
      style: widget.style,
      margin: widget.margin,
      onDismiss: _onTipDismissed,
    );
  }
}