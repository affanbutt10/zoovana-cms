import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../network/api_client.dart';
import '../network/dio_factory.dart';
import '../services/connectivity_service.dart';
import '../storage/local_storage_service.dart';
import '../storage/secure_storage_service.dart';

// Auth data layer
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

// Auth domain use cases
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/verify_email_usecase.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/refresh_token_usecase.dart';

// Shop data layer
import '../../features/shop/data/datasources/shop_remote_datasource.dart';
import '../../features/shop/data/repositories/shop_repository_impl.dart';
import '../../features/shop/domain/repositories/shop_repository.dart';
import '../../features/shop/domain/usecases/shop_init_usecase.dart';

// Dashboard data layer
import '../../features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_overview.dart';

// Supplier data layer
import '../../features/suppliers/data/datasources/supplier_remote_datasource.dart';
import '../../features/suppliers/data/repositories/supplier_repository_impl.dart';
import '../../features/suppliers/domain/repositories/supplier_repository.dart';
import '../../features/suppliers/domain/usecases/get_suppliers.dart';
import '../../features/suppliers/domain/usecases/create_supplier.dart';

// Category data layer
import '../../features/categories/data/datasources/category_remote_datasource.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/categories/domain/usecases/get_categories.dart';
import '../../features/categories/domain/usecases/create_category.dart';

// Chat data layer
import '../../features/chat/data/datasources/chat_remote_datasource.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/usecases/get_chat_messages.dart';
import '../../features/chat/domain/usecases/get_chat_threads.dart';
import '../../features/chat/domain/usecases/mark_chat_thread_read.dart';
import '../../features/chat/domain/usecases/send_chat_message.dart';

// Pet owner data layer
import '../../features/pet_owner/data/datasources/pet_owner_remote_datasource.dart';
import '../../features/pet_owner/data/repositories/pet_owner_repository_impl.dart';
import '../../features/pet_owner/domain/repositories/pet_owner_repository.dart';
import '../../features/pet_owner/domain/usecases/create_pet.dart';
import '../../features/pet_owner/domain/usecases/get_my_pets.dart';
import '../../features/pet_owner/domain/usecases/get_pet_bookings.dart';
import '../../features/pet_owner/domain/usecases/get_pet_owner_overview.dart';
import '../../features/pet_owner/domain/usecases/request_pet_booking.dart';
import '../../features/pet_owner/domain/usecases/search_pet_services.dart';

// Provider data layer
import '../../features/provider/data/datasources/provider_remote_datasource.dart';
import '../../features/provider/data/repositories/provider_repository_impl.dart';
import '../../features/provider/domain/repositories/provider_repository.dart';
import '../../features/provider/domain/usecases/apply_provider_profile.dart';
import '../../features/provider/domain/usecases/create_provider_service.dart';
import '../../features/provider/domain/usecases/get_provider_bookings.dart';
import '../../features/provider/domain/usecases/get_provider_overview.dart';
import '../../features/provider/domain/usecases/get_provider_services.dart';
import '../../features/provider/domain/usecases/update_provider_booking_status.dart';

// Volunteer data layer
import '../../features/volunteer/data/datasources/volunteer_remote_datasource.dart';
import '../../features/volunteer/data/repositories/volunteer_repository_impl.dart';
import '../../features/volunteer/domain/repositories/volunteer_repository.dart';
import '../../features/volunteer/domain/usecases/apply_volunteer.dart';
import '../../features/volunteer/domain/usecases/get_volunteer_applications.dart';
import '../../features/volunteer/domain/usecases/get_volunteer_shelters.dart';
import '../../features/volunteer/domain/usecases/get_volunteer_shifts.dart';
import '../../features/volunteer/domain/usecases/sign_in_volunteer_shift.dart';
import '../../features/volunteer/domain/usecases/sign_out_volunteer_shift.dart';

// Shelter data layer
import '../../features/shelter/data/datasources/shelter_remote_datasource.dart';
import '../../features/shelter/data/repositories/shelter_repository_impl.dart';
import '../../features/shelter/domain/repositories/shelter_repository.dart';
import '../../features/shelter/domain/usecases/create_shelter_adoption.dart';
import '../../features/shelter/domain/usecases/create_shelter_animal.dart';
import '../../features/shelter/domain/usecases/create_shelter_kennel.dart';
import '../../features/shelter/domain/usecases/create_shelter_medical_record.dart';
import '../../features/shelter/domain/usecases/create_shelter_profile.dart';
import '../../features/shelter/domain/usecases/create_shelter_vaccination.dart';
import '../../features/shelter/domain/usecases/get_shelter_animal_care_tasks.dart';
import '../../features/shelter/domain/usecases/get_shelter_adoptions.dart';
import '../../features/shelter/domain/usecases/get_shelter_animals.dart';
import '../../features/shelter/domain/usecases/get_shelter_donations.dart';
import '../../features/shelter/domain/usecases/get_shelter_kennels.dart';
import '../../features/shelter/domain/usecases/get_shelter_lost_found_reports.dart';
import '../../features/shelter/domain/usecases/get_shelter_medical_records.dart';
import '../../features/shelter/domain/usecases/get_shelter_operations.dart';
import '../../features/shelter/domain/usecases/get_shelter_overview.dart';
import '../../features/shelter/domain/usecases/get_shelter_profiles.dart';
import '../../features/shelter/domain/usecases/get_shelter_vaccinations.dart';
import '../../features/shelter/domain/usecases/get_shelter_volunteers.dart';
import '../../features/shelter/domain/usecases/update_shelter_adoption_status.dart';
import '../../features/shelter/domain/usecases/update_shelter_animal_care_status.dart';
import '../../features/shelter/domain/usecases/update_shelter_donation_status.dart';
import '../../features/shelter/domain/usecases/update_shelter_lost_found_status.dart';
import '../../features/shelter/domain/usecases/update_shelter_volunteer_status.dart';

// Product management data layer
import '../../features/products_management/data/datasources/product_remote_datasource.dart';
import '../../features/products_management/data/repositories/product_repository_impl.dart';
import '../../features/products_management/domain/repositories/product_repository.dart';
import '../../features/products_management/domain/usecases/get_products.dart';
import '../../features/products_management/domain/usecases/create_product.dart';

// Auth presentation controllers
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/controllers/role_controller.dart';

// Shop presentation controller
import '../../features/shop/presentation/controllers/shop_init_controller.dart';

// Dashboard presentation controller
import '../../features/dashboard/presentation/controllers/dashboard_controller.dart';

// Supplier presentation controller
import '../../features/suppliers/presentation/controllers/supplier_controller.dart';

// Category presentation controller
import '../../features/categories/presentation/controllers/category_controller.dart';

// Chat presentation controller
import '../../features/chat/presentation/controllers/chat_controller.dart';

// Pet owner presentation controller
import '../../features/pet_owner/presentation/controllers/pet_owner_controller.dart';

// Provider presentation controller
import '../../features/provider/presentation/controllers/provider_controller.dart';

// Volunteer presentation controller
import '../../features/volunteer/presentation/controllers/volunteer_controller.dart';

// Shelter presentation controller
import '../../features/shelter/presentation/controllers/shelter_controller.dart';

// Product management presentation controller
import '../../features/products_management/presentation/controllers/product_management_controller.dart';

/// Global [GetIt] service locator instance.
final getIt = GetIt.instance;

/// Demo mode — set to [true] only for client presentations where you want
/// to skip authentication and navigate freely. Always [false] in production.
const bool demoMode = false;

/// Registers all app-wide services before the first screen renders.
class DependencyInjection {
  DependencyInjection._();

  static Future<void> init() async {
    // ── 1. Storage services ──────────────────────────────────────────────────
    getIt.registerSingleton<SecureStorageService>(SecureStorageServiceImpl());
    getIt.registerSingleton<LocalStorageService>(LocalStorageServiceImpl());
    Get.put<SecureStorageService>(
      getIt<SecureStorageService>(),
      permanent: true,
    );
    Get.put<LocalStorageService>(getIt<LocalStorageService>(), permanent: true);
    debugPrint('DI STEP 1: Storage registered');

    // ── 2. ApiClient — must be ready before any datasource is created ────────
    final apiClient = await ApiClient().init();
    getIt.registerSingleton<ApiClient>(apiClient);
    Get.put<ApiClient>(apiClient, permanent: true);
    debugPrint('DI STEP 2: ApiClient initialized');

    // ── 3. ConnectivityService ───────────────────────────────────────────────
    final connectivityService = await ConnectivityService().init();
    getIt.registerSingleton<ConnectivityService>(connectivityService);
    Get.put<ConnectivityService>(connectivityService, permanent: true);
    debugPrint('DI STEP 3: ConnectivityService initialized');

    // ── 4. Dio instances (auth + shop) ───────────────────────────────────────
    // The onForceSignOut callback is a closure — Get.find<AuthController>() is
    // only called when a 401 is actually received, not during construction, so
    // it is safe to reference AuthController here before it is registered.
    getIt.registerSingleton<Dio>(
      DioFactory.createAuthDio(
        secureStorage: getIt<SecureStorageService>(),
        localStorage: getIt<LocalStorageService>(),
        onForceSignOut: () => Get.find<AuthController>().forceSignOut(),
      ),
      instanceName: 'authDio',
    );

    getIt.registerSingleton<Dio>(
      DioFactory.createShopDio(
        secureStorage: getIt<SecureStorageService>(),
        localStorage: getIt<LocalStorageService>(),
        onForceSignOut: () => Get.find<AuthController>().forceSignOut(),
      ),
      instanceName: 'shopDio',
    );

    getIt.registerSingleton<Dio>(
      DioFactory.createCmsDio(
        secureStorage: getIt<SecureStorageService>(),
        localStorage: getIt<LocalStorageService>(),
        onForceSignOut: () => Get.find<AuthController>().forceSignOut(),
      ),
      instanceName: 'cmsDio',
    );

    getIt.registerSingleton<Dio>(
      DioFactory.createShelterDio(
        secureStorage: getIt<SecureStorageService>(),
        localStorage: getIt<LocalStorageService>(),
        onForceSignOut: () => Get.find<AuthController>().forceSignOut(),
      ),
      instanceName: 'shelterDio',
    );

    getIt.registerSingleton<Dio>(
      DioFactory.createPetCareDio(
        secureStorage: getIt<SecureStorageService>(),
        localStorage: getIt<LocalStorageService>(),
        onForceSignOut: () => Get.find<AuthController>().forceSignOut(),
      ),
      instanceName: 'petCareDio',
    );
    debugPrint('DI STEP 4: Dio registered');

    // ── 5. Remote data sources ───────────────────────────────────────────────
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt<Dio>(instanceName: 'authDio')),
    );

    getIt.registerLazySingleton<ShopRemoteDataSource>(
      () => ShopRemoteDataSourceImpl(getIt<Dio>(instanceName: 'shopDio')),
    );

    getIt.registerLazySingleton<DashboardRemoteDatasource>(
      () => DashboardRemoteDatasourceImpl(
        shopDio: getIt<Dio>(instanceName: 'shopDio'),
      ),
    );

    getIt.registerLazySingleton<SupplierRemoteDataSource>(
      () => SupplierRemoteDataSourceImpl(
        shopDio: getIt<Dio>(instanceName: 'cmsDio'),
      ),
    );

    getIt.registerLazySingleton<CategoryRemoteDataSource>(
      () => CategoryRemoteDataSourceImpl(
        shopDio: getIt<Dio>(instanceName: 'cmsDio'),
      ),
    );

    getIt.registerLazySingleton<ProductRemoteDataSource>(
      () => ProductRemoteDataSourceImpl(
        shopDio: getIt<Dio>(instanceName: 'cmsDio'),
      ),
    );

    getIt.registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(
        cmsDio: getIt<Dio>(instanceName: 'petCareDio'),
      ),
    );

    getIt.registerLazySingleton<PetOwnerRemoteDataSource>(
      () => PetOwnerRemoteDataSourceImpl(
        cmsDio: getIt<Dio>(instanceName: 'petCareDio'),
      ),
    );

    getIt.registerLazySingleton<ProviderRemoteDataSource>(
      () => ProviderRemoteDataSourceImpl(
        cmsDio: getIt<Dio>(instanceName: 'petCareDio'),
      ),
    );

    getIt.registerLazySingleton<VolunteerRemoteDataSource>(
      () => VolunteerRemoteDataSourceImpl(
        cmsDio: getIt<Dio>(instanceName: 'shelterDio'),
      ),
    );

    getIt.registerLazySingleton<ShelterRemoteDataSource>(
      () => ShelterRemoteDataSourceImpl(
        cmsDio: getIt<Dio>(instanceName: 'shelterDio'),
      ),
    );
    debugPrint('DI STEP 5: Data sources registered');

    // ── 6. Repositories ──────────────────────────────────────────────────────
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: getIt<AuthRemoteDataSource>(),
        secureStorage: getIt<SecureStorageService>(),
        localStorage: getIt<LocalStorageService>(),
      ),
    );

    getIt.registerLazySingleton<ShopRepository>(
      () => ShopRepositoryImpl(
        remoteDataSource: getIt<ShopRemoteDataSource>(),
        localStorage: getIt<LocalStorageService>(),
      ),
    );

    getIt.registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(
        remoteDatasource: getIt<DashboardRemoteDatasource>(),
      ),
    );

    getIt.registerLazySingleton<SupplierRepository>(
      () => SupplierRepositoryImpl(
        remoteDataSource: getIt<SupplierRemoteDataSource>(),
      ),
    );

    getIt.registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(
        remoteDataSource: getIt<CategoryRemoteDataSource>(),
      ),
    );

    getIt.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(
        remoteDataSource: getIt<ProductRemoteDataSource>(),
      ),
    );

    getIt.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(remoteDataSource: getIt<ChatRemoteDataSource>()),
    );

    getIt.registerLazySingleton<PetOwnerRepository>(
      () => PetOwnerRepositoryImpl(
        remoteDataSource: getIt<PetOwnerRemoteDataSource>(),
      ),
    );

    getIt.registerLazySingleton<ProviderRepository>(
      () => ProviderRepositoryImpl(
        remoteDataSource: getIt<ProviderRemoteDataSource>(),
      ),
    );

    getIt.registerLazySingleton<VolunteerRepository>(
      () => VolunteerRepositoryImpl(
        remoteDataSource: getIt<VolunteerRemoteDataSource>(),
      ),
    );

    getIt.registerLazySingleton<ShelterRepository>(
      () => ShelterRepositoryImpl(
        remoteDataSource: getIt<ShelterRemoteDataSource>(),
      ),
    );
    debugPrint('DI STEP 6: Repositories registered');

    // ── 7. Use cases ─────────────────────────────────────────────────────────
    getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
    getIt.registerLazySingleton(() => RegisterUseCase(getIt<AuthRepository>()));
    getIt.registerLazySingleton(
      () => VerifyEmailUseCase(getIt<AuthRepository>()),
    );
    getIt.registerLazySingleton(
      () => ForgotPasswordUseCase(getIt<AuthRepository>()),
    );
    getIt.registerLazySingleton(
      () => ResetPasswordUseCase(getIt<AuthRepository>()),
    );
    getIt.registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()));
    getIt.registerLazySingleton(
      () => RefreshTokenUseCase(getIt<AuthRepository>()),
    );
    getIt.registerLazySingleton(() => ShopInitUseCase(getIt<ShopRepository>()));
    getIt.registerLazySingleton(
      () => GetDashboardOverview(repository: getIt<DashboardRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetSuppliers(repository: getIt<SupplierRepository>()),
    );
    getIt.registerLazySingleton(
      () => CreateSupplier(repository: getIt<SupplierRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetCategories(repository: getIt<CategoryRepository>()),
    );
    getIt.registerLazySingleton(
      () => CreateCategory(repository: getIt<CategoryRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetProducts(repository: getIt<ProductRepository>()),
    );
    getIt.registerLazySingleton(
      () => CreateProduct(repository: getIt<ProductRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetChatThreads(repository: getIt<ChatRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetChatMessages(repository: getIt<ChatRepository>()),
    );
    getIt.registerLazySingleton(
      () => SendChatMessage(repository: getIt<ChatRepository>()),
    );
    getIt.registerLazySingleton(
      () => MarkChatThreadRead(repository: getIt<ChatRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetPetOwnerOverview(repository: getIt<PetOwnerRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetMyPets(repository: getIt<PetOwnerRepository>()),
    );
    getIt.registerLazySingleton(
      () => CreatePet(repository: getIt<PetOwnerRepository>()),
    );
    getIt.registerLazySingleton(
      () => SearchPetServices(repository: getIt<PetOwnerRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetPetBookings(repository: getIt<PetOwnerRepository>()),
    );
    getIt.registerLazySingleton(
      () => RequestPetBooking(repository: getIt<PetOwnerRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetProviderOverview(repository: getIt<ProviderRepository>()),
    );
    getIt.registerLazySingleton(
      () => ApplyProviderProfile(repository: getIt<ProviderRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetProviderServices(repository: getIt<ProviderRepository>()),
    );
    getIt.registerLazySingleton(
      () => CreateProviderService(repository: getIt<ProviderRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetProviderBookings(repository: getIt<ProviderRepository>()),
    );
    getIt.registerLazySingleton(
      () =>
          UpdateProviderBookingStatus(repository: getIt<ProviderRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetVolunteerShifts(repository: getIt<VolunteerRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetVolunteerApplications(repository: getIt<VolunteerRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetVolunteerShelters(repository: getIt<VolunteerRepository>()),
    );
    getIt.registerLazySingleton(
      () => ApplyVolunteer(repository: getIt<VolunteerRepository>()),
    );
    getIt.registerLazySingleton(
      () => SignInVolunteerShift(repository: getIt<VolunteerRepository>()),
    );
    getIt.registerLazySingleton(
      () => SignOutVolunteerShift(repository: getIt<VolunteerRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetShelterOverview(repository: getIt<ShelterRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetShelterOperations(repository: getIt<ShelterRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetShelterProfiles(repository: getIt<ShelterRepository>()),
    );
    getIt.registerLazySingleton(
      () => CreateShelterProfile(repository: getIt<ShelterRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetShelterAnimals(repository: getIt<ShelterRepository>()),
    );
    getIt.registerLazySingleton(
      () => CreateShelterAnimal(repository: getIt<ShelterRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetShelterMedicalRecords(repository: getIt<ShelterRepository>()),
    );
    getIt.registerLazySingleton(
      () => CreateShelterMedicalRecord(repository: getIt<ShelterRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetShelterVaccinations(repository: getIt<ShelterRepository>()),
    );
    getIt.registerLazySingleton(
      () => CreateShelterVaccination(repository: getIt<ShelterRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetShelterKennels(repository: getIt<ShelterRepository>()),
    );
    getIt.registerLazySingleton(
      () => CreateShelterKennel(repository: getIt<ShelterRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetShelterAdoptions(repository: getIt<ShelterRepository>()),
    );
    getIt.registerLazySingleton(
      () => CreateShelterAdoption(repository: getIt<ShelterRepository>()),
    );
    getIt.registerLazySingleton(
      () => UpdateShelterAdoptionStatus(repository: getIt<ShelterRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetShelterVolunteers(repository: getIt<ShelterRepository>()),
    );
    getIt.registerLazySingleton(
      () =>
          UpdateShelterVolunteerStatus(repository: getIt<ShelterRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetShelterDonations(repository: getIt<ShelterRepository>()),
    );
    getIt.registerLazySingleton(
      () => UpdateShelterDonationStatus(repository: getIt<ShelterRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetShelterLostFoundReports(repository: getIt<ShelterRepository>()),
    );
    getIt.registerLazySingleton(
      () =>
          UpdateShelterLostFoundStatus(repository: getIt<ShelterRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetShelterAnimalCareTasks(repository: getIt<ShelterRepository>()),
    );
    getIt.registerLazySingleton(
      () =>
          UpdateShelterAnimalCareStatus(repository: getIt<ShelterRepository>()),
    );
    debugPrint('DI STEP 7: Use cases registered');

    // ── 8. GetX controllers ──────────────────────────────────────────────────
    // AuthController must be registered first — Dio callbacks reference it.
    final authController = AuthController(
      loginUseCase: getIt<LoginUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      secureStorage: getIt<SecureStorageService>(),
    );
    Get.put<AuthController>(authController, permanent: true);

    Get.put<RoleController>(
      RoleController(localStorage: getIt<LocalStorageService>()),
      permanent: true,
    );

    Get.put<ShopInitController>(
      ShopInitController(
        shopInitUseCase: getIt<ShopInitUseCase>(),
        localStorage: getIt<LocalStorageService>(),
      ),
      permanent: true,
    );

    Get.put<DashboardController>(
      DashboardController(getDashboardOverview: getIt<GetDashboardOverview>()),
      permanent: true,
    );

    Get.put<SupplierController>(
      SupplierController(
        getSuppliers: getIt<GetSuppliers>(),
        createSupplier: getIt<CreateSupplier>(),
      ),
      permanent: true,
    );

    Get.put<CategoryController>(
      CategoryController(
        getCategories: getIt<GetCategories>(),
        createCategory: getIt<CreateCategory>(),
      ),
      permanent: true,
    );

    Get.put<ProductManagementController>(
      ProductManagementController(
        getProducts: getIt<GetProducts>(),
        createProduct: getIt<CreateProduct>(),
      ),
      permanent: true,
    );

    Get.put<ChatController>(
      ChatController(
        getChatThreads: getIt<GetChatThreads>(),
        getChatMessages: getIt<GetChatMessages>(),
        sendChatMessage: getIt<SendChatMessage>(),
        markChatThreadRead: getIt<MarkChatThreadRead>(),
      ),
      permanent: true,
    );

    Get.put<PetOwnerController>(
      PetOwnerController(
        getOverview: getIt<GetPetOwnerOverview>(),
        getMyPets: getIt<GetMyPets>(),
        createPet: getIt<CreatePet>(),
        searchServices: getIt<SearchPetServices>(),
        getBookings: getIt<GetPetBookings>(),
        requestBooking: getIt<RequestPetBooking>(),
      ),
      permanent: true,
    );

    Get.put<ProviderController>(
      ProviderController(
        getOverview: getIt<GetProviderOverview>(),
        applyProfile: getIt<ApplyProviderProfile>(),
        getServices: getIt<GetProviderServices>(),
        createService: getIt<CreateProviderService>(),
        getBookings: getIt<GetProviderBookings>(),
        updateBookingStatus: getIt<UpdateProviderBookingStatus>(),
      ),
      permanent: true,
    );

    Get.put<VolunteerController>(
      VolunteerController(
        getShifts: getIt<GetVolunteerShifts>(),
        getApplications: getIt<GetVolunteerApplications>(),
        getShelters: getIt<GetVolunteerShelters>(),
        applyVolunteer: getIt<ApplyVolunteer>(),
        signInShift: getIt<SignInVolunteerShift>(),
        signOutShift: getIt<SignOutVolunteerShift>(),
      ),
      permanent: true,
    );

    Get.put<ShelterController>(
      ShelterController(
        getOverview: getIt<GetShelterOverview>(),
        getOperations: getIt<GetShelterOperations>(),
        getShelters: getIt<GetShelterProfiles>(),
        createShelter: getIt<CreateShelterProfile>(),
        getAnimals: getIt<GetShelterAnimals>(),
        createAnimal: getIt<CreateShelterAnimal>(),
        getMedicalRecords: getIt<GetShelterMedicalRecords>(),
        createMedicalRecord: getIt<CreateShelterMedicalRecord>(),
        getVaccinations: getIt<GetShelterVaccinations>(),
        createVaccination: getIt<CreateShelterVaccination>(),
        getKennels: getIt<GetShelterKennels>(),
        createKennel: getIt<CreateShelterKennel>(),
        getAdoptions: getIt<GetShelterAdoptions>(),
        createAdoption: getIt<CreateShelterAdoption>(),
        updateAdoptionStatus: getIt<UpdateShelterAdoptionStatus>(),
        getVolunteers: getIt<GetShelterVolunteers>(),
        updateVolunteerStatus: getIt<UpdateShelterVolunteerStatus>(),
        getDonations: getIt<GetShelterDonations>(),
        updateDonationStatus: getIt<UpdateShelterDonationStatus>(),
        getLostFoundReports: getIt<GetShelterLostFoundReports>(),
        updateLostFoundStatus: getIt<UpdateShelterLostFoundStatus>(),
        getAnimalCareTasks: getIt<GetShelterAnimalCareTasks>(),
        updateAnimalCareStatus: getIt<UpdateShelterAnimalCareStatus>(),
      ),
      permanent: true,
    );
    debugPrint('DI STEP 8: Controllers registered');

    // ── 9. Background startup tasks ──────────────────────────────────────────
    // These run in the background while the splash screen is shown.
    // Errors are caught so they cannot silently kill startup.
    authController.restoreSessionOnInit().catchError((e, st) {
      debugPrint('restoreSessionOnInit failed: $e');
      debugPrint('$st');
    });

    Get.find<RoleController>().fetchAllRoles().catchError((e, st) {
      debugPrint('fetchAllRoles failed: $e');
      debugPrint('$st');
    });
    debugPrint('DI STEP 9: Background startup tasks started');
  }
}
