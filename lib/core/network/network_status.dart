import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:majichrono/core/network/api_client.dart';
import 'package:majichrono/core/network/network_profile.dart';

/// Etat reseau expose a toute l'application (EXI-T06).
class NetworkStatus {
  const NetworkStatus({
    required this.reachable,
    required this.profile,
    required this.transport,
    required this.lastProbeAt,
    this.rttMs,
  });

  const NetworkStatus.unknown()
    : reachable = false,
      profile = NetworkProfile.offline,
      transport = NetworkTransport.none,
      rttMs = null,
      lastProbeAt = null;

  /// Le serveur repond reellement — et pas seulement « une interface est up ».
  final bool reachable;
  final NetworkProfile profile;
  final NetworkTransport transport;
  final int? rttMs;
  final DateTime? lastProbeAt;

  bool get isOnline => reachable;

  NetworkStatus copyWith({
    bool? reachable,
    NetworkProfile? profile,
    NetworkTransport? transport,
    int? rttMs,
    DateTime? lastProbeAt,
  }) => NetworkStatus(
    reachable: reachable ?? this.reachable,
    profile: profile ?? this.profile,
    transport: transport ?? this.transport,
    rttMs: rttMs ?? this.rttMs,
    lastProbeAt: lastProbeAt ?? this.lastProbeAt,
  );
}

enum NetworkTransport { none, mobile, wifi, ethernet, other }

/// Service d'etat reseau.
///
/// `connectivity_plus` seul ne suffit pas : a Antananarivo une interface mobile
/// peut etre « connectee » sans qu'aucun paquet ne passe. Le service croise
/// donc l'etat systeme avec une **sonde applicative** sur `/health`, et c'est
/// le temps d'aller-retour mesure qui qualifie le profil (§9.2).
class NetworkStatusService {
  NetworkStatusService({
    required this._apiClient,
    Connectivity? connectivity,
    this._probeInterval = const Duration(seconds: 30),
  }) : _connectivity = connectivity ?? Connectivity();

  final ApiClient _apiClient;
  final Connectivity _connectivity;
  final Duration _probeInterval;

  /// Cadence rapide quand l'appareil est connecte mais le serveur injoignable :
  /// c'est le cas du reveil du serveur (plan gratuit, ~30 s). On sonde souvent
  /// pour repasser « en ligne » des la premiere reponse, plutot que d'attendre
  /// le prochain tour lent et de laisser l'utilisateur devant un ecran fige.
  static const Duration _wakingInterval = Duration(seconds: 4);

  final StreamController<NetworkStatus> _controller =
      StreamController<NetworkStatus>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _timer;
  NetworkStatus _current = const NetworkStatus.unknown();
  bool _probing = false;

  Stream<NetworkStatus> get stream => _controller.stream;
  NetworkStatus get current => _current;

  Future<void> start() async {
    _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
      final transport = _mapTransport(results);
      _emit(_current.copyWith(transport: transport));
      // Un changement d'interface justifie une sonde immediate, puis on recale
      // la cadence sur le nouvel etat (reveil rapide, sinon lent).
      unawaited(refresh().then((_) => _scheduleNext()));
    });
    await refresh();
    _scheduleNext();
  }

  /// Reprogramme la prochaine sonde, cadence choisie selon l'etat courant :
  /// rapide tant que le serveur ne repond pas alors que l'appareil est connecte
  /// (reveil), lente une fois en ligne.
  void _scheduleNext() {
    _timer?.cancel();
    // Tant que le serveur ne repond pas, on resonde vite (reveil du plan gratuit,
    // coupure passagere) pour repasser « en ligne » des que possible ; une fois
    // joignable, on espace. On ne se fie plus au transport, juge peu fiable.
    final interval = _current.reachable ? _probeInterval : _wakingInterval;
    _timer = Timer(interval, () async {
      await refresh();
      _scheduleNext();
    });
  }

  /// Force une mesure. Sans effet si une mesure est deja en vol.
  Future<NetworkStatus> refresh() async {
    if (_probing) return _current;
    _probing = true;
    try {
      // La lecture du transport ne doit jamais empecher la sonde : si le plugin
      // systeme echoue, on continue quand meme a tester le serveur.
      NetworkTransport transport;
      try {
        transport = _mapTransport(await _connectivity.checkConnectivity());
      } on Object {
        transport = NetworkTransport.other;
      }
      // On sonde **toujours** le serveur, quoi que dise `connectivity_plus`.
      // Sur certains telephones il rapporte « aucune connexion » a tort (Android
      // recent, VPN, double SIM...) ; gater la sonde sur son verdict laissait
      // l'application « hors ligne » en permanence alors que le serveur repond
      // parfaitement. La seule verite qui compte ici, c'est : est-ce que le
      // serveur repond ? Le transport ne sert plus qu'a l'affichage.
      final rtt = await _apiClient.probe();
      _emit(
        NetworkStatus(
          reachable: rtt != null,
          profile: NetworkProfile.fromRttMs(rtt),
          transport: rtt != null && transport == NetworkTransport.none
              // Le serveur repond mais l'OS dit « aucune interface » : on ne le
              // croit pas, on marque « autre » plutot que de garder « none ».
              ? NetworkTransport.other
              : transport,
          rttMs: rtt,
          lastProbeAt: DateTime.now(),
        ),
      );
      return _current;
    } finally {
      _probing = false;
    }
  }

  void _emit(NetworkStatus status) {
    _current = status;
    if (!_controller.isClosed) _controller.add(status);
  }

  NetworkTransport _mapTransport(List<ConnectivityResult> results) {
    if (results.isEmpty || results.every((r) => r == ConnectivityResult.none)) {
      return NetworkTransport.none;
    }
    if (results.contains(ConnectivityResult.wifi)) return NetworkTransport.wifi;
    if (results.contains(ConnectivityResult.mobile)) {
      return NetworkTransport.mobile;
    }
    if (results.contains(ConnectivityResult.ethernet)) {
      return NetworkTransport.ethernet;
    }
    return NetworkTransport.other;
  }

  Future<void> dispose() async {
    _timer?.cancel();
    await _connectivitySub?.cancel();
    await _controller.close();
  }
}
