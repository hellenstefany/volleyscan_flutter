/// Mensaje del chat (coach = true si lo envía la IA).
class ChatMsg {
  final bool coach;
  final String texto;
  final String hora;
  const ChatMsg(this.coach, this.texto, this.hora);
}

String horaActual() {
  final n = DateTime.now();
  return '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}';
}

/// Respuesta de prueba. Reemplázala pasando `onSend` con tu llamada real a la API.
Future<String> respuestaSimulada(String mensaje) async {
  await Future.delayed(const Duration(milliseconds: 1200));
  return '## Respuesta de prueba\n\n'
      'Recibí tu pregunta: **$mensaje**.\n\n'
      'Conecta el parámetro `onSend` de AnalisisScreen con tu API para ver respuestas reales.';
}
