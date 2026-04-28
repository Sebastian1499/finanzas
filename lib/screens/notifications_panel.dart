import 'package:flutter/material.dart';
import '../models/app_notification.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';

class NotificationsPanel extends StatefulWidget {
  final List<AppNotification> notifications;

  const NotificationsPanel({super.key, required this.notifications});

  @override
  State<NotificationsPanel> createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends State<NotificationsPanel> {
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    // Mark all visible notifications as read immediately
    _notifications = widget.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    NotificationService.markAllRead(
      widget.notifications.map((n) => n.id).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.72),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle ───────────────────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.handle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Título ───────────────────────────────────────────────────
          Text(
            'Notificaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.textMain,
            ),
          ),
          const SizedBox(height: 16),

          // ── Lista o estado vacío ─────────────────────────────────────
          if (_notifications.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.notifications_none_rounded,
                        size: 52, color: context.textSub),
                    const SizedBox(height: 14),
                    Text(
                      'Sin notificaciones por ahora',
                      style:
                          TextStyle(color: context.textSub, fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _notifications.length,
                separatorBuilder: (_, __) =>
                    Divider(color: context.divider, height: 1),
                itemBuilder: (_, i) => _NotifTile(
                  notification: _notifications[i],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Tile individual ──────────────────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  final AppNotification notification;

  const _NotifTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final n = notification;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícono con fondo tintado
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: n.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(n.icon, color: n.color, size: 22),
          ),
          const SizedBox(width: 14),

          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        n.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.textMain,
                        ),
                      ),
                    ),
                    // Punto rojo si no leída
                    if (!n.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFC62828),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  n.body,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.textSub,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
