package com.flutter_laranjinha_payment.flutter_laranjinha_payment.deeplink

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import rede.smartrede.sdk.Payment
import rede.smartrede.sdk.PaymentStatus
import rede.smartrede.sdk.RedePayments
import rede.smartrede.sdk.api.IRedeSdk

class RefundDeeplink: Deeplink {
    companion object {
        const val REQUEST_CODE = 10004
    }

    override fun startDeeplink(redeSdk: IRedeSdk, binding: ActivityPluginBinding, bundle: Bundle): Bundle {
        try {
            val nsu: String? = bundle.getString("nsu")

            require(!nsu.isNullOrEmpty()) {
                "NSU cannot be null or empty"
            }

            require(nsu.length in 1..6) {
                "NSU must contain between 1 and 6 digits (received length=${nsu.length})"
            }

            val redePayments: RedePayments = redeSdk.getRedePayments(binding.activity)
            val reversal: Intent = redePayments.intentForReversal(nsu)

            binding.activity.startActivityForResult(reversal, REQUEST_CODE)

            return Bundle().apply {
                putString("code", "SUCCESS")
            }
        } catch (e: ActivityNotFoundException) {
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

    override fun validateIntent(intent: Intent?): Map<String, Any?> {
        try {
            if (intent == null) {
                throw IllegalArgumentException("No intent data")
            }

            val payment: Payment = RedePayments.getPaymentFromIntent(intent)
                ?: throw IllegalStateException("Payment not found in Intent")

            return when (payment.status) {
                PaymentStatus.AUTHORIZED -> {
                    mapOf(
                        "code" to "SUCCESS",
                        "message" to "Estorno autorizado"
                    )
                }
                PaymentStatus.DECLINED -> {
                    throw IllegalStateException("Estorno recusado")
                }
                PaymentStatus.FAILED -> {
                    throw IllegalStateException("Falha no estorno")
                }
                else -> {
                    throw IllegalStateException("Unknown refund status: ${payment.status}")
                }
            }
        } catch (e: IllegalStateException) {
            return mapOf(
                "code" to "ERROR",
                "message" to e.message
            )
        } catch (e: IllegalArgumentException) {
            return mapOf(
                "code" to "ERROR",
                "message" to e.message
            )
        } catch (e: Exception) {
            return mapOf(
                "code" to "ERROR",
                "message" to e.message
            )
        }
    }
}