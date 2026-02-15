import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/glucose/glucose_bloc.dart';
import '../../../data/models/glucose_models.dart';

class GlucoseHistoryScreen extends StatefulWidget {
  final String patientId;

  const GlucoseHistoryScreen({super.key, required this.patientId});

  @override
  State<GlucoseHistoryScreen> createState() => _GlucoseHistoryScreenState();
}

class _GlucoseHistoryScreenState extends State<GlucoseHistoryScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  int _currentPage = 0;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<GlucoseBloc>().add(LoadGlucoseHistory(
      widget.patientId,
      limit: _pageSize,
      offset: _currentPage * _pageSize,
      startDate: _startDate,
      endDate: _endDate,
    ));
  }

  void _onDateSelected(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
          // Ensure end date allows the whole day
          if (_endDate != null) {
             _endDate = _endDate!.add(const Duration(hours: 23, minutes: 59));
          }
        }
      });
    }
  }

  void _search() {
    setState(() {
      _currentPage = 0;
    });
    _loadData();
  }

  void _nextPage() {
    setState(() {
      _currentPage++;
    });
    _loadData();
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Glucosa'),
      ),
      body: Column(
        children: [
          // Filter Section
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _DateSelector(
                          label: 'Desde',
                          date: _startDate,
                          onTap: () => _onDateSelected(true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _DateSelector(
                          label: 'Hasta',
                          date: _endDate != null ? DateTime(_endDate!.year, _endDate!.month, _endDate!.day) : null,
                          onTap: () => _onDateSelected(false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _search,
                      icon: const Icon(Icons.search),
                      label: const Text('Buscar'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: BlocBuilder<GlucoseBloc, GlucoseState>(
              builder: (context, state) {
                if (state is GlucoseLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is GlucoseError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is GlucoseLoaded) {
                  if (state.history.isEmpty) {
                    return const Center(child: Text('No se encontraron registros.'));
                  }
                  
                  return Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: state.history.length,
                          itemBuilder: (context, index) {
                            final item = state.history[index];
                            return _GlucoseGridItem(item: item);
                          },
                        ),
                      ),
                      
                      // Pagination Controls
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: _currentPage > 0 ? _prevPage : null,
                              child: const Text('Anterior'),
                            ),
                            Text('Página ${_currentPage + 1}'),
                            ElevatedButton(
                              // Disable next if we received fewer items than page size (end of list)
                              onPressed: state.history.length == _pageSize ? _nextPage : null,
                              child: const Text('Siguiente'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const Center(child: Text('Selecciona filtros para buscar'));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateSelector({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(date != null ? DateFormat('dd/MM/yyyy').format(date!) : 'Seleccionar'),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }
}

class _GlucoseGridItem extends StatelessWidget {
  final GlucoseMeasurement item;

  const _GlucoseGridItem({required this.item});

  @override
  Widget build(BuildContext context) {
    // Basic color coding
    Color color = Colors.green;
    if (item.glucoseValue < 70) color = Colors.red;
    if (item.glucoseValue > 180) color = Colors.orange;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(Icons.water_drop, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${item.glucoseValue} mg/dL',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('dd/MM HH:mm').format(item.timestamp),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (item.notes != null && item.notes!.isNotEmpty)
              Text(
                item.notes!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}
