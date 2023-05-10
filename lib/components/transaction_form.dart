import 'package:flutter/material.dart';
import 'adaptative_button.dart';
import 'adaptative_textfield.dart';
import 'adaptative_date.dart';
class TransactionForm extends StatefulWidget {
  final void Function(String, double, DateTime) onSubmit;

  TransactionForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  void _submitButtonFunc() {
    if (_titleController.text.trim().isEmpty ||
        _valueController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Aviso'),
            content: const Text('Por favor, preencha todos os campos.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      widget.onSubmit(_titleController.text,
          double.tryParse(_valueController.text) ?? 0, _selectedDate);
    }
  }


  _submitForm() {
    final title = _titleController.text;
    final value = double.tryParse(_valueController.text) ?? 0;

    if (title.isEmpty || value <= 0 || _selectedDate == null) {
      return;
    }

    widget.onSubmit(title, value, _selectedDate!);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx,constrains){
        return SingleChildScrollView(
          child: Card(
            child: Container(
              height: constrains.maxHeight*1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AdaptativeTextField(
                    label: 'Título',
                    controller: _titleController,
                    onSubmitted: (_) => _submitForm,
                  ),
                  AdaptativeTextField(
                    label: 'Valor (R\$)',
                    controller: _valueController,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    onSubmitted: (_) => _submitForm,
                  ),
                  AdaptativeDatePicker(
                    selectedDate: _selectedDate,
                    onDateChanged: (newDate) {
                      setState(() {
                        _selectedDate = newDate;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AdaptativeButton('Nova Transação', _submitButtonFunc)

                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },

    );
  }
}
