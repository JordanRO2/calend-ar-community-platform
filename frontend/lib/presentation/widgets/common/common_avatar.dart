// frontend/lib/presentation/widgets/common/common_avatar.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/configuration/assets/app_images.dart';

class CommonAvatar extends StatelessWidget {
  final double radius;
  final String? imageUrl;
  final VoidCallback? onTap;

  const CommonAvatar({
    super.key,
    required this.radius,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
            ? NetworkImage(imageUrl!)
            : const AssetImage(AppImages.defaultUser) as ImageProvider,
        child: imageUrl == null || imageUrl!.isEmpty
            ? Icon(
                Icons.person,
                size: radius,
                color: Theme.of(context).colorScheme.onSurface,
              )
            : null,
      ),
    );
  }
}
