/// Repository layer: provides prompt/category/notification data.
///
/// DEMO MODE: all data comes from bundled sample data. To switch to
/// Firebase, implement [PromptRepository] with a Firebase-backed class
/// (see README for the documented setup steps and security rules).
library;

import 'dart:math';

import 'models.dart';

abstract class PromptRepository {
  Future<List<Prompt>> getPrompts({int limit = 20, String? startAfterId});
  Future<List<Category>> getCategories();
  Future<List<NotificationItem>> getNotifications();
}

/// Demo repository with bundled sample data.
class DemoPromptRepository implements PromptRepository {
  final List<Prompt> _prompts = _samplePrompts;
  final List<Category> _categories = _sampleCategories;
  final List<NotificationItem> _notifications = _sampleNotifications;

  @override
  Future<List<Prompt>> getPrompts({int limit = 20, String? startAfterId}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var list = _prompts.where((p) => true).toList();
    if (startAfterId != null) {
      final idx = list.indexWhere((p) => p.id == startAfterId);
      if (idx >= 0) {
        list = list.sublist(min(idx + 1, list.length));
      }
    } else {
      list = list.sublist(0, min(limit, list.length));
    }
    return list;
  }

  @override
  Future<List<Category>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _categories;
  }

  @override
  Future<List<NotificationItem>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _notifications;
  }
}

// ---------------------------------------------------------------------------
// SAMPLE DATA (demo mode)
// ---------------------------------------------------------------------------

const _imgPortrait =
    'https://d2lm3begjhzc49.cloudfront.net/generated-images/b3251552.webp';
const _imgCar =
    'https://d2lm3begjhzc49.cloudfront.net/generated-images/f19a0c42.webp';
const _imgAnimal =
    'https://d2lm3begjhzc49.cloudfront.net/generated-images/970a53a5.webp';
const _imgAnime =
    'https://d2lm3begjhzc49.cloudfront.net/generated-images/bce22d0c.webp';
const _imgArt =
    'https://d1qqeunc9izjbf.cloudfront.net/generated-images/40f4ad73.webp';
const _imgWriting =
    'https://d1qqeunc9izjbf.cloudfront.net/generated-images/7cde6580.webp';
const _imgCode =
    'https://d1qqeunc9izjbf.cloudfront.net/generated-images/77f7b5f8.webp';
const _imgBusiness =
    'https://d1qqeunc9izjbf.cloudfront.net/generated-images/e9f49b15.webp';

final List<Category> _sampleCategories = [
  Category(id: 'men', name: 'Men', imageUrl: _imgPortrait, description: 'Prompts for male portraits and characters.', promptCount: 6),
  Category(id: 'women', name: 'Women', imageUrl: _imgPortrait, description: 'Prompts for female portraits and characters.', promptCount: 8),
  Category(id: 'portrait', name: 'Portrait', imageUrl: _imgPortrait, description: 'Studio, editorial and artistic portrait prompts.', promptCount: 10),
  Category(id: 'fashion', name: 'Fashion', imageUrl: _imgPortrait, description: 'High-fashion and runway style prompts.', promptCount: 5),
  Category(id: 'love', name: 'Love', imageUrl: _imgWriting, description: 'Romantic and heartwarming scene prompts.', promptCount: 4),
  Category(id: 'couples', name: 'Couples', imageUrl: _imgWriting, description: 'Couple portraits and romantic moments.', promptCount: 4),
  Category(id: 'nature', name: 'Nature', imageUrl: _imgArt, description: 'Landscapes, skies and natural beauty.', promptCount: 7),
  Category(id: 'cars', name: 'Cars', imageUrl: _imgCar, description: 'Cars, supercars and automotive art.', promptCount: 6),
  Category(id: 'animals', name: 'Animals', imageUrl: _imgAnimal, description: 'Wildlife and pet photography prompts.', promptCount: 5),
  Category(id: 'anime', name: 'Anime', imageUrl: _imgAnime, description: 'Anime and manga style illustrations.', promptCount: 9),
  Category(id: '3d-art', name: '3D Art', imageUrl: _imgArt, description: '3D renders and sculptural art.', promptCount: 4),
  Category(id: 'photography', name: 'Photography', imageUrl: _imgPortrait, description: 'Photorealistic photography prompts.', promptCount: 6),
  Category(id: 'cinematic', name: 'Cinematic', imageUrl: _imgCar, description: 'Movie-grade cinematic scenes.', promptCount: 5),
  Category(id: 'fantasy', name: 'Fantasy', imageUrl: _imgAnime, description: 'Magical and fantasy worlds.', promptCount: 7),
  Category(id: 'luxury', name: 'Luxury', imageUrl: _imgBusiness, description: 'Luxury lifestyle and premium objects.', promptCount: 3),
  Category(id: 'business', name: 'Business', imageUrl: _imgBusiness, description: 'Professional and corporate visuals.', promptCount: 4),
  Category(id: 'architecture', name: 'Architecture', imageUrl: _imgArt, description: 'Buildings, interiors and structures.', promptCount: 5),
  Category(id: 'travel', name: 'Travel', imageUrl: _imgArt, description: 'Travel destinations and adventures.', promptCount: 6),
  Category(id: 'wallpapers', name: 'Wallpapers', imageUrl: _imgArt, description: 'Desktop and phone wallpapers.', promptCount: 8),
  Category(id: 'wedding', name: 'Wedding', imageUrl: _imgWriting, description: 'Wedding photography and moments.', promptCount: 4),
  Category(id: 'professional', name: 'Professional', imageUrl: _imgBusiness, description: 'Professional headshots and brands.', promptCount: 5),
  Category(id: 'traditional', name: 'Traditional', imageUrl: _imgWriting, description: 'Cultural and traditional themes.', promptCount: 3),
  Category(id: 'fitness', name: 'Fitness', imageUrl: _imgAnimal, description: 'Fitness, gym and sports visuals.', promptCount: 4),
  Category(id: 'gaming', name: 'Gaming', imageUrl: _imgAnime, description: 'Gaming characters and setups.', promptCount: 6),
];

DateTime _daysAgo(int days) => DateTime.now().subtract(Duration(days: days));

final List<Prompt> _samplePrompts = [
  Prompt(
    id: 'p01',
    title: 'Neon Portrait Queen',
    description:
        'A striking editorial portrait with neon rim lighting. Perfect for magazine covers and premium profile pictures. The dramatic purple and electric blue lighting creates a futuristic yet elegant mood.',
    promptText:
        'Editorial fashion portrait of a confident woman, dramatic studio lighting, purple and electric blue rim light, dark navy background, glossy skin highlights, sharp focus on eyes, 85mm lens, f/1.4, ultra detailed, magazine cover quality',
    imageUrl: _imgPortrait,
    categoryId: 'portrait',
    tags: ['portrait', 'neon', 'women', 'fashion', 'editorial'],
    publishedDate: _daysAgo(1),
    featured: true,
    trending: true,
    views: 1240,
    copies: 310,
    favorites: 89,
  ),
  Prompt(
    id: 'p02',
    title: 'Midnight Supercar',
    description:
        'A cinematic night shot of a futuristic supercar. Wet street reflections and neon lights give it a premium automotive-poster look.',
    promptText:
        'Futuristic neon supercar parked on a rainy city street at night, purple and electric blue neon reflections on wet asphalt, cinematic wide shot, volumetric light, dramatic mood, automotive advertising style, ultra detailed, 8k',
    imageUrl: _imgCar,
    categoryId: 'cars',
    tags: ['cars', 'neon', 'cinematic', 'night'],
    publishedDate: _daysAgo(2),
    featured: true,
    trending: true,
    views: 1820,
    copies: 540,
    favorites: 130,
  ),
  Prompt(
    id: 'p03',
    title: 'Golden Lion Majesty',
    description:
        'A powerful wildlife portrait of a lion at golden hour. Rich warm tones on a dark background create an award-winning photography feel.',
    promptText:
        'Majestic lion portrait, golden hour light, dramatic dark background, detailed fur texture, intense amber eyes, professional wildlife photography, National Geographic style, ultra sharp, 8k',
    imageUrl: _imgAnimal,
    categoryId: 'animals',
    tags: ['animals', 'lion', 'wildlife', 'photography'],
    publishedDate: _daysAgo(3),
    featured: false,
    trending: true,
    views: 980,
    copies: 220,
    favorites: 74,
  ),
  Prompt(
    id: 'p04',
    title: 'Neon Warrior',
    description:
        'An anime-style warrior with a glowing energy sword. Great for character concepts and wallpaper art.',
    promptText:
        'Anime illustration of a female warrior holding a glowing energy sword, purple and electric blue neon aesthetic, dynamic pose, detailed digital anime art, dark background, dramatic lighting, high detail, 4k',
    imageUrl: _imgAnime,
    categoryId: 'anime',
    tags: ['anime', 'warrior', 'neon', 'fantasy', 'character'],
    publishedDate: _daysAgo(1),
    featured: false,
    trending: true,
    views: 1530,
    copies: 470,
    favorites: 112,
  ),
  Prompt(
    id: 'p05',
    title: 'Dreamscape Landscape',
    description:
        'A surreal neon dreamscape with floating islands. Ideal for wallpapers and fantasy scene concepts.',
    promptText:
        'Surreal dreamscape landscape, floating islands over a glowing purple and blue ocean, neon gradient sky, volumetric fog, fantasy art style, cinematic composition, ultra detailed, 8k',
    imageUrl: _imgArt,
    categoryId: 'fantasy',
    tags: ['fantasy', 'landscape', 'nature', 'wallpapers'],
    publishedDate: _daysAgo(5),
    featured: true,
    trending: false,
    views: 760,
    copies: 190,
    favorites: 61,
  ),
  Prompt(
    id: 'p06',
    title: 'Corporate Power Headshot',
    description:
        'A clean professional headshot prompt for LinkedIn-style profile pictures and business branding.',
    promptText:
        'Professional corporate headshot of a confident man in a navy suit, soft studio lighting, dark blue gradient background, sharp focus, shallow depth of field, LinkedIn profile style, ultra realistic, 8k',
    imageUrl: _imgBusiness,
    categoryId: 'professional',
    tags: ['professional', 'business', 'headshot', 'men'],
    publishedDate: _daysAgo(4),
    featured: false,
    trending: false,
    views: 430,
    copies: 98,
    favorites: 27,
  ),
  Prompt(
    id: 'p07',
    title: 'Cinematic Rain Kiss',
    description:
        'A romantic cinematic moment under neon rain. Perfect for love and couples themes.',
    promptText:
        'Cinematic shot of a couple embracing under neon rain at night, purple and blue city lights bokeh, romantic mood, film still aesthetic, shallow depth of field, ultra detailed, 4k',
    imageUrl: _imgWriting,
    categoryId: 'love',
    tags: ['love', 'couples', 'cinematic', 'romantic'],
    publishedDate: _daysAgo(6),
    featured: false,
    trending: false,
    views: 540,
    copies: 130,
    favorites: 45,
  ),
  Prompt(
    id: 'p08',
    title: 'Isometric 3D City',
    description:
        'A charming isometric 3D city render. Great for tech visuals and wallpapers.',
    promptText:
        'Isometric 3D render of a miniature city at night, glowing windows, purple and electric blue color palette, soft ambient occlusion, blender render, high detail, 4k',
    imageUrl: _imgArt,
    categoryId: '3d-art',
    tags: ['3d-art', 'city', 'isometric', 'gaming'],
    publishedDate: _daysAgo(7),
    featured: false,
    trending: false,
    views: 320,
    copies: 76,
    favorites: 22,
  ),
];

final List<NotificationItem> _sampleNotifications = [
  NotificationItem(
    id: 'n1',
    title: 'New Prompt Published',
    message: 'Neon Warrior has been added to the Anime category.',
    type: 'prompt',
    relatedPromptId: 'p04',
    date: _daysAgo(0),
  ),
  NotificationItem(
    id: 'n2',
    title: 'New Featured Prompt',
    message: 'Midnight Supercar is now featured on the Home screen.',
    type: 'featured',
    relatedPromptId: 'p02',
    date: _daysAgo(1),
  ),
  NotificationItem(
    id: 'n3',
    title: 'Trending Update',
    message: 'Neon Portrait Queen is trending this week!',
    type: 'trending',
    relatedPromptId: 'p01',
    date: _daysAgo(2),
  ),
  NotificationItem(
    id: 'n4',
    title: 'New Category Added',
    message: 'The Gaming category is now available.',
    type: 'category',
    date: _daysAgo(3),
  ),
];
