import 'package:frontend/domain/entities/community.dart';
import 'package:frontend/infrastructure/dto/community_dto.dart';

class CommunityMapper {
  static CommunityDTO toDto(Community community) {
    return CommunityDTO(
      id: community.id,
      name: community.name,
      description: community.description,
      admin: community.admin,
      moderators: community.moderators,
      members: community.members,
      events: community.events,
      featured: community.featured,
      createdAt: community.createdAt,
      category: community.category,
      location: community.location,
      type: community.type,
      imageUrl: community.imageUrl,
    );
  }

  static Community fromDto(CommunityDTO dto) {
    return Community(
      id: dto.id ?? '',
      name: dto.name,
      description: dto.description,
      admin: dto.admin,
      moderators: dto.moderators,
      members: dto.members,
      events: dto.events,
      featured: dto.featured,
      createdAt: dto.createdAt ?? DateTime.now(),
      category: dto.category,
      location: dto.location,
      type: dto.type,
      imageUrl: dto.imageUrl,
    );
  }
}
