import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Official pin silhouette and unchanged brand geometry, shared by map views.
class BrandMapPin extends StatelessWidget {
  const BrandMapPin({
    required this.color,
    this.onTap,
    this.number,
    this.count = 1,
    this.label = 'Ubicación',
    super.key,
  });
  final Color color;
  final VoidCallback? onTap;
  final int? number;
  final int count;
  final String label;
  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    button: onTap != null,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: PhysicalShape(
            color: color,
            clipper: const BrandMapPinClipper(),
            clipBehavior: Clip.antiAlias,
            elevation: 3,
            shadowColor: const Color(0x40000000),
            child: Material(
              color: color,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/branding/only-black.svg',
                      width: 27,
                      height: 27,
                      excludeFromSemantics: true,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (number != null || count > 1)
          Positioned(
            right: -4,
            top: -5,
            child: ExcludeSemantics(
              child: Container(
                constraints: const BoxConstraints(minWidth: 21, minHeight: 21),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count > 1 ? '×$count' : '$number',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class BrandMapPinClipper extends CustomClipper<Path> {
  const BrandMapPinClipper();
  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.width * .5, size.height)
    ..lineTo(size.width * .34, size.height * .81)
    ..cubicTo(-size.width * .12, size.height * .65, 0, 0, size.width * .5, 0)
    ..cubicTo(
      size.width,
      0,
      size.width * 1.12,
      size.height * .65,
      size.width * .66,
      size.height * .81,
    )
    ..close();
  @override
  bool shouldReclip(BrandMapPinClipper oldClipper) => false;
}
