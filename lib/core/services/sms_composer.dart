import 'dart:io';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../errors/failure.dart';

part 'sms_composer.g.dart';

/// `opened`: the SMS app was opened but the platform doesn't report the outcome (Android).
enum ComposeResult { sent, cancelled, failed, opened }

/// Native SMS composer — platform channel `quotesheaf/composer`
/// (iOS: `AppDelegate.swift`, Android: `MainActivity.kt`).
abstract interface class SmsComposer {
  /// True when the device can send texts with attachments.
  Future<bool> canSendText();

  /// True when a Mail account is set up (used to enable the Email button).
  Future<bool> canSendMail();

  Future<ComposeResult> sendText({required String phone, required String body, required File attachment});
}

class NativeSmsComposer implements SmsComposer {
  const NativeSmsComposer();

  static const _channel = MethodChannel('quotesheaf/composer');

  @override
  Future<bool> canSendText() => _bool('canSendText');

  @override
  Future<bool> canSendMail() => _bool('canSendMail');

  @override
  Future<ComposeResult> sendText({required String phone, required String body, required File attachment}) async {
    try {
      final r = await _channel.invokeMethod<String>('sendText', {
        'recipients': [phone],
        'body': body,
        'attachmentPath': attachment.path,
      });
      return switch (r) {
        'sent' => ComposeResult.sent,
        'cancelled' => ComposeResult.cancelled,
        'opened' => ComposeResult.opened,
        _ => ComposeResult.failed,
      };
    } on PlatformException catch (e) {
      throw Failure(e.message ?? "Couldn't open the messages app.", e);
    }
  }

  static Future<bool> _bool(String method) async {
    if (!Platform.isIOS && !Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>(method) ?? false;
    } on PlatformException {
      return false;
    }
  }
}

@Riverpod(keepAlive: true)
SmsComposer smsComposer(Ref ref) => const NativeSmsComposer();
