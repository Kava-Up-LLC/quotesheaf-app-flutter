package com.kavaup.quotesheaf

import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Telephony
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/** Shares the quote PDF with the SMS app (own authority, independent of plugins). */
class ComposerFileProvider : FileProvider()

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "quotesheaf/composer")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "canSendText" -> result.success(defaultSmsPackage() != null)
                    "canSendMail" -> result.success(canSendMail())
                    "sendText" -> sendText(
                        phone = call.argument<List<String>>("recipients")?.firstOrNull().orEmpty(),
                        body = call.argument<String>("body").orEmpty(),
                        path = call.argument<String>("attachmentPath"),
                        result = result,
                    )
                    else -> result.notImplemented()
                }
            }
    }

    private fun defaultSmsPackage(): String? =
        if (packageManager.hasSystemFeature(PackageManager.FEATURE_TELEPHONY_MESSAGING)) {
            Telephony.Sms.getDefaultSmsPackage(this)
        } else {
            null
        }

    private fun canSendMail(): Boolean =
        Intent(Intent.ACTION_SENDTO, Uri.parse("mailto:")).resolveActivity(packageManager) != null

    /**
     * Opens the default SMS app directly (no chooser) with number, text and the PDF (PRD §8.4).
     * Android does not report whether the message was sent, so the result is "opened".
     */
    private fun sendText(phone: String, body: String, path: String?, result: MethodChannel.Result) {
        val smsPackage = defaultSmsPackage()
        if (smsPackage == null) {
            result.error("not_available", "This device can't send texts.", null)
            return
        }
        val intent = Intent(Intent.ACTION_SEND).apply {
            type = "application/pdf"
            putExtra("address", phone)
            putExtra("sms_body", body)
            putExtra(Intent.EXTRA_TEXT, body)
            if (path != null) {
                val uri = FileProvider.getUriForFile(
                    this@MainActivity, "$packageName.composer_file_provider", File(path),
                )
                putExtra(Intent.EXTRA_STREAM, uri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            setPackage(smsPackage)
        }
        try {
            startActivity(intent)
            result.success("opened")
        } catch (e: ActivityNotFoundException) {
            result.error("not_available", "The SMS app can't receive attachments.", null)
        }
    }
}
