import 'package:financas/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionList extends StatefulWidget {
  final List<Transaction> transactions;

  final void Function(String) delete;

  const TransactionList(
      {super.key, required this.transactions, required this.delete});

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  @override
  Widget build(BuildContext context) {
    return widget.transactions.isEmpty
        ? LayoutBuilder(
            builder: (ctx, constrains) {
              return Column(children: [
                Padding(
                  padding: EdgeInsets.all(constrains.maxHeight * 0.1),
                  child: Text(
                    'Nenuma Transação Cadastrada',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Container(
                  height: constrains.maxHeight * 0.6,
                  padding: EdgeInsets.all(constrains.maxHeight * 0.1),
                  child: Image.asset(
                    'assets/images/waiting.png',
                    //Ajustar o tamanho da imagem a tela, todavia, precisa dar criação de um Container ou SizedBox para tal
                    fit: BoxFit.cover,
                  ),
                )
              ]);
            },
          )
        : ListView.builder(
            itemCount: widget.transactions.length,
            itemBuilder: (context, index) {
              final transaction = widget.transactions[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                elevation: 10,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.withOpacity(0.8),
                    radius: 30,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FittedBox(
                          child: Text(
                        'R\$${transaction.value}',
                        style: TextStyle(color: Colors.white),
                      )),
                    ),
                  ),
                  title: Text(
                    transaction.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  subtitle:
                      Text(DateFormat('d MMM y').format(transaction.date)),
                  trailing: MediaQuery.of(context).size.width > 480
                      ? OutlinedButton.icon(
                          onPressed: () => widget.delete(transaction.id),
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          label: Text('Excluir',style: TextStyle(color: Colors.red),))
                      : IconButton(
                          icon: const Icon(Icons.delete),
                          color: Theme.of(context).colorScheme.error,
                          onPressed: () => widget.delete(transaction.id),
                        ),
                ),
              );
            },
          );
  }
}
