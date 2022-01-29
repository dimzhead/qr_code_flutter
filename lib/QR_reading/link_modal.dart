import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LinkModal extends StatefulWidget {
  var result;
  var context;
  LinkModal({Key? key, context, result}) : super(key: key);

  @override
  State<LinkModal> createState() => _LinkModalState();
}

class _LinkModalState extends State<LinkModal> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(
        'Barcode Type: ${describeEnum(widget.result!.format)}   Data: ${widget.result!.code}',
      ),
    );
  }
}
