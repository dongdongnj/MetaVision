import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class Profile {

  const Profile({
    required this.theme,
    this.locale,
    required this.curWallet,
    required this.wallets,
  });

  final int theme;
  final String? locale;
  final int curWallet;
  final List<WalletProfile> wallets;

  factory Profile.fromJson(Map<String,dynamic> json) => Profile(
    theme: json['theme'] as int,
    locale: json['locale']?.toString(),
    curWallet: json['curWallet'] as int,
    wallets: (json['wallets'] as List? ?? []).map((e) => WalletProfile.fromJson(e as Map<String, dynamic>)).toList()
  );
  
  Map<String, dynamic> toJson() => {
    'theme': theme,
    'locale': locale,
    'curWallet': curWallet,
    'wallets': wallets.map((e) => e.toJson()).toList()
  };

  Profile clone() => Profile(
    theme: theme,
    locale: locale,
    curWallet: curWallet,
    wallets: wallets.map((e) => e.clone()).toList()
  );


  Profile copyWith({
    int? theme,
    Optional<String?>? locale,
    int? curWallet,
    List<WalletProfile>? wallets
  }) => Profile(
    theme: theme ?? this.theme,
    locale: checkOptional(locale, () => this.locale),
    curWallet: curWallet ?? this.curWallet,
    wallets: wallets ?? this.wallets,
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is Profile && theme == other.theme && locale == other.locale && curWallet == other.curWallet && wallets == other.wallets;

  @override
  int get hashCode => theme.hashCode ^ locale.hashCode ^ curWallet.hashCode ^ wallets.hashCode;
}
