import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'confirmation_toast.dart';
import '../../theme/app_theme.dart';

/// Visible credits for CARTO's basemap, independent of product markers.
class MapAttribution extends StatefulWidget {
  const MapAttribution({super.key});

  @override
  State<MapAttribution> createState() => _MapAttributionState();
}

class _MapAttributionState extends State<MapAttribution> {
  int _failure = 0;

  Future<void> _open(String url) async {
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      // Treat missing browser/platform errors as a recoverable presentation error.
    }
    if (mounted && !opened) setState(() => _failure++);
  }

  Widget _credit(String label, String url) => TextButton(
    onPressed: () => _open(url),
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF454545),
      minimumSize: const Size(48, 48),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      textStyle: const TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: 10,
        height: 1.2,
      ),
    ),
    child: Text(label, textAlign: TextAlign.end),
  );

  @override
  Widget build(BuildContext context) => ConfirmationToastHost(
    confirmed: _failure > 0,
    noticeId: _failure,
    message: 'No se pudo abrir el enlace. Reintenta.',
    isError: true,
    child: Material(
      color: const Color(0xEFFFFFFF),
      borderRadius: BorderRadius.circular(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: _credit(
              '© OpenStreetMap contributors',
              'https://www.openstreetmap.org/copyright',
            ),
          ),
          _credit('© CARTO', 'https://carto.com/attribution/'),
        ],
      ),
    ),
  );
}
