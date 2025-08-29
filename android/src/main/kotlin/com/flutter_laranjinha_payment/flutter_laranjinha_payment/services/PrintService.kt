package com.flutter_laranjinha_payment.flutter_laranjinha_payment.services

import android.graphics.Bitmap
import android.os.Bundle
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import rede.smartrede.commons.callback.IPrinterCallback
import rede.smartrede.commons.contract.IConnectorPrinter
import rede.smartrede.commons.contract.ITerminalFunctions
import rede.smartrede.sdk.api.IRedeSdk

class PrintService {
    fun start( redeSdk: IRedeSdk, printerCallback: IPrinterCallback, printableContent: List<Bundle>?, binding: ActivityPluginBinding): Bundle {
        try {
            val terminalFunctions: ITerminalFunctions = redeSdk.getTerminalFunctions()
            val printer: IConnectorPrinter = terminalFunctions.getConnectorPrinter()
            validatePrintContent(printableContent)
            printer.setPrinterCallback(printerCallback)
            val generateBitmap: GenerateBitmap = GenerateBitmap()
            val bitmap: Bitmap =
                generateBitmap.convertPrintableItemsToBitmap(binding.activity, printableContent!!)
                    ?: throw IllegalStateException("Não foi possível gerar o bitmap de impressão!")

            printer.printBitmap(bitmap)

            return Bundle().apply {
                putString("code", "SUCCESS")
                putBoolean("data", true)
            }
        } catch (e: IllegalStateException) {
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

    private fun validatePrintContent(printableContent: List<Bundle>?) {
        if (printableContent == null) {
            throw IllegalArgumentException("Invalid print data: printable_content")
        }

        for (content: Bundle in printableContent) {
            val type: String? = content.getString("type")
            if (type == "text") {
                val contentOfType: String? = content.getString("content")
                val align: String? = content.getString("align")
                val size: String? = content.getString("size")

                if (contentOfType == null) throw IllegalArgumentException("Invalid printable_content data: content can't null when type equal 'text'")
                if (align !in listOf(
                        "center",
                        "right",
                        "left"
                    )
                ) throw IllegalArgumentException("Invalid printable_content data: align cannot be different from 'center | right | left' when type equal 'text'")
                if (size !in listOf(
                        "big",
                        "medium",
                        "small"
                    )
                ) throw IllegalArgumentException("Invalid printable_content data: size  cannot be different from 'big | medium | small' when type equal 'text'")
            } else if (type == "line") {
                if (content.getString("content") == null) {
                    throw IllegalArgumentException("Invalid printable_content data: content can't null when type equal 'text'")
                }
            } else if (type == "image") {
                if (content.getString("imagePath") == null) {
                    throw IllegalArgumentException("Invalid printable_content data: content can't null when type equal 'text'")
                }
            }
        }
    }

}