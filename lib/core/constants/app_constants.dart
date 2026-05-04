class AppConstants {
  // ── App Info ────────────────────────────────────────────
  static const String appName    = 'Farketmez Kanka';
  static const String appTagline = 'Ne yapalım? Farketmez kanka.';
  static const String appVersion = '1.0.0';

  // ── Google Maps ─────────────────────────────────────────
  static const String googleMapsApiKey = 'AIzaSyAgBG8RFM4qpV9UoP6fGynrikC-4_Sfrxo';

  // ── Search Options ──────────────────────────────────────
  static const List<int>    radiusOptions = [500, 1000, 3000, 5000];
  static const List<String> radiusLabels  = ['500m', '1km', '3km', '5km'];

  // ── Group Types ──────────────────────────────────────────
  // Her tip Places API aramasını farklı şekilde etkiler
  static const List<Map<String, dynamic>> groupTypes = [
    {
      'id': 'solo',
      'label': 'Yalnız',
      'subtitle': 'Kendi başıma',
      'keyword': null,
      'minRating': 4.0,
    },
    {
      'id': 'romantic',
      'label': 'Sevgili',
      'subtitle': 'Romantik an',
      'keyword': 'romantic cozy',
      'minRating': 4.2,
    },
    {
      'id': 'friends',
      'label': 'Arkadaşlar',
      'subtitle': 'Kafadar takım',
      'keyword': null,
      'minRating': 3.5,
    },
    {
      'id': 'family',
      'label': 'Aile',
      'subtitle': 'Aile keyfi',
      'keyword': 'family friendly',
      'minRating': 4.0,
    },
  ];

  // ── Categories ──────────────────────────────────────────
  static const List<Map<String, dynamic>> categories = [
    {
      'id': 'food',
      'label': 'Yemek',
      'types': ['restaurant', 'food', 'meal_takeaway'],
    },
    {
      'id': 'coffee',
      'label': 'Kahve',
      'types': ['cafe', 'bakery'],
    },
    {
      'id': 'dessert',
      'label': 'Tatlı',
      'types': ['bakery', 'ice_cream'],
    },
    {
      'id': 'entertainment',
      'label': 'Eğlence',
      'types': ['movie_theater', 'bowling_alley', 'amusement_park', 'night_club', 'bar', 'casino'],
    },
    {
      'id': 'outdoor',
      'label': 'Dışarı',
      'types': ['park', 'natural_feature', 'campground', 'rv_park'],
    },
    {
      'id': 'culture',
      'label': 'Kültür',
      'types': ['museum', 'art_gallery', 'tourist_attraction', 'historic_site', 'library'],
    },
  ];

  // ── Outdoor Activity Suggestions ────────────────────────
  // Dışarı kategorisinde rastgele gösterilir
  static const List<String> outdoorActivities = [
    'Kola, çıtlak ve çekirdek alın, güzel bir köşeye yayılın 🥤',
    'Spotify\'dan ortak playlist oluşturun, müziğin tadını çıkarın 🎵',
    'Vampir köylü oynayın, kim vampir kim köylü bakalım 🧛‍♂️',
    'Kameralar hazır! Yaratıcı pozlar verin, içerik üretin 📸',
    'Taş atlama yarışması yapın, kim daha uzağa atar? 🪨',
    'Sandalyeler hazır, güneşin tadını çıkarın ☀️',
    'Kek al, mumlar dik, aniden doğum günü yapın 🎂',
    'Herkes telefonunu ortaya bıraksın, ilk bakan kaybeder 📵',
    'Biriniz yüksek sesle roman okusun, dinleyin 📖',
    'Hayatta yapılacaklar listesi yazın, sonra karşılaştırın 📝',
    'Frizbee veya top var mı? Sahaya inin hemen 🥏',
    'Kim en komik yürüyüşü yapar? Yarışma başlasın 🚶',
    'Birbirinize "Hayatında en..." soruları sorun 🤔',
    'Hızlı el sıkışma ritmi yarışın, kim en hızlı? 🤝',
    'Herkes farklı bir atıştırmalık alsın, tadım yapın 🍿',
    'Ateş yakın (izinliyse), marshmallow kavurun 🔥',
    'Yakın çevreyi keşfedin, daha önce hiç gitmediniz mi buraya? 🗺️',
    'Hareket oyunu: son hareket eden kaybeder 🙅',
    'Birbirinize "sana göre en iyi film" sorun, liste yapın 🎬',
    'Gökyüzüne bakın, bulutlarda şekil bulun ☁️',
  ];

  // ── Memory ──────────────────────────────────────────────
  static const int maxNegativeVotes   = 3;
  static const int repeatVisitWarning = 3;

  // ── Firestore Collections ───────────────────────────────
  static const String usersCollection     = 'users';
  static const String placesCollection    = 'places';
  static const String visitsCollection    = 'visits';
  static const String feedbackCollection  = 'feedback';
  static const String sponsoredCollection = 'sponsored_places';

  // ── SharedPreferences Keys ──────────────────────────────
  static const String prefOnboarded       = 'is_onboarded';
  static const String prefUserId          = 'user_id';
  static const String prefGuestMode       = 'is_guest';
  static const String prefSelectedRadius  = 'selected_radius';
  static const String prefSelectedGroup   = 'selected_group';
  static const String prefSelectedCategory = 'selected_category';
  static const String prefVegetarian      = 'is_vegetarian';
  static const String prefSpicy           = 'likes_spicy';
  static const String prefBudget          = 'budget_level';

  // ── Budget ──────────────────────────────────────────────
  static const List<String> budgetLevels = ['Ekonomik', 'Orta', 'Fark etmez'];
}
