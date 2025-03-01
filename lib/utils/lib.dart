import 'package:flutter/material.dart';

import '../config/router.dart';
import '../models/models.dart';

void showError(ApiData apidata) {
  String message = '';
  if (apidata is ExceptionError) {
    message = apidata.exception.toString();
  } else if (apidata is Error) {
    message = apidata.message;
  }

  if (message != '') {
    final snackbar = SnackBar(content: Text('Error:  $message'));
    showSnackBar(snackbar);
  }
}

showSnackBar(SnackBar snackbar) {
  ScaffoldMessenger.of(navigatiorKey.currentContext!).showSnackBar(snackbar);
}
