import 'dart:math';

const List<String> adjectives = ['Brave', 'Calm', 'Cheerful', 'Clever', 'Lively'];
const List<String> nouns = ['Person', 'Worker', 'Friend', 'Human', 'Personality'];

String generateSessionTitle() {
  final random = Random();
  final adjective = adjectives[random.nextInt(adjectives.length)];
  final noun = nouns[random.nextInt(nouns.length)];
  return '$adjective $noun';
}
