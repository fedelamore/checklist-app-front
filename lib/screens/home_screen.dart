import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/checklist.dart';
import '../providers/checklist_provider.dart';
import '../widgets/checklist_card.dart';
import 'checklists_screen.dart';
import 'create_checklist_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklists pendentes'),
        actions: [
          IconButton(
            tooltip: 'Todos os checklists',
            icon: const Icon(Icons.list_alt),
            onPressed: () => Navigator.of(context).pushNamed(ChecklistsScreen.routeName),
          ),
        ],
      ),
      body: Consumer<ChecklistProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final pending = provider.byStatus(ChecklistStatus.pending);
          if (pending.isEmpty) {
            return const _EmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemBuilder: (_, index) {
              final item = pending[index];
              return ChecklistCard(
                checklist: item,
                subtitle: 'Criado em ' + DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    CreateChecklistScreen.routeName,
                    arguments: item,
                  );
                },
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: pending.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(CreateChecklistScreen.routeName),
        icon: const Icon(Icons.add_task),
        label: const Text('Novo checklist'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const _HomeBottomBar(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_outlined, size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            const Text(
              'Sem pendências',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Você está em dia! Sempre que precisar, toque no botão para abrir um novo checklist.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeBottomBar extends StatelessWidget {
  const _HomeBottomBar();

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        children: [
          IconButton(
            tooltip: 'Início',
            icon: const Icon(Icons.home_filled),
            onPressed: () {},
          ),
          IconButton(
            tooltip: 'Checklists',
            icon: const Icon(Icons.fact_check_outlined),
            onPressed: () => Navigator.of(context).pushNamed(ChecklistsScreen.routeName),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Perfil',
            icon: const Icon(Icons.person_outline),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
