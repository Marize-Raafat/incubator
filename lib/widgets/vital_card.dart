import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VitalCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final String status;
  final String hint;
  final bool isAlert;
  final bool isWarning;

  const VitalCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.status = '✓ Normal',
    this.hint = '',
    this.isAlert = false,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    Color statusBgColor = const Color(0xFFEAF3DE);
    Color statusTextColor = const Color(0xFF3B6D11);
    
    if (isAlert) {
      statusBgColor = const Color(0xFFFCEBEB);
      statusTextColor = const Color(0xFFA32D2D);
    } else if (isWarning) {
      statusBgColor = const Color(0xFFFAEEDA);
      statusTextColor = const Color(0xFF854F0B);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.15), width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11.5),
        child: Column(
          children: [
            Container(
              height: 3,
              width: double.infinity,
              color: color,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 9, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: Colors.black54,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          value,
                          style: GoogleFonts.inter(
                            color: color,
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          unit,
                          style: GoogleFonts.inter(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          isAlert ? Icons.cancel : (isWarning ? Icons.warning_amber : Icons.check),
                          color: statusTextColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            status,
                            style: GoogleFonts.inter(
                              color: statusTextColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hint,
                      style: GoogleFonts.inter(
                        color: Colors.black45,
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
