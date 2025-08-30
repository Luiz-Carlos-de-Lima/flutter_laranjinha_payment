package com.flutter_laranjinha_payment.flutter_laranjinha_payment.services

import android.graphics.Bitmap
import android.os.Bundle
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import rede.smartrede.commons.callback.IPrinterCallback
import rede.smartrede.commons.contract.IConnectorPrinter
import rede.smartrede.commons.contract.ITerminalFunctions
import rede.smartrede.sdk.api.IRedeSdk

class PrintService {
    fun start(
        redeSdk: IRedeSdk,
        printerCallback: IPrinterCallback,
        printableContent: List<Bundle>?,
        binding: ActivityPluginBinding
    ): Bundle {
        return try {
            Worker.postToWorkerThread {
                try {
                    val terminalFunctions: ITerminalFunctions = redeSdk.getTerminalFunctions()
                    val printer: IConnectorPrinter = terminalFunctions.getConnectorPrinter()

                    validatePrintContent(printableContent)

                    val bitmap: Bitmap = GenerateBitmap()
                        .convertPrintableItemsToBitmap(binding.activity, printableContent!!)
                        ?: throw IllegalStateException("Não foi possível gerar o bitmap de impressão!")

                    printer.setPrinterCallback(printerCallback)
                    printer.printBitmap(bitmap)
                } catch (e: IllegalArgumentException) {
                    printerCallback.onError(e.message ?: "Falha ao imprimir")
                } catch (e: IllegalStateException) {
                    printerCallback.onError(e.message ?: "Falha ao imprimir")
                } catch (e: Exception) {
                    printerCallback.onError(e.message ?: "Falha ao imprimir")
                }
            }

            Bundle().apply {
                putString("code", "SUCCESS")
                putBoolean("data", true)
            }
        } catch (e: IllegalStateException) {
            Bundle().apply {
                putString("code", "ERROR")
                putString("message", e.message)
            }
        } catch (e: Exception) {
            Bundle().apply {
                putString("code", "ERROR")
                putString("message", e.message ?: "Erro inesperado")
            }
        }
    }

    private fun validatePrintContent(printableContent: List<Bundle>?) {
        if (printableContent == null) throw IllegalArgumentException("Invalid print data: printable_content")

        for (content in printableContent) {
            when (content.getString("type")) {
                "text" -> {
                    val c = content.getString("content")
                    val align = content.getString("align")
                    val size = content.getString("size")
                    require(c != null) { "Invalid printable_content: content can't be null when type is 'text'" }
                    require(align in listOf("center","right","left")) { "align must be 'center|right|left'" }
                    require(size in listOf("big","medium","small")) { "size must be 'big|medium|small'" }
                }
                "line" -> requireNotNull(content.getString("content")) { "Invalid printable_content: content can't be null when type is 'line'" }
                "image" -> requireNotNull(content.getString("imagePath")) { "Invalid printable_content: imagePath can't be null when type is 'image'" }
                else -> throw IllegalArgumentException("Invalid printable_content: unknown type")
            }
        }
    }
}
