/// Prompt card data for the Vin Prompt app.
class PromptItem {
  final String title;
  final String category;
  final String prompt;
  final String imageUrl;

  const PromptItem({
    required this.title,
    required this.category,
    required this.prompt,
    required this.imageUrl,
  });
}

const List<PromptItem> kPrompts = [
  PromptItem(
    title: 'نېون منظرې',
    category: 'AI هنر',
    prompt:
        'A vibrant surreal landscape with glowing neon gradient sky in purple, magenta and cyan, floating geometric shapes, dreamy atmosphere, digital art, 4k',
    imageUrl:
        'https://d1qqeunc9izjbf.cloudfront.net/generated-images/40f4ad73.webp',
  ),
  PromptItem(
    title: 'کرهیټیف لیکل',
    category: 'لیکوالۍ',
    prompt:
        'Write a short inspiring story about a pen that brings dreams to life, warm and poetic tone, 200 words',
    imageUrl:
        'https://d1qqeunc9izjbf.cloudfront.net/generated-images/7cde6580.webp',
  ),
  PromptItem(
    title: 'کوډ مرستندوی',
    category: 'کوډنګ',
    prompt:
        'Act as a senior Flutter developer. Review my code and suggest clean architecture improvements with examples.',
    imageUrl:
        'https://d1qqeunc9izjbf.cloudfront.net/generated-images/77f7b5f8.webp',
  ),
  PromptItem(
    title: 'مارکیټنګ پلان',
    category: 'بزنس',
    prompt:
        'Create a 7-day social media marketing plan for a new mobile app launch, include daily post ideas and hashtags.',
    imageUrl:
        'https://d1qqeunc9izjbf.cloudfront.net/generated-images/e9f49b15.webp',
  ),
];
