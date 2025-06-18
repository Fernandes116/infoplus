import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/province_selector.dart';

class JobListView extends StatefulWidget {
  const JobListView({super.key});

  @override
  State<JobListView> createState() => _JobListViewState();
}

class _JobListViewState extends State<JobListView> {
  String selectedProvince = 'Maputo';
  bool _isLoading = false;

  Future<void> _handleRefresh() async {
    final auth = context.read<AuthProvider>();
    if (auth.isAdmin) {
      await context.read<JobProvider>().fetchJobs(selectedProvince);
      return;
    }

    setState(() => _isLoading = true);
    await Navigator.pushReplacementNamed(context, '/payment', arguments: {
      'valor': 4,
      'tipo': 'vagas',
      'pontos': 5,
      'destino': '/jobs',
      'province': selectedProvince,
    });
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleRefresh());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final jobs = context.watch<JobProvider>().jobsByProvince(selectedProvince);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vagas'),
        actions: [
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.pushNamed(context, '/add-job'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              child: Column(
                children: [
                  ProvinceSelector(
                    selected: selectedProvince,
                    onChanged: (val) async {
                      if (val != null) {
                        setState(() => selectedProvince = val);
                        await _handleRefresh();
                      }
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: jobs.length,
                      itemBuilder: (_, i) {
                        final job = jobs[i];
                        return ListTile(
                          title: Text(job.title),
                          subtitle: Text('${job.location} - ${job.category}'),
                          trailing: auth.isAdmin
                              ? IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => context.read<JobProvider>().deleteJob(job.id),
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
