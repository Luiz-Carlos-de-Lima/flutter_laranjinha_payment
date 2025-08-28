package com.flutter_laranjinha_payment.flutter_laranjinha_payment.deeplink

import android.content.ActivityNotFoundException
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import rede.smartrede.sdk.FlexTipoPagamento
import rede.smartrede.sdk.PaymentIntentBuilder
import rede.smartrede.sdk.RedePaymentValidationError
import rede.smartrede.sdk.RedePayments
import rede.smartrede.sdk.api.IRedeSdk

class PaymentDeeplink: Deeplink() {
    companion object {
        const val REQUEST_CODE = 10001
    }

    override fun startDeeplink(redeSdk: IRedeSdk, binding: ActivityPluginBinding, bundle: Bundle): Bundle {
        try {
            validatePaymentData(bundle)
            val paymentType: FlexTipoPagamento = getPaymentType(bundle.getString("paymentType"))
            val amount: Int = bundle.getInt("amount", 0)
            val installments: Int = bundle.getInt("installments", 0)

            val redePayments: RedePayments = redeSdk.getRedePayments(binding.activity)

            val paymentIntentBuilder: PaymentIntentBuilder = redePayments.intentForPaymentBuilder(paymentType, amount.toLong())

            if (paymentType == FlexTipoPagamento.CREDITO_PARCELADO || paymentType == FlexTipoPagamento.CREDITO_PARCELADO_EMISSOR) {
                paymentIntentBuilder.setInstallments(installments)
            }

            paymentIntentBuilder.setInstallments(installments)

            val paymentIntent: Intent = paymentIntentBuilder.build()

            binding.activity.startActivityForResult(paymentIntent, REQUEST_CODE)

            return Bundle().apply {
                putString("code", "SUCCESS")
            }
        } catch (e: ActivityNotFoundException ) {
            return Bundle().apply {
                putString("code", "ERROR")
                putString("message", e.message)
            }
        } catch (e: RedePaymentValidationError ) {
            return Bundle().apply {
                putString("code", "ERROR")
                putString("message", e.message)
            }
        } catch (e: IllegalArgumentException) {
            return Bundle().apply {
                putString("code", "ERROR")
                putString("message", e.message)
            }
        } catch (e: Exception) {
            return Bundle().apply {
                putString("code", "ERROR")
                putString("message", e.message ?: "An unexpected error occurred")
            }
        }
    }

    private fun validatePaymentData(bundle: Bundle) {
        val paymentType = bundle.getString("paymentType")
            ?: throw IllegalArgumentException("Missing paymentType")

        val amount = bundle.getInt("amount", 0)
        val installments = bundle.getInt("installments", 0)

        require(paymentType in listOf(
            "credit_single_payment",
            "credit_installments",
            "credit_installments_with_interest",
            "debit",
            "voucher",
            "pix"
        )) {
            "Invalid payment type: '$paymentType'"
        }

        if (paymentType == "credit_installments" || paymentType == "credit_installments_with_interest") {
            require(installments in 2..99) {
                "Invalid installments: received $installments for paymentType '$paymentType'. " +
                        "Installments must be between 2 and 99."
            }
        }

        require(amount > 0) {
            "Invalid amount: must be greater than 0 (received $amount)"
        }
    }


    private fun getPaymentType(type: String?): FlexTipoPagamento {
        return when (type) {
            "credit_single_payment" -> FlexTipoPagamento.CREDITO_A_VISTA
            "credit_installments" -> FlexTipoPagamento.CREDITO_PARCELADO
            "credit_installments_with_interest" -> FlexTipoPagamento.CREDITO_PARCELADO_EMISSOR
            "debit" -> FlexTipoPagamento.DEBITO
            "voucher" -> FlexTipoPagamento.VOUCHER
            "pix" -> FlexTipoPagamento.PIX
            else -> throw IllegalArgumentException("Invalid payment type: '$type'")
        }
    }
}