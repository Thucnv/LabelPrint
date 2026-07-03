import 'package:get_it/get_it.dart';

import '../../data/datasources/local/config_local_datasource.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/datasources/local/print_job_local_datasource.dart';
import '../../data/datasources/local/printer_local_datasource.dart';
import '../../data/datasources/local/template_local_datasource.dart';
import '../../data/repositories/config_repository_impl.dart';
import '../../data/repositories/print_job_repository_impl.dart';
import '../../data/repositories/printer_repository_impl.dart';
import '../../data/repositories/template_repository_impl.dart';
import '../../domain/repositories/config_repository.dart';
import '../../domain/repositories/print_job_repository.dart';
import '../../domain/repositories/printer_repository.dart';
import '../../domain/repositories/template_repository.dart';
import '../../domain/usecases/barcode/generate_barcode.dart';
import '../../domain/usecases/barcode/print_barcode.dart';
import '../../domain/usecases/config/get_config.dart';
import '../../domain/usecases/config/save_config.dart';
import '../../domain/usecases/preview/generate_preview_bitmap.dart';
import '../../domain/usecases/printer/add_printer.dart';
import '../../domain/usecases/printer/delete_printer.dart';
import '../../domain/usecases/printer/get_all_printers.dart';
import '../../domain/usecases/printer/get_default_printer.dart';
import '../../domain/usecases/printer/print_document.dart';
import '../../domain/usecases/printer/set_default_printer.dart';
import '../../domain/usecases/printer/test_connection.dart';
import '../../domain/usecases/printer/update_printer.dart';
import '../../domain/usecases/template/delete_template.dart';
import '../../domain/usecases/template/get_all_templates.dart';
import '../../domain/usecases/template/save_as_template.dart';
import '../../presentation/barcode/bloc/barcode_bloc.dart';
import '../../presentation/home/bloc/home_cubit.dart';
import '../../presentation/printer_management/bloc/printer_list_bloc.dart';
import '../../presentation/print_config/bloc/print_config_cubit.dart';
import '../../presentation/delivery_note/bloc/delivery_note_cubit.dart';

final sl = GetIt.instance;

/// Khởi tạo và cấu hình các thành phần phụ thuộc (Dependency Injection) trong hệ thống.
Future<void> init() async {
  // =========================================================================
  // 1. EXTERNAL / DATABASE
  // =========================================================================
  final dbHelper = DatabaseHelper();
  sl.registerLazySingleton<DatabaseHelper>(() => dbHelper);

  // Khởi tạo DB ngay từ đầu để tránh độ trễ khi có truy vấn đầu tiên
  await dbHelper.database;

  // =========================================================================
  // 2. DATA SOURCES
  // =========================================================================
  sl.registerLazySingleton<PrinterLocalDataSource>(
    () => PrinterLocalDataSourceImpl(databaseHelper: sl()),
  );
  sl.registerLazySingleton<ConfigLocalDataSource>(
    () => ConfigLocalDataSourceImpl(databaseHelper: sl()),
  );
  sl.registerLazySingleton<PrintJobLocalDataSource>(
    () => PrintJobLocalDataSourceImpl(databaseHelper: sl()),
  );
  sl.registerLazySingleton<TemplateLocalDataSource>(
    () => TemplateLocalDataSourceImpl(databaseHelper: sl()),
  );

  // =========================================================================
  // 3. REPOSITORIES
  // =========================================================================
  sl.registerLazySingleton<PrinterRepository>(
    () => PrinterRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<ConfigRepository>(
    () => ConfigRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<PrintJobRepository>(
    () => PrintJobRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<TemplateRepository>(
    () => TemplateRepositoryImpl(localDataSource: sl()),
  );

  // =========================================================================
  // 4. USE CASES
  // =========================================================================
  // Printer
  sl.registerLazySingleton(() => GetAllPrinters(sl()));
  sl.registerLazySingleton(() => GetDefaultPrinter(sl()));
  sl.registerLazySingleton(() => AddPrinter(sl()));
  sl.registerLazySingleton(() => UpdatePrinter(sl()));
  sl.registerLazySingleton(() => DeletePrinter(sl()));
  sl.registerLazySingleton(() => SetDefaultPrinter(sl()));
  sl.registerLazySingleton(() => TestConnection());
  sl.registerLazySingleton(() => PrintDocument(
        printerRepository: sl(),
        printJobRepository: sl(),
      ));

  // Config
  sl.registerLazySingleton(() => GetConfig(sl()));
  sl.registerLazySingleton(() => SaveConfig(sl()));

  // Template
  sl.registerLazySingleton(() => GetAllTemplates(sl()));
  sl.registerLazySingleton(() => DeleteTemplate(sl()));
  sl.registerLazySingleton(() => SaveAsTemplate(sl()));

  // Barcode / Print
  sl.registerLazySingleton(() => GenerateBarcode());
  sl.registerLazySingleton(() => PrintBarcode(
        printerRepository: sl(),
        configRepository: sl(),
        printJobRepository: sl(),
        generateBarcode: sl(),
      ));

  // Preview
  sl.registerLazySingleton(() => GeneratePreviewBitmap(
        generateBarcodeUsecase: sl(),
      ));

  // =========================================================================
  // 5. BLOCS / CUBITS
  // =========================================================================
  sl.registerFactory(() => HomeCubit(getDefaultPrinter: sl()));
  sl.registerFactory(() => PrinterListBloc(
        getAllPrinters: sl(),
        addPrinterUsecase: sl(),
        updatePrinterUsecase: sl(),
        deletePrinterUsecase: sl(),
        setDefaultPrinterUsecase: sl(),
        testConnectionUsecase: sl(),
      ));
  sl.registerFactory(() => BarcodeBloc(printBarcodeUsecase: sl()));
  sl.registerFactory(() => PrintConfigCubit(
        getConfigUsecase: sl(),
        saveConfigUsecase: sl(),
        saveAsTemplateUsecase: sl(),
        getDefaultPrinterUsecase: sl(),
        getAllTemplatesUsecase: sl(),
      ));
  sl.registerFactory(() => DeliveryNoteCubit());
}
