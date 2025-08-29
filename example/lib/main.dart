import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_laranjinha_payment/constants/laranjinha_payment_type.dart';
import 'package:flutter_laranjinha_payment/constants/laranjinha_print_content_types.dart';
import 'package:flutter_laranjinha_payment/exceptions/laranjinha_info_exception.dart';
import 'package:flutter_laranjinha_payment/exceptions/laranjinha_payment_exception.dart';
import 'package:flutter_laranjinha_payment/exceptions/laranjinha_print_exception.dart';
import 'package:flutter_laranjinha_payment/exceptions/laranjinha_refund_exception.dart';
import 'package:flutter_laranjinha_payment/flutter_laranjinha_payment.dart';
import 'package:flutter_laranjinha_payment/models/laranjinha_content_print.dart';
import 'package:flutter_laranjinha_payment/models/laranjinha_payment_payload.dart';
import 'package:flutter_laranjinha_payment/models/laranjinha_payment_response.dart';
import 'package:flutter_laranjinha_payment/models/laranjinha_print_payload.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_laranjinha_payment/models/laranjinha_refund_payload.dart';
import 'package:http/http.dart' as http;

final flutterLaranjinhaPaymentPlugin = FlutterLaranjinhaPayment();
final List<LaranjinhaPaymentResponse> listPayments = [];

void main() {
  runApp(const MaterialApp(home: PaymentApp()));
}

class PaymentApp extends StatelessWidget {
  const PaymentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            spacing: 15.0,
            children: [
              SizedBox(
                width: 300,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => _PaymentPage()));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  child: Text('Pagamento'),
                ),
              ),

              SizedBox(
                width: 300,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => _CancelPage()));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  child: Text('Estornar'),
                ),
              ),
              SizedBox(
                width: 300,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => _PrintPage()));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  child: Text('Imprimir'),
                ),
              ),
              SizedBox(
                width: 300,
                height: 45,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await flutterLaranjinhaPaymentPlugin.reprint();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Reimpressão realizada com sucesso!")));
                    } on LaranjinhaInfoException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                    } on LaranjinhaPrintException catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Não foi realizar a impressão das informações do terminal: ${e.message}")));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro desconhecido')));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                  child: Text('Reimprimir'),
                ),
              ),

              SizedBox(
                width: 300,
                height: 45,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final info = await flutterLaranjinhaPaymentPlugin.deviceInfo();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Device info: ${info.toJson()}")));
                    } on LaranjinhaInfoException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro desconhecido')));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white),
                  child: Text('Device Info'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentPage extends StatefulWidget {
  const _PaymentPage();

  @override
  State<_PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<_PaymentPage> {
  final _amountEC = TextEditingController();
  final _qtdEC = TextEditingController();

  final List<DropdownMenuItem<LaranjinhaPaymentType?>> _listPaymentTypes = LaranjinhaPaymentType.values
      .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
      .toList();

  LaranjinhaPaymentType _transactionType = LaranjinhaPaymentType.debit;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('pagamento'), centerTitle: true, leading: Container()),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Align(alignment: Alignment.centerLeft, child: Text('Tipo do Pagamento')),
                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(5)),
                    height: 55,
                    child: DropdownButton(
                      value: _transactionType,
                      items: _listPaymentTypes,
                      isExpanded: true,
                      underline: Container(),
                      onChanged: (value) {
                        _qtdEC.text = '';
                        _transactionType = value!;
                        setState(() {});
                      },
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Align(alignment: Alignment.centerLeft, child: Text('Valor')),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _amountEC,
                    decoration: InputDecoration(hintText: 'Valor', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                  // if (_transactionType == LaranjinhaPaymentType.CREDIT)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Row(
                      children: [
                        SizedBox(width: 10.0),
                        Expanded(
                          child: Column(
                            children: [
                              Align(alignment: Alignment.centerLeft, child: Text('Qtd parcelamento')),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: _qtdEC,
                                decoration: InputDecoration(hintText: 'Qtd parcelamento', border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    child: Text('Voltar'),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        double amount = double.parse(_amountEC.text);
                        int? qtdPar = int.tryParse(_qtdEC.text);
                        final payment = LaranjinhaPaymentPayload(paymentType: _transactionType, amount: amount, installments: qtdPar);

                        final response = await flutterLaranjinhaPaymentPlugin.pay(paymentPayload: payment);
                        listPayments.add(response);
                        // final print = LaranjinhaPrintPayload(
                        //   printableContent: [LaranjinhaContentprint(type: LaranjinhaPrintType.line, content: response.toJson().toString())],
                        // );
                        // await flutterLaranjinhaPaymentPlugin.print(printPayload: print);

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Simulacao pagamento e Impressão realizada com sucesso!")));
                      } on LaranjinhaPaymentException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                      } on LaranjinhaPrintException catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Simulação de pagamento realizado mas erro na impressão: ${e.message}")));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro desconhecido')));
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: Text('Pagar'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CancelPage extends StatefulWidget {
  const _CancelPage();

  @override
  State<_CancelPage> createState() => _CancelPageState();
}

class _CancelPageState extends State<_CancelPage> {
  int? _indexPayment;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('cancelar'), centerTitle: true, leading: Container()),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                spacing: 10,
                children: [
                  Text("Lista de pagamentos que podem ser cancelados"),
                  ...List.generate(
                    listPayments.length,
                    (index) => InkWell(
                      onTap: () {
                        setState(() {
                          _indexPayment = index;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        width: double.infinity,
                        decoration: BoxDecoration(color: _indexPayment == index ? Colors.blue : Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                        child: Text("NSU: ${listPayments[index].nsu}", style: TextStyle(color: _indexPayment == index ? Colors.white : Colors.black)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    child: Text('Voltar'),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _indexPayment != null
                        ? () async {
                            try {
                              final refundPayload = LaranjinhaRefundPayload(nsu: listPayments[_indexPayment!].nsu!);

                              final response = await flutterLaranjinhaPaymentPlugin.refund(refundPayload: refundPayload);

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text("Simulacao Estorno realizada com sucesso! ${response.toJson()}")));
                            } on LaranjinhaRefundException catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                            } on LaranjinhaPrintException catch (e) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text("Simulação de pagamento realizado mas erro na impressão: ${e.message}")));
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro desconhecido')));
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    child: Text('Cancelar'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrintPage extends StatefulWidget {
  const _PrintPage();

  @override
  State<_PrintPage> createState() => _PrintPageState();
}

class _PrintPageState extends State<_PrintPage> {
  final _flutterLaranjinhaPaymentPlugin = FlutterLaranjinhaPayment();
  final _printTextEC = TextEditingController();
  final List<DropdownMenuItem<LaranjinhaPrintType>> _listPrintType = LaranjinhaPrintType.values
      .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
      .toList();
  final List<DropdownMenuItem<LaranjinhaPrintAlign>> _listPrintAlign = LaranjinhaPrintAlign.values
      .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
      .toList();
  final List<DropdownMenuItem<LaranjinhaPrintSize>> _listPrintSize = LaranjinhaPrintSize.values
      .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
      .toList();

  LaranjinhaPrintType _printType = LaranjinhaPrintType.line;
  LaranjinhaPrintAlign? _printAlign = LaranjinhaPrintAlign.center;
  LaranjinhaPrintSize _printSize = LaranjinhaPrintSize.medium;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('impressão'), centerTitle: true, leading: Container()),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Align(alignment: Alignment.centerLeft, child: Text('Tipo de Impressão')),
                  SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(5)),
                    height: 55,
                    child: DropdownButton(
                      value: _printType,
                      items: _listPrintType,
                      isExpanded: true,
                      underline: Container(),
                      onChanged: (value) {
                        _printType = value!;
                        if (_printType == LaranjinhaPrintType.text) {
                          _printAlign = LaranjinhaPrintAlign.center;
                          _printSize = LaranjinhaPrintSize.medium;
                        } else {
                          _printAlign = LaranjinhaPrintAlign.left;
                          _printSize = LaranjinhaPrintSize.medium;
                        }
                        setState(() {});
                      },
                    ),
                  ),
                  if (_printType == LaranjinhaPrintType.text)
                    Column(
                      children: [
                        SizedBox(height: 10),
                        Align(alignment: Alignment.centerLeft, child: Text('Alinhamento da Impressão')),
                        SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(5)),
                          height: 55,
                          child: DropdownButton(
                            value: _printAlign,
                            items: _listPrintAlign,
                            isExpanded: true,
                            underline: Container(),
                            onChanged: (value) {
                              _printAlign = value!;
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  if (_printType == LaranjinhaPrintType.text)
                    Column(
                      children: [
                        SizedBox(height: 10),
                        Align(alignment: Alignment.centerLeft, child: Text('Tamanho da Impressão')),
                        SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(5)),
                          height: 55,
                          child: DropdownButton(
                            value: _printSize,
                            items: _listPrintSize,
                            isExpanded: true,
                            underline: Container(),
                            onChanged: (value) {
                              _printSize = value!;
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  (_printType != LaranjinhaPrintType.image)
                      ? Column(
                          children: [
                            SizedBox(height: 10),
                            Align(alignment: Alignment.centerLeft, child: Text('Texto para Impressão')),
                            SizedBox(height: 10),
                            TextFormField(
                              controller: _printTextEC,
                              decoration: InputDecoration(hintText: 'Texto', border: OutlineInputBorder()),
                            ),
                          ],
                        )
                      : Column(children: [Image.network('https://zup.com.br/wp-content/uploads/2021/03/5ce2fde702ef93c1e994d987_flutter.png')]),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    child: Text('Voltar'),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        String? image64;
                        if (_printType == LaranjinhaPrintType.image) {
                          image64 = await imageToBase64('https://zup.com.br/wp-content/uploads/2021/03/5ce2fde702ef93c1e994d987_flutter.png');
                        }
                        final print = LaranjinhaPrintPayload(
                          printableContent: [
                            LaranjinhaContentprint(
                              type: _printType,
                              align: _printAlign,
                              content: '------------------------------------------------',
                              size: _printSize,
                              imagePath: image64,
                            ),
                          ],
                        );
                        await _flutterLaranjinhaPaymentPlugin.print(printPayload: print);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Impressão realizada com sucesso!")));
                      } on LaranjinhaPrintException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro desconhecido')));
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: Text('imprimir'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> imageToBase64(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return base64Encode(response.bodyBytes);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao converter imagem para Base64: $e");
      }
    }
    return null;
  }
}
