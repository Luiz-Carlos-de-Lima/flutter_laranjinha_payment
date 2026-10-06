<h1 align="center">Flutter Laranjinha Payment</h1>

<div align="center" id="top">
  <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Rede_logo.svg/512px-Rede_logo.svg.png" alt="Rede" height=40 style="margin: 20px 0px 0px 0px;" />
</div>

## Plugin não oficial

<a href="https://buymeacoffee.com/luiz.carlos199" target="_blank">
    <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" width="150">
</a>
<br />

<a href="https://www.linkedin.com/in/luizcarlos199lcdl/" target="_blank">
    <img src="https://img.shields.io/badge/-LinkedIn-%230077B5?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn" width="100"  style="margin: 5px 0px 5px 0;" />
</a>
<br />

<a href="https://github.com/Luiz-Carlos-de-Lima" target="_blank">
    <img src="https://img.shields.io/badge/GitHub-black?style=for-the-badge&logo=github" alt="GitHub Repo" width="100" >
</a>

## Sobre

O **Flutter Laranjinha Payment** Plugin integra pagamento da Rede (maquininha Laranjinha / Itaú) em aplicações Flutter executadas no terminal POS Android. Com este plugin é possível processar transações via `crédito`, `débito`, `voucher` e `Pix`, além de realizar `estorno`, `impressão customizada`, `reimpressão` e consulta de `informações do terminal`.

---

## Requisitos

Antes de utilizar o plugin, certifique-se de que os seguintes requisitos sejam atendidos:

- **Aplicação Android rodando em um terminal POS Laranjinha compatível**.
- **Aplicativos da Rede / Laranjinha instalados no dispositivo POS**.

---

## Instalação

Adicione a dependência do plugin ao seu projeto Flutter:

```yaml
dependencies:
  flutter_laranjinha_payment: any
```

## Uso

Para utilizar o plugin, basta criar uma instância e chamar os métodos disponíveis:

```dart
import 'package:flutter_laranjinha_payment/flutter_laranjinha_payment.dart';

final flutterLaranjinha = FlutterLaranjinhaPayment();

final response = await flutterLaranjinha.pay(paymentPayload: payment);

final refund = await flutterLaranjinha.refund(refundPayload: refundPayload);

await flutterLaranjinha.print(printPayload: printPayload);

await flutterLaranjinha.reprint();

final info = await flutterLaranjinha.deviceInfo();
```

## Enums Disponíveis

### `LaranjinhaPaymentType`

Define os tipos de transação disponíveis:

* `creditSinglePayment` - Crédito à vista.

* `creditInstallments` - Crédito parcelado sem juros. Exige `installments` entre 2 e 99.

* `creditInstallmentsWithInterest` - Crédito parcelado com juros. Exige `installments` entre 2 e 99.

* `debit` - Débito.

* `voucher` - Voucher.

* `pix` - Pix.

### `LaranjinhaPrintType`

Define os tipos de impressão disponíveis:

* `text` - Impressão de texto.

* `line` - Impressão de linha.

* `image` - Impressão de imagem.

### `LaranjinhaPrintAlign`

Alinhamento do texto. Usado quando `LaranjinhaPrintType.text`:

* `center` - Centralizado.

* `right` - Alinhado à direita.

* `left` - Alinhado à esquerda.

### `LaranjinhaPrintSize`

Tamanho do texto. Usado quando `LaranjinhaPrintType.text`:

* `big` - Grande.

* `medium` - Médio.

* `small` - Pequeno.

## Exceptions

```dart
LaranjinhaPaymentException() // Erro na execução do método pay.
LaranjinhaRefundException() // Erro na execução do método refund.
LaranjinhaPrintException() // Erro na execução do método print.
LaranjinhaReprintException() // Erro na execução do método reprint.
LaranjinhaInfoException() // Erro na execução do método deviceInfo.
```

## Método `pay`

No método `pay`, crie um `LaranjinhaPaymentPayload`. O `amount` é em reais. O plugin converte para centavos antes de enviar ao terminal.

```dart
final payment = LaranjinhaPaymentPayload(
  amount: 150.00,
  paymentType: LaranjinhaPaymentType.debit,
);

final credit = LaranjinhaPaymentPayload(
  amount: 150.00,
  paymentType: LaranjinhaPaymentType.creditInstallments,
  installments: 3,
);
```

A estrutura de `LaranjinhaPaymentPayload` é a seguinte:

```dart
class LaranjinhaPaymentPayload {
  final LaranjinhaPaymentType paymentType;
  final double amount;
  final int? installments;

  LaranjinhaPaymentPayload({
    required this.paymentType,
    required this.amount,
    this.installments,
  });
}
```

## Resposta do Pagamento

Se a transação for aprovada, o retorno é um `LaranjinhaPaymentResponse`. Caso contrário, é lançada `LaranjinhaPaymentException`.

```dart
class LaranjinhaPaymentResponse {
  final String storeName;
  final String date;
  final String time;
  final double value;
  final String? auto;
  final String? nsu;
  final String? issuerName;
  final String? cardHolderName;
  final String? terminalNumber;
  final String? cv;
  final String? aid;
  final String? arqc;
  final int? installments;
  final double? installmentValue;
  final String? cnpj;
  final String? operationType;
  final String? maskedPan;
  final String? pixTransactionId;
}
```

## Método `refund`

No método `refund`, informe o NSU da transação (no máximo 6 dígitos):

```dart
final refund = LaranjinhaRefundPayload(nsu: '123456');
final response = await flutterLaranjinha.refund(refundPayload: refund);
```

```dart
class LaranjinhaRefundPayload {
  final String nsu;

  LaranjinhaRefundPayload({required this.nsu});
}
```

Se o estorno for bem-sucedido, o retorno é um `LaranjinhaRefundResponse` com `code` e `message`. Caso contrário, é lançada `LaranjinhaRefundException`.

## Método `print`

No método `print`, crie um `LaranjinhaPrintPayload`:

```dart
LaranjinhaPrintPayload(
  printableContent: [
    LaranjinhaContentprint(
      type: LaranjinhaPrintType.line,
      content: '--------------------------------',
    ),
    LaranjinhaContentprint(
      type: LaranjinhaPrintType.text,
      align: LaranjinhaPrintAlign.center,
      size: LaranjinhaPrintSize.big,
      content: 'Texto a ser impresso',
    ),
    LaranjinhaContentprint(
      type: LaranjinhaPrintType.image,
      imagePath: 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
    ),
  ],
);
```

Se a impressão for bem-sucedida, a resposta é `void`. Caso contrário, é lançada `LaranjinhaPrintException`.

## Método `reprint`

Reimprime o último comprovante. Não recebe parâmetros. Em caso de erro, é lançada `LaranjinhaReprintException`.

## Método `deviceInfo`

Retorna o número de série e o modelo do terminal:

```dart
final info = await flutterLaranjinha.deviceInfo();
// info.seriallNumber, info.deviceModel
```

Em caso de erro, é lançada `LaranjinhaInfoException`.

## Considerações Finais

Este plugin foi desenvolvido para rodar em terminais POS Android da Rede (Laranjinha). Certifique-se de que a aplicação atende aos requisitos antes de utilizá-lo.

## :memo: Autores

Este projeto foi desenvolvido por:
<a href="https://github.com/Luiz-Carlos-de-Lima" target="_blank">Luiz Carlos de Lima</a>
</br>
<div>
<a href="https://github.com/Luiz-Carlos-de-Lima">
  <img src="https://avatars.githubusercontent.com/u/82920625?s=400&u=a114c12a6e61d2f9b907feb450587a37aae068bb&v=4" height=90 />
</a>
<br>
<a href="https://github.com/Luiz-Carlos-de-Lima" target="_blank">Luiz Carlos de Lima</a>
</div>

&#xa0;

## Licença

Este projeto está sob a licença MIT.

<a href="#top">Voltar para o topo</a>
