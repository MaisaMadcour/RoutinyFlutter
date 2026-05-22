import 'package:flutter/material.dart';

/// Maps the task icon id (stored in the DB) to a Material [IconData].
/// Mirrors the Android TaskIconLibrary.
class TaskIcons {
  TaskIcons._();

  static const Map<String, IconData> _map = {
    // Favorites / general
    'star': Icons.star,
    'star_border': Icons.star_border,
    'favorite': Icons.favorite,
    'favorite_border': Icons.favorite_border,
    'emoji_emotions': Icons.emoji_emotions,
    'emoji_events': Icons.emoji_events,
    'emoji_nature': Icons.emoji_nature,
    'emoji_people': Icons.emoji_people,
    'mood': Icons.mood,
    'sentiment_satisfied': Icons.sentiment_satisfied,
    'check_circle': Icons.check_circle,
    'done_all': Icons.done_all,
    'flag': Icons.flag,
    'label': Icons.label,
    'bookmark': Icons.bookmark,
    // Home / daily life
    'home': Icons.home,
    'weekend': Icons.weekend,
    'king_bed': Icons.king_bed,
    'bathtub': Icons.bathtub,
    'cleaning_services': Icons.cleaning_services,
    'local_laundry_service': Icons.local_laundry_service,
    'iron': Icons.iron,
    'kitchen': Icons.kitchen,
    'blender': Icons.blender,
    'microwave': Icons.microwave,
    'yard': Icons.yard,
    'grass': Icons.grass,
    // Work / study
    'work': Icons.work,
    'business_center': Icons.business_center,
    'school': Icons.school,
    'edit': Icons.edit,
    'menu_book': Icons.menu_book,
    'auto_stories': Icons.auto_stories,
    'library_books': Icons.library_books,
    'science': Icons.science,
    'calculate': Icons.calculate,
    'assignment': Icons.assignment,
    'note_alt': Icons.note_alt,
    'description': Icons.description,
    'laptop': Icons.laptop,
    'computer': Icons.computer,
    'keyboard': Icons.keyboard,
    'mail': Icons.mail,
    'inbox': Icons.inbox,
    'send': Icons.send,
    // Health / fitness
    'fitness_center': Icons.fitness_center,
    'directions_run': Icons.directions_run,
    'directions_walk': Icons.directions_walk,
    'directions_bike': Icons.directions_bike,
    'pool': Icons.pool,
    'spa': Icons.spa,
    'self_improvement': Icons.self_improvement,
    'local_hospital': Icons.local_hospital,
    'medical_services': Icons.medical_services,
    'medication': Icons.medication,
    'vaccines': Icons.vaccines,
    'monitor_heart': Icons.monitor_heart,
    'bedtime': Icons.bedtime,
    'air': Icons.air,
    'water_drop': Icons.water_drop,
    'opacity': Icons.opacity,
    // Sports
    'sports_soccer': Icons.sports_soccer,
    'sports_basketball': Icons.sports_basketball,
    'sports_tennis': Icons.sports_tennis,
    'sports_volleyball': Icons.sports_volleyball,
    'sports_golf': Icons.sports_golf,
    'sports_handball': Icons.sports_handball,
    'sports_martial_arts': Icons.sports_martial_arts,
    'hiking': Icons.hiking,
    'skateboarding': Icons.skateboarding,
    'snowboarding': Icons.snowboarding,
    // Food / drink
    'local_cafe': Icons.local_cafe,
    'restaurant': Icons.restaurant,
    'lunch_dining': Icons.lunch_dining,
    'dinner_dining': Icons.dinner_dining,
    'fastfood': Icons.fastfood,
    'local_pizza': Icons.local_pizza,
    'cake': Icons.cake,
    'icecream': Icons.icecream,
    'bakery_dining': Icons.bakery_dining,
    'local_bar': Icons.local_bar,
    'local_drink': Icons.local_drink,
    'wine_bar': Icons.wine_bar,
    'set_meal': Icons.set_meal,
    'rice_bowl': Icons.rice_bowl,
    'ramen_dining': Icons.ramen_dining,
    // Shopping / money
    'shopping_cart': Icons.shopping_cart,
    'shopping_bag': Icons.shopping_bag,
    'attach_money': Icons.attach_money,
    'credit_card': Icons.credit_card,
    'account_balance': Icons.account_balance,
    'savings': Icons.savings,
    'card_giftcard': Icons.card_giftcard,
    'redeem': Icons.redeem,
    'receipt': Icons.receipt,
    'paid': Icons.paid,
    // Tech / devices
    'phone_iphone': Icons.phone_iphone,
    'tv': Icons.tv,
    'headset': Icons.headset,
    'headphones': Icons.headphones,
    'camera_alt': Icons.camera_alt,
    'videocam': Icons.videocam,
    'print': Icons.print,
    'router': Icons.router,
    'watch': Icons.watch,
    'build': Icons.build,
    // Creativity / art
    'palette': Icons.palette,
    'brush': Icons.brush,
    'color_lens': Icons.color_lens,
    'music_note': Icons.music_note,
    'piano': Icons.piano,
    'queue_music': Icons.queue_music,
    'movie': Icons.movie,
    'theaters': Icons.theaters,
    'photo': Icons.photo,
    'draw': Icons.draw,
    'style': Icons.style,
    'auto_awesome': Icons.auto_awesome,
    // Nature / environment
    'wb_sunny': Icons.wb_sunny,
    'brightness_3': Icons.brightness_3,
    'local_florist': Icons.local_florist,
    'eco': Icons.eco,
    'park': Icons.park,
    'forest': Icons.forest,
    'pets': Icons.pets,
    'cloud': Icons.cloud,
    'ac_unit': Icons.ac_unit,
    'thunderstorm': Icons.thunderstorm,
    // Travel / transport
    'flight': Icons.flight,
    'beach_access': Icons.beach_access,
    'location_on': Icons.location_on,
    'map': Icons.map,
    'directions_car': Icons.directions_car,
    'train': Icons.train,
    'directions_bus': Icons.directions_bus,
    'local_taxi': Icons.local_taxi,
    'two_wheeler': Icons.two_wheeler,
    'luggage': Icons.luggage,
    // Time / organization
    'alarm': Icons.alarm,
    'schedule': Icons.schedule,
    'event': Icons.event,
    'today': Icons.today,
    'date_range': Icons.date_range,
    'notifications': Icons.notifications,
    'timer': Icons.timer,
    'hourglass_empty': Icons.hourglass_empty,
    // Social / communication
    'people': Icons.people,
    'person': Icons.person,
    'group': Icons.group,
    'family_restroom': Icons.family_restroom,
    'handshake': Icons.handshake,
    'volunteer_activism': Icons.volunteer_activism,
    'diversity_3': Icons.diversity_3,
    'chat': Icons.chat,
    'forum': Icons.forum,
    'call': Icons.call,
  };

  /// The picker shows the icons in this order.
  static List<String> get all => _map.keys.toList();

  static IconData of(String id) {
    if (_map.containsKey(id)) return _map[id]!;
    // legacy `ic_*` resource names
    switch (id) {
      case 'ic_routiny_sparkles':
        return Icons.auto_awesome;
      case 'ic_routiny_check':
      case 'ic_routiny_check_circle':
        return Icons.check_circle;
      default:
        return Icons.star;
    }
  }
}
