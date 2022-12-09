import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class WalletProfile {

  const WalletProfile({
    this.metaid,
    required this.name,
    required this.token,
    required this.seedPath,
  });

  final String? metaid;
  final String name;
  final String token;
  final String seedPath;

  factory WalletProfile.fromJson(Map<String,dynamic> json) => WalletProfile(
    metaid: json['metaid']?.toString(),
    name: json['name'].toString(),
    token: json['token'].toString(),
    seedPath: json['seedPath'].toString()
  );
  
  Map<String, dynamic> toJson() => {
    'metaid': metaid,
    'name': name,
    'token': token,
    'seedPath': seedPath
  };

  WalletProfile clone() => WalletProfile(
    metaid: metaid,
    name: name,
    token: token,
    seedPath: seedPath
  );


  WalletProfile copyWith({
    Optional<String?>? metaid,
    String? name,
    String? token,
    String? seedPath
  }) => WalletProfile(
    metaid: checkOptional(metaid, () => this.metaid),
    name: name ?? this.name,
    token: token ?? this.token,
    seedPath: seedPath ?? this.seedPath,
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is WalletProfile && metaid == other.metaid && name == other.name && token == other.token && seedPath == other.seedPath;

  @override
  int get hashCode => metaid.hashCode ^ name.hashCode ^ token.hashCode ^ seedPath.hashCode;
}
