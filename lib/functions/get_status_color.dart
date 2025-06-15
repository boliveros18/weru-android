import 'package:flutter/material.dart';

Color getStatusColor(String status) {
  switch (status) {
    case "Por asignar":
      return const Color.fromARGB(255, 255, 214, 79);
    case "Por ejecutar":
      return const Color(0xff3F51B5);
    case "En ejecucion":
      return const Color(0xffaed581);
    case "Con novedad":
      return const Color(0xffadadad);
    case "Finalizado":
      return const Color(0xff4caf50);
    case "Anulado":
      return const Color(0xffe19800);
    case "Cancelado":
      return const Color(0xff008FCD);
    case "Vencido":
      return const Color(0xffd32f2f);
    case "Fallido":
      return const Color(0xff008FCD);
    case "En sitio":
      return const Color(0xff008FCD);
    case "Por Transmitir":
      return const Color(0xff008FCD);
    default:
      return const Color(0xff008FCD);
  }
}
