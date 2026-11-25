import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../errors/failure.dart';

part 'email_composer.g.dart';

/// Native Mail composer via `flutter_email_sender`. It returns once Mail is
/// open; the package does not report whether the email was sent.
abstract interface class EmailComposer {
  Future<void> send({required String to, required String subject, required String body, required File attachment});
}

class FlutterEmailComposer implements EmailComposer {
  const FlutterEmailComposer();

  @override
  Future<void> send({required String to, required String subject, required String body, required File attachment}) async {
    try {
      await FlutterEmailSender.send(Email(
        recipients: [to],
        subject: subject,
        body: body,
        attachmentPaths: [attachment.path],
      ));
    } on PlatformException catch (e) {
      throw Failure(
        e.code == 'not_available' || e.code == 'UNAVAILABLE' ? 'Set up an email account on this device to send by Email.' : "Couldn't open Mail.",
        e,
      );
    }
  }
}

@Riverpod(keepAlive: true)
EmailComposer emailComposer(Ref ref) => const FlutterEmailComposer();
