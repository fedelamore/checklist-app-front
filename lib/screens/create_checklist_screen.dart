import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';

import '../models/checklist.dart';
import '../providers/checklist_provider.dart';
import '../widgets/progress_bar.dart';

class CreateChecklistScreen extends StatefulWidget {
  const CreateChecklistScreen({super.key});

  static const routeName = '/create-checklist';

  @override
  State<CreateChecklistScreen> createState() => _CreateChecklistScreenState();
}

class _CreateChecklistScreenState extends State<CreateChecklistScreen> {
  final _formKey = GlobalKey<FormState>();
  final _driverNameController = TextEditingController();
  final _driverDocumentController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  final _odometerController = TextEditingController();
  final _notesController = TextEditingController();
  final _signatureController = SignatureController(penStrokeWidth: 4, penColor: Colors.black);

  final ImagePicker _picker = ImagePicker();
  int _currentStep = 0;
  String? _evaluation;
  String? _odometerPhotoPath;
  final List<String> _photoPaths = [];
  String? _signatureData;
  Checklist? _editing;

  @override
  void dispose() {
    _driverNameController.dispose();
    _driverDocumentController.dispose();
    _vehiclePlateController.dispose();
    _odometerController.dispose();
    _notesController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argument = ModalRoute.of(context)?.settings.arguments;
    if (argument is Checklist && _editing == null) {
      _editing = argument;
      _driverNameController.text = argument.driverName;
      _driverDocumentController.text = argument.driverDocument;
      _vehiclePlateController.text = argument.vehiclePlate;
      _odometerController.text = argument.odometer.toString();
      _evaluation = argument.evaluation;
      _odometerPhotoPath = argument.odometerPhotoPath;
      _photoPaths
        ..clear()
        ..addAll(argument.photoPaths);
      _signatureData = argument.signature;
      _notesController.text = argument.notes ?? '';
    }
  }

  double get _progress {
    final total = 6;
    var completed = 0;
    if (_driverNameController.text.isNotEmpty && _driverDocumentController.text.isNotEmpty) {
      completed++;
    }
    if (_vehiclePlateController.text.isNotEmpty && _odometerController.text.isNotEmpty) {
      completed++;
    }
    if (_odometerPhotoPath != null) {
      completed++;
    }
    if (_evaluation != null) {
      completed++;
    }
    if (_photoPaths.isNotEmpty) {
      completed++;
    }
    if (_signatureData != null && _signatureData!.isNotEmpty) {
      completed++;
    }
    return completed / total;
  }

  bool get _isFormComplete =>
      _driverNameController.text.isNotEmpty &&
      _driverDocumentController.text.isNotEmpty &&
      _vehiclePlateController.text.isNotEmpty &&
      int.tryParse(_odometerController.text) != null &&
      _odometerPhotoPath != null &&
      _evaluation != null &&
      _photoPaths.isNotEmpty &&
      _signatureData != null &&
      _signatureData!.isNotEmpty;

  Future<void> _pickOdometerPhoto() async {
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file != null) {
      setState(() => _odometerPhotoPath = file.path);
    }
  }

  Future<void> _pickOrientationPhoto() async {
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file != null) {
      setState(() => _photoPaths.add(file.path));
    }
  }

  Future<void> _captureSignature() async {
    final export = await _signatureController.toPngBytes();
    if (export == null) return;
    setState(() => _signatureData = base64Encode(export));
  }

  void _clearSignature() {
    _signatureController.clear();
    setState(() => _signatureData = null);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || !_isFormComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos antes de enviar.')),
      );
      return;
    }

    final provider = context.read<ChecklistProvider>();
    final checklist = Checklist(
      id: _editing?.id ?? provider.generateId(),
      driverName: _driverNameController.text,
      driverDocument: _driverDocumentController.text,
      vehiclePlate: _vehiclePlateController.text.toUpperCase(),
      odometer: int.parse(_odometerController.text),
      odometerPhotoPath: _odometerPhotoPath!,
      evaluation: _evaluation!,
      photoPaths: List<String>.from(_photoPaths),
      signature: _signatureData!,
      createdAt: _editing?.createdAt ?? DateTime.now(),
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      status: ChecklistStatus.completed,
      syncStatus: SyncStatus.localOnly,
    );

    if (_editing != null) {
      await provider.updateChecklist(checklist);
    } else {
      await provider.addChecklist(checklist);
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKey.currentState!.validate()) return;
    }
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing == null ? 'Novo checklist' : 'Editar checklist'),
        actions: [
          TextButton(
            onPressed: _isFormComplete ? _submit : null,
            child: const Text('Enviar'),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: ChecklistProgressBar(
                progress: _progress,
                label: 'Progresso geral',
              ),
            ),
            Expanded(
              child: Stepper(
                type: StepperType.vertical,
                currentStep: _currentStep,
                onStepContinue: _nextStep,
                onStepCancel: _previousStep,
                controlsBuilder: (context, details) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        FilledButton(
                          onPressed: details.onStepContinue,
                          child: Text(_currentStep == steps.length - 1 ? 'Resumo' : 'Continuar'),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: details.onStepCancel,
                          child: const Text('Voltar'),
                        ),
                      ],
                    ),
                  );
                },
                steps: steps,
              ),
            ),
            SafeArea(
              minimum: const EdgeInsets.all(16),
              child: FilledButton.icon(
                icon: const Icon(Icons.send),
                onPressed: _isFormComplete ? _submit : null,
                label: const Text('Enviar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Step> _buildSteps(BuildContext context) {
    return [
      Step(
        title: const Text('Motorista'),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        content: Column(
          children: [
            TextFormField(
              controller: _driverNameController,
              decoration: const InputDecoration(labelText: 'Nome do motorista'),
              validator: (value) => value == null || value.isEmpty ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _driverDocumentController,
              decoration: const InputDecoration(labelText: 'Documento (CNH)'),
              validator: (value) => value == null || value.isEmpty ? 'Informe o documento' : null,
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Veículo'),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        content: Column(
          children: [
            TextFormField(
              controller: _vehiclePlateController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Placa'),
              validator: (value) => value == null || value.isEmpty ? 'Informe a placa' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _odometerController,
              decoration: const InputDecoration(labelText: 'Odômetro'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe o odômetro';
                }
                if (int.tryParse(value) == null) {
                  return 'Informe um número válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _odometerPhotoPath == null
                        ? 'Capture a foto do odômetro'
                        : 'Foto capturada: ${_odometerPhotoPath!.split('/').last}',
                  ),
                ),
                IconButton(
                  onPressed: _pickOdometerPhoto,
                  icon: const Icon(Icons.camera_alt_outlined),
                  tooltip: 'Fotografar odômetro',
                ),
              ],
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Avaliação'),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Como está o veículo?'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: [
                _EvaluationChip(label: 'Excelente', emoji: '😀', selectedValue: _evaluation, onSelected: _setEvaluation),
                _EvaluationChip(label: 'Ok', emoji: '😐', selectedValue: _evaluation, onSelected: _setEvaluation),
                _EvaluationChip(label: 'Problemas', emoji: '😟', selectedValue: _evaluation, onSelected: _setEvaluation),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Observações'),
              maxLines: 3,
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Fotos orientadas'),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Capture fotos das laterais, frente e traseira.'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final path in _photoPaths)
                  Chip(
                    label: Text(path.split('/').last),
                    onDeleted: () => setState(() => _photoPaths.remove(path)),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Adicionar foto'),
                  onPressed: _pickOrientationPhoto,
                ),
              ],
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Assinatura'),
        isActive: _currentStep >= 4,
        state: _signatureData != null ? StepState.complete : StepState.indexed,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 3,
                child: Signature(
                  controller: _signatureController,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _captureSignature,
                  icon: const Icon(Icons.check),
                  label: const Text('Salvar assinatura'),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: _clearSignature,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Limpar'),
                ),
              ],
            ),
            if (_signatureData != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Assinatura salva em ${DateFormat('HH:mm').format(DateTime.now())}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    ];
  }

  void _setEvaluation(String value) {
    setState(() => _evaluation = value);
  }
}

class _EvaluationChip extends StatelessWidget {
  const _EvaluationChip({
    required this.label,
    required this.emoji,
    required this.selectedValue,
    required this.onSelected,
  });

  final String label;
  final String emoji;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final value = '$emoji $label';
    final selected = selectedValue == value;
    return ChoiceChip(
      label: Text(value),
      selected: selected,
      onSelected: (_) => onSelected(value),
    );
  }
}
