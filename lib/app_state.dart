import 'package:flutter/material.dart';
import 'flutter_flow/request_manager.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/api_requests/api_manager.dart';
import 'backend/supabase/supabase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _email = prefs.getString('ff_email') ?? _email;
    });
    _safeInit(() {
      _adminPage = prefs.getString('ff_adminPage') ?? _adminPage;
    });
    _safeInit(() {
      _firstOpen = prefs.getBool('ff_firstOpen') ?? _firstOpen;
    });
    _safeInit(() {
      _hasGuestGetLichtwatt =
          prefs.getBool('ff_hasGuestGetLichtwatt') ?? _hasGuestGetLichtwatt;
    });
    _safeInit(() {
      _onboardingCompleted =
          prefs.getBool('ff_onboardingCompleted') ?? _onboardingCompleted;
    });
    _safeInit(() {
      _hasUserLoggedOut =
          prefs.getBool('ff_hasUserLoggedOut') ?? _hasUserLoggedOut;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  String _email = '';
  String get email => _email;
  set email(String value) {
    _email = value;
    prefs.setString('ff_email', value);
  }

  DateTime? _refreshDate;
  DateTime? get refreshDate => _refreshDate;
  set refreshDate(DateTime? value) {
    _refreshDate = value;
  }

  String _adminPage = 'statistic';
  String get adminPage => _adminPage;
  set adminPage(String value) {
    _adminPage = value;
    prefs.setString('ff_adminPage', value);
  }

  bool _firstOpen = true;
  bool get firstOpen => _firstOpen;
  set firstOpen(bool value) {
    _firstOpen = value;
    prefs.setBool('ff_firstOpen', value);
  }

  bool _terms = false;
  bool get terms => _terms;
  set terms(bool value) {
    _terms = value;
  }

  bool _hasGuestGetLichtwatt = false;
  bool get hasGuestGetLichtwatt => _hasGuestGetLichtwatt;
  set hasGuestGetLichtwatt(bool value) {
    _hasGuestGetLichtwatt = value;
    prefs.setBool('ff_hasGuestGetLichtwatt', value);
  }

  int _guestNumber = 0;
  int get guestNumber => _guestNumber;
  set guestNumber(int value) {
    _guestNumber = value;
  }

  bool _onboardingCompleted = false;
  bool get onboardingCompleted => _onboardingCompleted;
  set onboardingCompleted(bool value) {
    _onboardingCompleted = value;
    prefs.setBool('ff_onboardingCompleted', value);
  }

  /// Check if user has logged out to navigate him to login page instead of give
  /// him guest mode
  bool _hasUserLoggedOut = false;
  bool get hasUserLoggedOut => _hasUserLoggedOut;
  set hasUserLoggedOut(bool value) {
    _hasUserLoggedOut = value;
    prefs.setBool('ff_hasUserLoggedOut', value);
  }

  final _userManager = FutureRequestManager<List<UsersRow>>();
  Future<List<UsersRow>> user({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<UsersRow>> Function() requestFn,
  }) =>
      _userManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearUserCache() => _userManager.clear();
  void clearUserCacheKey(String? uniqueKey) =>
      _userManager.clearRequest(uniqueKey);

  final _postsManager = StreamRequestManager<List<PostsRow>>();
  Stream<List<PostsRow>> posts({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Stream<List<PostsRow>> Function() requestFn,
  }) =>
      _postsManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearPostsCache() => _postsManager.clear();
  void clearPostsCacheKey(String? uniqueKey) =>
      _postsManager.clearRequest(uniqueKey);

  final _gamesManager = StreamRequestManager<List<GamesRow>>();
  Stream<List<GamesRow>> games({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Stream<List<GamesRow>> Function() requestFn,
  }) =>
      _gamesManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearGamesCache() => _gamesManager.clear();
  void clearGamesCacheKey(String? uniqueKey) =>
      _gamesManager.clearRequest(uniqueKey);

  final _gamesUserManager = FutureRequestManager<List<GamesRow>>();
  Future<List<GamesRow>> gamesUser({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<GamesRow>> Function() requestFn,
  }) =>
      _gamesUserManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearGamesUserCache() => _gamesUserManager.clear();
  void clearGamesUserCacheKey(String? uniqueKey) =>
      _gamesUserManager.clearRequest(uniqueKey);

  final _userPostsManager = StreamRequestManager<List<PostsRow>>();
  Stream<List<PostsRow>> userPosts({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Stream<List<PostsRow>> Function() requestFn,
  }) =>
      _userPostsManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearUserPostsCache() => _userPostsManager.clear();
  void clearUserPostsCacheKey(String? uniqueKey) =>
      _userPostsManager.clearRequest(uniqueKey);

  final _orgPostsManager = StreamRequestManager<List<PostsRow>>();
  Stream<List<PostsRow>> orgPosts({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Stream<List<PostsRow>> Function() requestFn,
  }) =>
      _orgPostsManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearOrgPostsCache() => _orgPostsManager.clear();
  void clearOrgPostsCacheKey(String? uniqueKey) =>
      _orgPostsManager.clearRequest(uniqueKey);

  final _invitesManager = FutureRequestManager<List<InvitesRow>>();
  Future<List<InvitesRow>> invites({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<InvitesRow>> Function() requestFn,
  }) =>
      _invitesManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearInvitesCache() => _invitesManager.clear();
  void clearInvitesCacheKey(String? uniqueKey) =>
      _invitesManager.clearRequest(uniqueKey);

  final _followUserManager = FutureRequestManager<List<FollowersRow>>();
  Future<List<FollowersRow>> followUser({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<FollowersRow>> Function() requestFn,
  }) =>
      _followUserManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearFollowUserCache() => _followUserManager.clear();
  void clearFollowUserCacheKey(String? uniqueKey) =>
      _followUserManager.clearRequest(uniqueKey);
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
