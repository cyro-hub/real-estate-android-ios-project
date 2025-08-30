import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

Future<BitmapDescriptor> getCustomMarkerIcon(IconData iconData) async {
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);

  const double markerWidth = 130.0;
  const double markerHeight = 165.0;
  const double iconContainerRadius = 55.0;
  const double iconSize = 85.0;

  // --- Define Colors ---
  final Paint indigoPinPaint = Paint()..color = Colors.indigo;
  final Paint whiteCirclePaint = Paint()..color = Colors.white;
  const Color indigoIconColor = Colors.indigo;

  // --- Draw the custom pin shape (now indigo and sharper) ---
  final Path pinPath = Path();
  pinPath.addRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(
        0,
        0,
        markerWidth,
        markerHeight * 0.75,
      ), // Top rounded part
      const Radius.circular(60),
    ),
  );

  pinPath.moveTo(markerWidth / 2, markerHeight * 0.80);
  // Define the left bottom point of the triangle
  pinPath.lineTo(markerWidth * 0.2, markerHeight * 0.75);
  pinPath.lineTo(markerWidth / 2, markerHeight * 1);
  pinPath.lineTo(markerWidth * 0.8, markerHeight * 0.75);
  pinPath.close();

  canvas.drawPath(pinPath, indigoPinPaint);

  // --- Draw the white circular background for the icon ---
  const Offset circleCenter = Offset(markerWidth / 2, markerHeight * 0.75 / 2);
  canvas.drawCircle(circleCenter, iconContainerRadius, whiteCirclePaint);

  // --- TextPainter for the Icon (now indigo) ---
  final TextPainter iconPainter = TextPainter(textDirection: TextDirection.ltr);

  final String iconChar = String.fromCharCode(iconData.codePoint);
  iconPainter.text = TextSpan(
    text: iconChar,
    style: TextStyle(
      fontSize: iconSize,
      fontFamily: iconData.fontFamily,
      package: iconData.fontPackage,
      color: indigoIconColor,
    ),
  );
  iconPainter.layout();

  // Center the icon within the white circle
  final Offset iconOffset = Offset(
    circleCenter.dx - iconPainter.width / 2,
    circleCenter.dy - iconPainter.height / 2,
  );
  iconPainter.paint(canvas, iconOffset);

  final ui.Image image = await pictureRecorder.endRecording().toImage(
    markerWidth.toInt(),
    markerHeight.toInt(),
  );
  final ByteData? byteData = await image.toByteData(
    format: ui.ImageByteFormat.png,
  );
  final Uint8List? bytes = byteData?.buffer.asUint8List();

  if (bytes != null) {
    return BitmapDescriptor.fromBytes(bytes);
  }
  return BitmapDescriptor.defaultMarker;
}
