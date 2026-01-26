import 'package:flutter/material.dart';

class FormCard extends StatefulWidget {
  FormCard({Key? key}) : super(key: key);

  @override
  _FormCardState createState() => _FormCardState();
}

class _FormCardState extends State<FormCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.network("assets/img/secundario1.png"),
        const SizedBox(height: 150),
        _inputname(),
        SizedBox(height: 10),
        _inputcard(),
      ],
    );
  }

  Container _inputname() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: TextFormField(
        style: const TextStyle(fontSize: 20),
        decoration: const InputDecoration(
          hintText: "Email",
          border: InputBorder.none),
      ),
    );
  }
}

Container _inputcard() {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: Colors.grey),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 15),
    margin: const EdgeInsets.symmetric(horizontal: 15),
    child: TextFormField(
      style: const TextStyle(fontSize: 20),
      decoration: const InputDecoration(
        hintText: "Contraseña",
        border: InputBorder.none),
    ),
  );
}
