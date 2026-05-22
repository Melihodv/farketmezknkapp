class AppConstants {
  // ── App Info ────────────────────────────────────────────
  static const String appName    = 'Farketmez Kanka';
  static const String appTagline = 'Ne yapalım? Farketmez kanka.';
  static const String appVersion = '1.0.0';

  // ── Google Maps ─────────────────────────────────────────
  static const String googleMapsApiKey = 'AIzaSyAgBG8RFM4qpV9UoP6fGynrikC-4_Sfrxo';

  // ── Search Options ──────────────────────────────────────
  static const List<int>    radiusOptions = [500, 1000, 2000, 5000, 15000];
  static const List<String> radiusLabels  = ['500m', '1km', '2km', '5km', '10+km'];

  // ── Group Types ──────────────────────────────────────────
  // Her tip Places API aramasını farklı şekilde etkiler
  static const List<Map<String, dynamic>> groupTypes = [
    {
      'id': 'solo',
      'label': 'Yalnız',
      'subtitle': 'Kendi başıma',
      'keyword': null,
      'minRating': 4.0,
      // Sakin, hiş yokluğu dolu mekanlar — bar/gece kulübü çıkmasın
      'excludeTypes': ['night_club', 'casino', 'amusement_park'],
    },
    {
      'id': 'romantic',
      'label': 'Sevgili',
      'subtitle': 'Romantik an',
      'keyword': 'romantic cozy dinner',
      'minRating': 4.2,
      // Saçma yerler çıkmasın
      'excludeTypes': ['night_club', 'casino', 'bowling_alley', 'amusement_park', 'supermarket', 'convenience_store', 'grocery_or_supermarket', 'hardware_store', 'gas_station'],
    },
    {
      'id': 'friends',
      'label': 'Arkadaşlar',
      'subtitle': 'Kafadar takım',
      'keyword': null,
      'minRating': 3.5,
      // Arkadaşlarla her şey gidebilir
      'excludeTypes': ['supermarket', 'hardware_store', 'gas_station'],
    },
    {
      'id': 'family',
      'label': 'Aile',
      'subtitle': 'Aile keyfi',
      'keyword': 'family friendly',
      'minRating': 4.0,
      // Bar, gece kulübü ve casino kesinlikle çıkmasın
      'excludeTypes': ['bar', 'night_club', 'casino', 'liquor_store'],
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
      // Bar/gece kulübü/casino ayrıca excludeTypes ile filtreleniyor — bu liste sadece aile/sevgili dışı durumlar için
      'types': ['movie_theater', 'bowling_alley', 'amusement_park', 'night_club', 'bar'],
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
  static const List<String> outdoorActivities = [
    'Açık havanın tadını çıkarın, güzel bir yürüyüş yapın 🚶‍♂️',
    'Doğanın içinde derin bir nefes alıp stresten uzaklaşın 🍃',
    'Manzaraya karşı oturup sakinliğin keyfini sürün 🌅',
    'Etrafı keşfedin ve güzel fotoğraflar çekin 📸',
    'Güneşin veya esintinin tadını çıkararak dinlenin ☀️',
    'Beraber sessizliğin ve huzurun tadını çıkarın 🏕️',
    'Yakın çevrede daha önce görmediğiniz detayları keşfedin 🔍',
    'Sevdiğiniz bir içeceği alıp yürüyüşe eşlik edin ☕',
  ];

  // ── Romantic Activity Suggestions ───────────────────────
  static const List<String> romanticActivities = [
    'Şehrin en güzel manzarasını bulup sessizliğin tadını çıkarın 🌃',
    'Birlikte yeni bir lezzet keşfedin, daha önce denemediğiniz bir şey sipariş edin 🍽️',
    'Gelecekteki seyahat planlarınızı konuşun ve hayal kurun ✈️',
    'Birbirinize en sevdiğiniz anılarınızı anlatın 🥰',
    'Telefonları sessize alıp sadece anın tadını çıkarın 📵',
    'Tatlı veya kahve eşliğinde uzun uzun sohbet edin ☕🍰',
    'Akşam yürüyüşü yapıp günün yorgunluğunu atın 🌙',
    'İlk tanıştığınız gün hakkında konuşup eski günleri yad edin 💭',
    'Bugünü unutulmaz kılmak için güzel bir fotoğraf çekilin 📷',
  ];

  // ── Friends Activity Suggestions ──────────────────────
  static const List<String> friendsActivities = [
    'En komik anılarınızı hatırlayıp gülmekten karnınıza ağrılar girsin 😂',
    'Kim hesabı ödeyecek diye iddiaya girin veya alman usulü yapın 💸',
    'Ortak bir tatil planı yapın, bakalım kim önce vazgeçecek 🏖️',
    'Bol bol fotoğraf çekilip anı ölümsüzleştirin 📸',
    'Uzun zamandır görüşmediğiniz konuları masaya yatırın 🗣️',
    'Favori dizileriniz veya filmleriniz hakkında tartışın 🎬',
    'Grupça yeni bir mekan veya etkinlik keşfedin 🗺️',
    'Kolektif bir playlist açıp sevdiğiniz müzikleri dinleyin 🎵',
  ];

  // ── Solo Activity Suggestions ──────────────────────────
  static const List<String> soloActivities = [
    'Kulaklığını tak ve favori şarkılarınla kendi dünyana çekil 🎧',
    'O çok ertelediğin kitabı veya podcast\'i bitirmek için harika bir zaman 📖',
    'Sadece etrafı izle, anın tadını çıkar ve düşüncelerini toparla ☕',
    'Kendine güzel bir kahve veya tatlı ısmarla, bunu hak ettin 🍰',
    'Gelecek hedeflerini gözden geçirip planlar yap 📝',
    'Şehrin sokaklarında kaybolarak yeni bir mekan keşfet 🚶‍♂️',
    'Telefonu bir kenara bırakıp zihnini dinlendir 📵',
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
