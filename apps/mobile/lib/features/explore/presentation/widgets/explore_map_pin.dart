import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/presentation/widgets/brand_map_pin.dart';

class ExploreMapPin extends StatelessWidget {
  const ExploreMapPin({required this.selected, required this.onTap, super.key});
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PhysicalShape(
    color: selected ? const Color(0xFF171918) : Colors.white,
    clipper: const BrandMapPinClipper(),
    clipBehavior: Clip.antiAlias,
    elevation: selected ? 4 : 2,
    shadowColor: const Color(0x40000000),
    child: Material(
      color: selected ? const Color(0xFF171918) : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Center(
            child: SvgPicture.asset(
              'assets/branding/only-black.svg',
              width: 30,
              height: 30,
              colorFilter: selected
                  ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                  : null,
              excludeFromSemantics: true,
            ),
          ),
        ),
      ),
    ),
  );
}
