import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class Profile {

  const Profile({
    this.metaid,
    required this.token,
    required this.seedPath,
    required this.theme,
    this.locale,
  });

  final String? metaid;
  final String token;
  final String seedPath;
  final int theme;
  final String? locale;

  factory Profile.fromJson(Map<String,dynamic> json) => Profile(
    metaid: json['metaid']?.toString(),
    token: json['token'].toString(),
    seedPath: json['seedPath'].toString(),
    theme: json['theme'] as int,
    locale: json['locale']?.toString()
  );
  
  Map<String, dynamic> toJson() => {
    'metaid': metaid,
    'token': token,
    'seedPath': seedPath,
    'theme': theme,
    'locale': locale
  };

  Profile clone() => Profile(
    metaid: metaid,
    token: token,
    seedPath: seedPath,
    theme: theme,
    locale: locale
  );


  Profile copyWith({
    Optional<String?>? metaid,
    String? token,
    String? seedPath,
    int? theme,
    Optional<String?>? locale
  }) => Profile(
    metaid: checkOptional(metaid, () => this.metaid),
    token: token ?? this.token,
    seedPath: seedPath ?? this.seedPath,
    theme: theme ?? this.theme,
    locale: checkOptional(locale, () => this.locale),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is Profile && metaid == other.metaid && token == other.token && seedPath == other.seedPath && theme == other.theme && locale == other.locale;

  @override
  int get hashCode => metaid.hashCode ^ token.hashCode ^ seedPath.hashCode ^ theme.hashCode ^ locale.hashCode;
}
