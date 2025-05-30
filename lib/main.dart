import 'package:digi4_mobile/blocs/asset/assets_bloc.dart';
import 'package:digi4_mobile/blocs/auth/auth_bloc.dart';
import 'package:digi4_mobile/blocs/dashboard/dashboard_bloc.dart';
import 'package:digi4_mobile/blocs/locator/locator_bloc.dart';
import 'package:digi4_mobile/blocs/repair_request/repair_request_bloc.dart';
import 'package:digi4_mobile/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => DashboardBloc()),
        BlocProvider(create: (context) => AssetsBloc()),
        BlocProvider(create: (context) => RepairRequestBloc()),
        BlocProvider(create: (context) => LocatorBloc()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.login,
        routes: AppRoutes.routes,
      ),
    );
  }
}
