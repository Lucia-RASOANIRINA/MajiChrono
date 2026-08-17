import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:majichrono/core/network/api_endpoints.dart';
import 'package:majichrono/core/providers/core_providers.dart';
import 'package:majichrono/features/delivery/domain/entities/delivery_options.dart';

/// Reseau de points relais partenaires (differenciant D6).
///
/// Servi par quartier lorsqu'on en connait un : proposer les relais de toute
/// l'agglomeration a quelqu'un qui livre a Ambohipo lui ferait faire defiler une
/// liste dont dix-neuf entrees sur vingt sont hors sujet.
final relayPointsProvider =
    FutureProvider.autoDispose.family<List<RelayPoint>, String?>(
  (ref, district) async {
    final json = await ref.watch(apiClientProvider).get<Map<String, dynamic>>(
      ApiEndpoints.relayPoints,
      query: {'district': ?district},
    );

    return (json['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(RelayPoint.fromJson)
        .whereType<RelayPoint>()
        .toList();
  },
);
