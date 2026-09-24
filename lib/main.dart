import 'package:flutter/material.dart';

void main() {
  runApp(const WellDesignApp());
}

class WellDesignApp extends StatelessWidget {
  const WellDesignApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wellbore Interactive',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1E3A8A),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2563EB),
          secondary: Color(0xFF10B981),
          surface: Color(0xFF1E293B),
        ),
      ),
      home: const WellboreScreen(),
    );
  }
}

class WellboreScreen extends StatefulWidget {
  const WellboreScreen({super.key});

  @override
  State<WellboreScreen> createState() => _WellboreScreenState();
}

class _WellboreScreenState extends State<WellboreScreen> {
  // Parámetros de Profundidad (m)
  double casingDepth = 1800;
  double totalDepth = 2650;
  double dpLength = 2400;
  double hwdpLength = 150;
  double dcLength = 100;

  // Calculados
  double get BHALength => hwdpLength + dcLength;
  double get bitDepth => dpLength + BHALength;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diseño Interactivo de Pozo', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E293B),
        centerTitle: true,
      ),
      body: Row(
        children: [
          // Panel Izquierdo: Controles
          Expanded(
            flex: 4,
            child: Container(
              color: const Color(0xFF1E293B),
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const Text('Parámetros de Geometría (m)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                  const SizedBox(height: 10),
                  _buildSlider('Zapata TR (m)', casingDepth, 500, 3500, (val) {
                    setState(() => casingDepth = val);
                  }),
                  _buildSlider('Profundidad Total / Hoyo (m)', totalDepth, 1000, 5000, (val) {
                    setState(() => totalDepth = val);
                  }),
                  const Divider(color: Colors.white24),
                  const Text('Componentes de Sarta (m)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.emerald)),
                  const SizedBox(height: 10),
                  _buildSlider('Longitud DP (5")', dpLength, 500, 4500, (val) {
                    setState(() => dpLength = val);
                  }),
                  _buildSlider('Longitud HWDP (5")', hwdpLength, 0, 500, (val) {
                    setState(() => hwdpLength = val);
                  }),
                  _buildSlider('Longitud DC (6.5")', dcLength, 0, 300, (val) {
                    setState(() => dcLength = val);
                  }),
                  const Divider(color: Colors.white24),
                  _buildInfoCard(),
                ],
              ),
            ),
          ),
          // Panel Derecho: Diagrama Interactivo
          Expanded(
            flex: 6,
            child: Container(
              color: const Color(0xFF0F172A),
              padding: const EdgeInsets.all(20),
              child: InteractiveViewer(
                child: CustomPaint(
                  painter: WellborePainter(
                    casingDepth: casingDepth,
                    totalDepth: totalDepth,
                    dpLength: dpLength,
                    hwdpLength: hwdpLength,
                    dcLength: dcLength,
                  ),
                  child: Container(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double val, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: Colors.white70)),
            Text('${val.toStringAsFixed(0)} m', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
          ],
        ),
        Slider(
          value: val.clamp(min, max),
          min: min,
          max: max,
          activeColor: const Color(0xFF2563EB),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profundidad Barrena: ${bitDepth.toStringAsFixed(0)} m', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent)),
          const SizedBox(height: 4),
          Text('Estado del Fondo: ${bitDepth > totalDepth ? "¡ALERTA: Barrena excede hoyo!" : "Operativo"}',
              style: TextStyle(color: bitDepth > totalDepth ? Colors.redAccent : Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }
}

class WellborePainter extends CustomPainter {
  final double casingDepth;
  final double totalDepth;
  final double dpLength;
  final double hwdpLength;
  final double dcLength;

  WellborePainter({
    required this.casingDepth,
    required this.totalDepth,
    required this.dpLength,
    required this.hwdpLength,
    required this.dcLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double maxDepthVal = totalDepth > (dpLength + hwdpLength + dcLength) ? totalDepth + 100 : (dpLength + hwdpLength + dcLength) + 100;
    final double scaleY = size.height / maxDepthVal;
    final double centerX = size.width / 2;

    // Pintar Fondo / Anular
    final Paint fluidPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRect(Rect.fromLTRB(centerX - 60, 0, centerX + 60, totalDepth * scaleY), fluidPaint);

    // Pintar Casing TR
    final Paint casingPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    canvas.drawLine(Offset(centerX - 60, 0), Offset(centerX - 60, casingDepth * scaleY), casingPaint);
    canvas.drawLine(Offset(centerX + 60, 0), Offset(centerX + 60, casingDepth * scaleY), casingPaint);

    // Pintar Hoyo Descubierto
    if (totalDepth > casingDepth) {
      final Paint openHolePaint = Paint()
        ..color = const Color(0xFFD97706)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;

      canvas.drawLine(Offset(centerX - 58, casingDepth * scaleY), Offset(centerX - 58, totalDepth * scaleY), openHolePaint);
      canvas.drawLine(Offset(centerX + 58, casingDepth * scaleY), Offset(centerX + 58, totalDepth * scaleY), openHolePaint);
    }

    // Pintar Sarta (DP, HWDP, DC)
    double currentTop = 0;

    // DP
    _drawPipeSegment(canvas, centerX, currentTop * scaleY, dpLength * scaleY, 20, const Color(0xFF1D4ED8), "DP");
    currentTop += dpLength;

    // HWDP
    _drawPipeSegment(canvas, centerX, currentTop * scaleY, hwdpLength * scaleY, 24, const Color(0xFF2563EB), "HWDP");
    currentTop += hwdpLength;

    // DC
    _drawPipeSegment(canvas, centerX, currentTop * scaleY, dcLength * scaleY, 32, const Color(0xFF0284C7), "DC");
    currentTop += dcLength;

    // Barrena
    final Paint bitPaint = Paint()..color = const Color(0xFFDC2626);
    final Path bitPath = Path()
      ..moveTo(centerX - 25, currentTop * scaleY)
      ..lineTo(centerX + 25, currentTop * scaleY)
      ..lineTo(centerX, (currentTop + 20) * scaleY)
      ..close();
    canvas.drawPath(bitPath, bitPaint);
  }

  void _drawPipeSegment(Canvas canvas, double centerX, double topY, double height, double width, Color color, String label) {
    if (height <= 0) return;
    final Paint pipePaint = Paint()..color = color;
    final Rect rect = Rect.fromLTWH(centerX - (width / 2), topY, width, height);
    canvas.drawRect(rect, pipePaint);

    final Paint borderPaint = Paint()
      ..color = Colors.black45
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant WellborePainter oldDelegate) => true;
}
