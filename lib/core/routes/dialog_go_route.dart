import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DialogGoRoute extends GoRoute {
  DialogGoRoute({
    required super.path,
    super.redirect,
    List<GoRoute> super.routes = const [],
    Widget? child,
    Widget Function(BuildContext, GoRouterState)? builder,
  }) : assert(child != null || builder != null),
       super(
         pageBuilder: (context, state) {
           return CustomTransitionPage(
             child: Center(
               child: SizedBox(child: Center(child: child)),
             ),
             transitionsBuilder:
                 (
                   BuildContext context,
                   Animation<double> animation,
                   Animation<double> secondaryAnimation,
                   Widget child,
                 ) {
                   return FadeTransition(
                     opacity: animation,
                     child: builder?.call(context, state) ?? child,
                   );
                 },
           );
         },
       );
}
