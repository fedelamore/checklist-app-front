import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/checklist.dart';

class ChecklistCard extends StatelessWidget {
  const ChecklistCard({
    super.key,
    required this.checklist,
    this.subtitle,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Checklist checklist;
  final String? subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Color statusColor;
    switch (checklist.status) {
      case ChecklistStatus.completed:
        statusColor = colorScheme.primary;
        break;
      case ChecklistStatus.pending:
        statusColor = colorScheme.tertiary;
        break;
    }

    IconData syncIcon;
    switch (checklist.syncStatus) {
      case SyncStatus.localOnly:
        syncIcon = Icons.cloud_off;
        break;
      case SyncStatus.syncing:
        syncIcon = Icons.sync;
        break;
      case SyncStatus.synced:
        syncIcon = Icons.cloud_done;
        break;
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(syncIcon, size: 20, color: statusColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      checklist.driverName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      checklist.status == ChecklistStatus.completed ? 'Concluído' : 'Pendente',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Placa: ${checklist.vehiclePlate} · Odômetro: ${checklist.odometer} km'),
              const SizedBox(height: 4),
              Text(
                subtitle ?? 'Criado em ${DateFormat('dd/MM/yyyy HH:mm').format(checklist.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (onEdit != null)
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Editar'),
                    ),
                  if (onDelete != null)
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Excluir'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
