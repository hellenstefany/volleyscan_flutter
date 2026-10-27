/// Lectura de un ángulo: valor actual y rango (mín/máx) de la sesión.
class AngleReading {
  double? current;
  double? min;
  double? max;

  void update(double value) {
    current = value;
    min = (min == null || value < min!) ? value : min;
    max = (max == null || value > max!) ? value : max;
  }

  /// "Reiniciar rangos": el rango vuelve a empezar desde el valor actual.
  void resetRange() {
    min = current;
    max = current;
  }
}

class JointMeasure {
  final String name;
  final AngleReading left = AngleReading();
  final AngleReading right = AngleReading();

  JointMeasure(this.name);
}

class AnalysisData {
  final List<JointMeasure> joints;
  final AngleReading trunk; // inclinación del tronco, 0° = erguido

  AnalysisData({required this.joints, required this.trunk});

  factory AnalysisData.empty() => AnalysisData(
    joints: [
      JointMeasure('Codo'),
      JointMeasure('Hombro'),
      JointMeasure('Cadera'),
      JointMeasure('Rodilla'),
      JointMeasure('Tobillo'),
    ],
    trunk: AngleReading(),
  );

  void resetRanges() {
    for (final j in joints) {
      j.left.resetRange();
      j.right.resetRange();
    }
    trunk.resetRange();
  }
}
