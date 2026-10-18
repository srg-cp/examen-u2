import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExploreMapPin extends StatelessWidget {
  const ExploreMapPin({
    required this.count,
    required this.selected,
    required this.onTap,
    super.key,
  });
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? const Color(0xFFE5E5EA) : Colors.white,
    shape: const CircleBorder(),
    elevation: selected ? 4 : 2,
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Stack(
        children: [
          Center(
            child: SvgPicture.asset(
              'assets/branding/only-black.svg',
              width: 36,
              height: 36,
              excludeFromSemantics: true,
            ),
          ),
          if (count > 1)
            Positioned(
              top: 0,
              right: 0,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Color(0xFF111111),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
