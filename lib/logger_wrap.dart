import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 3, // number of method calls to be displayed
    errorMethodCount: 8, // number of method calls if stacktrace is provided
    printTime: true,
  ),
);