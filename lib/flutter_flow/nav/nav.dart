import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';

import '/auth/base_auth_user_provider.dart';

import '/main.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/lat_lng.dart';
import '/flutter_flow/place.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'serialization_util.dart';

import '/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) => appStateNotifier.loggedIn
          ? HomePageWidget()
          : OnboardingPageInitialWidget(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) => appStateNotifier.loggedIn
              ? HomePageWidget()
              : OnboardingPageInitialWidget(),
        ),
        FFRoute(
          name: HomePageWidget.routeName,
          path: HomePageWidget.routePath,
          builder: (context, params) => HomePageWidget(),
        ),
        FFRoute(
          name: SplashWidget.routeName,
          path: SplashWidget.routePath,
          builder: (context, params) => SplashWidget(),
        ),
        FFRoute(
          name: LoginWidget.routeName,
          path: LoginWidget.routePath,
          builder: (context, params) => LoginWidget(),
        ),
        FFRoute(
          name: ConfirmWidget.routeName,
          path: ConfirmWidget.routePath,
          builder: (context, params) => ConfirmWidget(
            email: params.getParam(
              'email',
              ParamType.String,
            ),
            password: params.getParam(
              'password',
              ParamType.String,
            ),
            username: params.getParam(
              'username',
              ParamType.String,
            ),
            firstName: params.getParam(
              'firstName',
              ParamType.String,
            ),
            actionType: params.getParam(
              'actionType',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: ForgotpasswordWidget.routeName,
          path: ForgotpasswordWidget.routePath,
          builder: (context, params) => ForgotpasswordWidget(
            email: params.getParam(
              'email',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: GoodNewsPageWidget.routeName,
          path: GoodNewsPageWidget.routePath,
          builder: (context, params) => GoodNewsPageWidget(),
        ),
        FFRoute(
          name: EnergyPageWidget.routeName,
          path: EnergyPageWidget.routePath,
          builder: (context, params) => EnergyPageWidget(),
        ),
        FFRoute(
          name: PlayPageWidget.routeName,
          path: PlayPageWidget.routePath,
          builder: (context, params) => PlayPageWidget(
            gameDT: params.getParam(
              'gameDT',
              ParamType.DataStruct,
              isList: false,
              structBuilder: GameStruct.fromSerializableMap,
            ),
          ),
        ),
        FFRoute(
          name: PlayPaymentPageWidget.routeName,
          path: PlayPaymentPageWidget.routePath,
          builder: (context, params) => PlayPaymentPageWidget(
            game: params.getParam(
              'game',
              ParamType.DataStruct,
              isList: false,
              structBuilder: GameStruct.fromSerializableMap,
            ),
            user: params.getParam<UsersRow>(
              'user',
              ParamType.SupabaseRow,
            ),
            guestChosenOrgId: params.getParam(
              'guestChosenOrgId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: FinishPageWidget.routeName,
          path: FinishPageWidget.routePath,
          requireAuth: true,
          builder: (context, params) => FinishPageWidget(
            gameId: params.getParam(
              'gameId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: OrganisationPageWidget.routeName,
          path: OrganisationPageWidget.routePath,
          builder: (context, params) => OrganisationPageWidget(
            orgId: params.getParam(
              'orgId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: GamePageWidget.routeName,
          path: GamePageWidget.routePath,
          requireAuth: true,
          builder: (context, params) => GamePageWidget(
            gameRow: params.getParam<GamesRow>(
              'gameRow',
              ParamType.SupabaseRow,
            ),
          ),
        ),
        FFRoute(
          name: GoodGamesPageWidget.routeName,
          path: GoodGamesPageWidget.routePath,
          builder: (context, params) => GoodGamesPageWidget(
            periodGames: params.getParam(
              'periodGames',
              ParamType.String,
            ),
            valueGames: params.getParam(
              'valueGames',
              ParamType.String,
            ),
            tab: params.getParam(
              'tab',
              ParamType.int,
            ),
          ),
        ),
        FFRoute(
          name: ForgotpasswordSendWidget.routeName,
          path: ForgotpasswordSendWidget.routePath,
          builder: (context, params) => ForgotpasswordSendWidget(
            email: params.getParam(
              'email',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: SuccessPageWidget.routeName,
          path: SuccessPageWidget.routePath,
          builder: (context, params) => SuccessPageWidget(),
        ),
        FFRoute(
          name: FailPageWidget.routeName,
          path: FailPageWidget.routePath,
          builder: (context, params) => FailPageWidget(),
        ),
        FFRoute(
          name: LoginAdminWidget.routeName,
          path: LoginAdminWidget.routePath,
          builder: (context, params) => LoginAdminWidget(),
        ),
        FFRoute(
          name: ConfirmAdminWidget.routeName,
          path: ConfirmAdminWidget.routePath,
          builder: (context, params) => ConfirmAdminWidget(
            email: params.getParam(
              'email',
              ParamType.String,
            ),
            password: params.getParam(
              'password',
              ParamType.String,
            ),
            username: params.getParam(
              'username',
              ParamType.String,
            ),
            firstName: params.getParam(
              'firstName',
              ParamType.String,
            ),
            actionType: params.getParam(
              'actionType',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: StatisticsAdminWidget.routeName,
          path: StatisticsAdminWidget.routePath,
          builder: (context, params) => StatisticsAdminWidget(),
        ),
        FFRoute(
          name: UsersAdminWidget.routeName,
          path: UsersAdminWidget.routePath,
          builder: (context, params) => UsersAdminWidget(),
        ),
        FFRoute(
          name: OrganisationsAdminWidget.routeName,
          path: OrganisationsAdminWidget.routePath,
          builder: (context, params) => OrganisationsAdminWidget(),
        ),
        FFRoute(
          name: PostDetailsAdminWidget.routeName,
          path: PostDetailsAdminWidget.routePath,
          builder: (context, params) => PostDetailsAdminWidget(
            post: params.getParam<PostsRow>(
              'post',
              ParamType.SupabaseRow,
            ),
          ),
        ),
        FFRoute(
          name: OrganisationsAddAdminWidget.routeName,
          path: OrganisationsAddAdminWidget.routePath,
          builder: (context, params) => OrganisationsAddAdminWidget(),
        ),
        FFRoute(
          name: OrganisationsEditAdminWidget.routeName,
          path: OrganisationsEditAdminWidget.routePath,
          builder: (context, params) => OrganisationsEditAdminWidget(
            org: params.getParam<OrganizationRow>(
              'org',
              ParamType.SupabaseRow,
            ),
          ),
        ),
        FFRoute(
          name: UsersAddAdminWidget.routeName,
          path: UsersAddAdminWidget.routePath,
          builder: (context, params) => UsersAddAdminWidget(),
        ),
        FFRoute(
          name: UsersEditAdminWidget.routeName,
          path: UsersEditAdminWidget.routePath,
          builder: (context, params) => UsersEditAdminWidget(
            user: params.getParam<UsersRow>(
              'user',
              ParamType.SupabaseRow,
            ),
          ),
        ),
        FFRoute(
          name: PostsAdminWidget.routeName,
          path: PostsAdminWidget.routePath,
          builder: (context, params) => PostsAdminWidget(),
        ),
        FFRoute(
          name: OrganisationDetailsAdminWidget.routeName,
          path: OrganisationDetailsAdminWidget.routePath,
          builder: (context, params) => OrganisationDetailsAdminWidget(
            org: params.getParam<OrganizationRow>(
              'org',
              ParamType.SupabaseRow,
            ),
          ),
        ),
        FFRoute(
          name: UserDetailsAdminWidget.routeName,
          path: UserDetailsAdminWidget.routePath,
          builder: (context, params) => UserDetailsAdminWidget(
            user: params.getParam<UsersRow>(
              'user',
              ParamType.SupabaseRow,
            ),
          ),
        ),
        FFRoute(
          name: ReceiptsAdminWidget.routeName,
          path: ReceiptsAdminWidget.routePath,
          builder: (context, params) => ReceiptsAdminWidget(),
        ),
        FFRoute(
          name: OnboardingPageInitialWidget.routeName,
          path: OnboardingPageInitialWidget.routePath,
          builder: (context, params) => OnboardingPageInitialWidget(),
        ),
        FFRoute(
          name: OnboardingPageMainWidget.routeName,
          path: OnboardingPageMainWidget.routePath,
          builder: (context, params) => OnboardingPageMainWidget(),
        ),
        FFRoute(
          name: UserProfilePageWidget.routeName,
          path: UserProfilePageWidget.routePath,
          builder: (context, params) => UserProfilePageWidget(
            userId: params.getParam(
              'userId',
              ParamType.String,
            ),
          ),
        )
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    StructBuilder<T>? structBuilder,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
      structBuilder: structBuilder,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) {
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && !appStateNotifier.loggedIn) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            return '/onboardingPageInitial';
          }
          return null;
        },
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = appStateNotifier.loading
              ? isWeb
                  ? Container()
                  : Container(
                      color: Colors.transparent,
                      child: Image.asset(
                        'assets/images/splash.png',
                        fit: BoxFit.cover,
                      ),
                    )
              : page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  name: state.name,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey, name: state.name, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
