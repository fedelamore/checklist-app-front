import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/checklist.dart';
import '../providers/checklist_provider.dart';
import '../widgets/checklist_card.dart';
import 'create_checklist_screen.dart';

class ChecklistsScreen extends StatelessWidget {
  const ChecklistsScreen({super.key});

  static const routeName = '/checklists';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Todos os checklists'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Todos'),
              Tab(text: 'Pendentes'),
              Tab(text: 'Concluídos'),
            ],
          ),
        ),
        body: Consumer<ChecklistProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final tabs = [
              provider.all,
              provider.byStatus(ChecklistStatus.pending),
              provider.byStatus(ChecklistStatus.completed),
            ];
            return TabBarView(
              children: [
                for (final list in tabs)
                  _ChecklistList(
                    checklists: list,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ChecklistList extends StatelessWidget {
  const _ChecklistList({required this.checklists});

  final List<Checklist> checklists;

  @override
  Widget build(BuildContext context) {
    if (checklists.isEmpty) {
      return const _EmptyTabMessage();
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, index) {
        final item = checklists[index];
        return ChecklistCard(
          checklist: item,
          onTap: () => Navigator.of(context).pushNamed(
            CreateChecklistScreen.routeName,
            arguments: item,
          ),
          onEdit: () => Navigator.of(context).pushNamed(
            CreateChecklistScreen.routeName,
            arguments: item,
          ),
          onDelete: () => _confirmDelete(context, item),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: checklists.length,
    );
  }

  Future<void> _confirmDelete(BuildContext context, Checklist checklist) async {
    final provider = context.read<ChecklistProvider>();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir checklist'),
        content: Text('Deseja excluir o checklist de ${checklist.driverName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (shouldDelete ?? false) {
      await provider.deleteChecklist(checklist.id);
    }
  }
}

class _EmptyTabMessage extends StatelessWidget {
  const _EmptyTabMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.fact_check_outlined, size: 64),
            SizedBox(height: 12),
            Text('Nenhum checklist encontrado.'),
          ],
        ),
      ),
    );
  }
}
