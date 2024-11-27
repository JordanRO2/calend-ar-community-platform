// frontend/lib/dependency_injection.dart

import 'package:flutter/material.dart';

// Core dependencies
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/infrastructure/services/socket_service.dart';
import 'package:frontend/presentation/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Network and Data Sources
import 'package:frontend/infrastructure/network/api_client.dart';
import 'package:frontend/infrastructure/datasources/datasources.dart';

// Repository Implementations
import 'package:frontend/infrastructure/implementation/implementation.dart';

// Use Cases
import 'package:frontend/infrastructure/use_cases/use_cases.dart';

// Providers
import 'package:frontend/presentation/providers/providers.dart';

// Third-party packages
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class DependencyInjection {
  // Core services
  static late final SharedPreferences _prefs;
  static late final FlutterSecureStorage _secureStorage;
  static late final ApiClient _apiClient;
  static late final SocketService _socketService;
  static late final List<SingleChildWidget> providers;

  /// Inicializa todas las dependencias necesarias para la aplicación
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Inicializar servicios core
    await _initializeCore();

    // Inicializar capas de datos
    final datasources = _initializeDatasources();
    final repositories = _initializeRepositories(datasources);
    final useCases = _initializeUseCases(repositories);

    // Configurar providers
    providers =
        _configureProviders(repositories: repositories, useCases: useCases);
  }

  /// Inicializa los servicios core
  static Future<void> _initializeCore() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _secureStorage = const FlutterSecureStorage();
      _apiClient = ApiClient();

      // Inicializar el servicio de WebSocket como singleton
      _socketService = SocketService.instance;
      _socketService.initializeSocket();
    } catch (e) {
      throw Exception("Error al inicializar los servicios core: $e");
    }
  }

  /// Libera recursos y desconecta servicios
  static void dispose() {
    try {
      _socketService.disconnect();
      _apiClient
          .dispose(); // Asegúrate de que ApiClient tenga un método dispose
    } catch (e) {
      debugPrint("Error al liberar servicios: $e");
    }
  }

  /// Inicializa todas las fuentes de datos
  static _DataSourceContainer _initializeDatasources() {
    return _DataSourceContainer(
      userRemoteDataSource: UserRemoteDataSource(_apiClient),
      calendarRemoteDataSource: CalendarRemoteDataSource(_apiClient),
      commentRemoteDataSource: CommentRemoteDataSource(_apiClient),
      communityRemoteDataSource: CommunityRemoteDataSource(_apiClient),
      eventRemoteDataSource: EventRemoteDataSource(_apiClient),
      notificationRemoteDataSource: NotificationRemoteDataSource(_apiClient),
      ratingRemoteDataSource: RatingRemoteDataSource(_apiClient),
      replyRemoteDataSource: ReplyRemoteDataSource(_apiClient),
    );
  }

  /// Inicializa todos los repositorios
  static _RepositoryContainer _initializeRepositories(
      _DataSourceContainer datasources) {
    return _RepositoryContainer(
      userRepository: UserRepositoryImpl(datasources.userRemoteDataSource),
      calendarRepository:
          CalendarRepositoryImpl(datasources.calendarRemoteDataSource),
      commentRepository:
          CommentRepositoryImpl(datasources.commentRemoteDataSource),
      communityRepository:
          CommunityRepositoryImpl(datasources.communityRemoteDataSource),
      eventRepository: EventRepositoryImpl(datasources.eventRemoteDataSource),
      notificationRepository:
          NotificationRepositoryImpl(datasources.notificationRemoteDataSource),
      ratingRepository:
          RatingRepositoryImpl(datasources.ratingRemoteDataSource),
      replyRepository: ReplyRepositoryImpl(datasources.replyRemoteDataSource),
    );
  }

  /// Inicializa todos los casos de uso
  static _UseCaseContainer _initializeUseCases(
      _RepositoryContainer repositories) {
    return _UseCaseContainer(
      // User use cases
      registerUserUseCase: RegisterUserUseCase(repositories.userRepository),
      loginUserUseCase: LoginUserUseCase(repositories.userRepository),
      getUserProfileUseCase: GetUserProfileUseCase(repositories.userRepository),
      updateUserProfileUseCase:
          UpdateUserProfileUseCase(repositories.userRepository),
      resetPasswordUseCase: ResetPasswordUseCase(repositories.userRepository),
      updatePasswordUseCase: UpdatePasswordUseCase(repositories.userRepository),
      disableUserUseCase: DisableUserUseCase(repositories.userRepository),
      validateTokenUseCase: ValidateTokenUseCase(repositories.userRepository),

      // Calendar use cases
      createCalendarUseCase:
          CreateCalendarUseCase(repositories.calendarRepository),
      updateCalendarUseCase:
          UpdateCalendarUseCase(repositories.calendarRepository),
      deleteCalendarUseCase:
          DeleteCalendarUseCase(repositories.calendarRepository),
      getCalendarByIdUseCase:
          GetCalendarByIdUseCase(repositories.calendarRepository),
      getAllCalendarsUseCase:
          GetAllCalendarsUseCase(repositories.calendarRepository),
      addEventToCalendarUseCase:
          AddEventToCalendarUseCase(repositories.calendarRepository),
      removeEventFromCalendarUseCase:
          RemoveEventFromCalendarUseCase(repositories.calendarRepository),
      listPublicCalendarsUseCase:
          ListPublicCalendarsUseCase(repositories.calendarRepository),
      shareCalendarUseCase:
          ShareCalendarUseCase(repositories.calendarRepository),
      getCalendarSubscribersUseCase:
          GetCalendarSubscribersUseCase(repositories.calendarRepository),
      setEventReminderUseCase:
          SetEventReminderUseCase(repositories.calendarRepository),

      // Comment use cases
      createCommentUseCase:
          CreateCommentUseCase(repositories.commentRepository),
      deleteCommentUseCase:
          DeleteCommentUseCase(repositories.commentRepository),
      getCommentDetailsUseCase:
          GetCommentDetailsUseCase(repositories.commentRepository),
      getCommentLikesUseCase:
          GetCommentLikesUseCase(repositories.commentRepository),
      getCommentsByEventUseCase:
          GetCommentsByEventUseCase(repositories.commentRepository),
      updateCommentUseCase:
          UpdateCommentUseCase(repositories.commentRepository),
      likeCommentUseCase: LikeCommentUseCase(repositories.commentRepository),
      reportCommentUseCase:
          ReportCommentUseCase(repositories.commentRepository),

      // Community use cases
      createCommunityUseCase:
          CreateCommunityUseCase(repositories.communityRepository),
      updateCommunityUseCase:
          UpdateCommunityUseCase(repositories.communityRepository),
      deleteCommunityUseCase:
          DeleteCommunityUseCase(repositories.communityRepository),
      getCommunityDetailsUseCase:
          GetCommunityDetailsUseCase(repositories.communityRepository),
      getAllCommunitiesUseCase:
          GetAllCommunitiesUseCase(repositories.communityRepository),
      addModeratorUseCase:
          AddModeratorUseCase(repositories.communityRepository),
      removeModeratorUseCase:
          RemoveModeratorUseCase(repositories.communityRepository),
      getFeaturedCommunitiesUseCase:
          GetFeaturedCommunitiesUseCase(repositories.communityRepository),
      filterCommunitiesUseCase:
          FilterCommunitiesUseCase(repositories.communityRepository),
      getCommunityTypesUseCase:
          GetCommunityTypesUseCase(repositories.communityRepository),
      getCommunityCategoriesUseCase:
          GetCommunityCategoriesUseCase(repositories.communityRepository),
      getCommunityLocationsUseCase:
          GetCommunityLocationsUseCase(repositories.communityRepository),

      // Event use cases
      createEventUseCase: CreateEventUseCase(repositories.eventRepository),
      updateEventUseCase: UpdateEventUseCase(repositories.eventRepository),
      deleteEventUseCase: DeleteEventUseCase(repositories.eventRepository),
      getEventDetailsUseCase:
          GetEventDetailsUseCase(repositories.eventRepository),
      addAttendeeUseCase: AddAttendeeUseCase(repositories.eventRepository),
      removeAttendeeUseCase:
          RemoveAttendeeUseCase(repositories.eventRepository),
      getFeaturedEventsUseCase:
          GetFeaturedEventsUseCase(repositories.eventRepository),
      filterEventsUseCase: FilterEventsUseCase(repositories.eventRepository),
      manageRecurrenceUseCase:
          ManageRecurrenceUseCase(repositories.eventRepository),
      cancelEventUseCase: CancelEventUseCase(repositories.eventRepository),
      getEventCategoriesUseCase:
          GetEventCategoriesUseCase(repositories.eventRepository),
      getEventTypesUseCase: GetEventTypesUseCase(repositories.eventRepository),
      getEventLocationsUseCase:
          GetEventLocationsUseCase(repositories.eventRepository),

      // Notification use cases
      createNotificationUseCase:
          CreateNotificationUseCase(repositories.notificationRepository),
      markNotificationAsReadUseCase:
          MarkNotificationAsReadUseCase(repositories.notificationRepository),
      getNotificationByIdUseCase:
          GetNotificationByIdUseCase(repositories.notificationRepository),
      getNotificationsByUserUseCase:
          GetNotificationsByUserUseCase(repositories.notificationRepository),
      deleteNotificationUseCase:
          DeleteNotificationUseCase(repositories.notificationRepository),

      // Rating use cases
      createRatingUseCase: CreateRatingUseCase(repositories.ratingRepository),
      updateRatingUseCase: UpdateRatingUseCase(repositories.ratingRepository),
      deleteRatingUseCase: DeleteRatingUseCase(repositories.ratingRepository),
      getRatingByIdUseCase: GetRatingByIdUseCase(repositories.ratingRepository),
      getRatingsByEventUseCase:
          GetRatingsByEventUseCase(repositories.ratingRepository),
      calculateAverageRatingUseCase:
          CalculateAverageRatingUseCase(repositories.ratingRepository),

      // Reply use cases
      createReplyUseCase: CreateReplyUseCase(repositories.replyRepository),
      getReplyByIdUseCase: GetReplyByIdUseCase(repositories.replyRepository),
      updateReplyUseCase: UpdateReplyUseCase(repositories.replyRepository),
      deleteReplyUseCase: DeleteReplyUseCase(repositories.replyRepository),
      getRepliesByCommentUseCase:
          GetRepliesByCommentUseCase(repositories.replyRepository),
      likeReplyUseCase: LikeReplyUseCase(repositories.replyRepository),
      getReplyLikesUseCase: GetReplyLikesUseCase(repositories.replyRepository),
    );
  }

  /// Configura los providers para la aplicación
  static List<SingleChildWidget> _configureProviders({
    required _RepositoryContainer repositories,
    required _UseCaseContainer useCases,
  }) {
    return [
      // Core providers
      Provider.value(value: _apiClient),
      Provider.value(value: _prefs),
      Provider.value(value: _secureStorage),
      Provider.value(value: _socketService),

      // Repository providers
      Provider.value(value: repositories.userRepository),
      Provider.value(value: repositories.calendarRepository),
      Provider.value(value: repositories.commentRepository),
      Provider.value(value: repositories.communityRepository),
      Provider.value(value: repositories.eventRepository),
      Provider.value(value: repositories.notificationRepository),
      Provider.value(value: repositories.ratingRepository),
      Provider.value(value: repositories.replyRepository),

      // Feature providers
      ChangeNotifierProvider(
        create: (_) => UserProvider(
          registerUserUseCase: useCases.registerUserUseCase,
          loginUserUseCase: useCases.loginUserUseCase,
          getUserProfileUseCase: useCases.getUserProfileUseCase,
          updateUserProfileUseCase: useCases.updateUserProfileUseCase,
          resetPasswordUseCase: useCases.resetPasswordUseCase,
          updatePasswordUseCase: useCases.updatePasswordUseCase,
          disableUserUseCase: useCases.disableUserUseCase,
          validateTokenUseCase: useCases.validateTokenUseCase,
          socketService: _socketService, // Usar variable estática
          secureStorage: _secureStorage, // Add the required argument
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => CalendarProvider(
          createCalendarUseCase: useCases.createCalendarUseCase,
          updateCalendarUseCase: useCases.updateCalendarUseCase,
          deleteCalendarUseCase: useCases.deleteCalendarUseCase,
          getCalendarByIdUseCase: useCases.getCalendarByIdUseCase,
          getAllCalendarsUseCase: useCases.getAllCalendarsUseCase,
          addEventToCalendarUseCase: useCases.addEventToCalendarUseCase,
          removeEventFromCalendarUseCase:
              useCases.removeEventFromCalendarUseCase,
          listPublicCalendarsUseCase: useCases.listPublicCalendarsUseCase,
          shareCalendarUseCase: useCases.shareCalendarUseCase,
          getCalendarSubscribersUseCase: useCases.getCalendarSubscribersUseCase,
          setEventReminderUseCase: useCases.setEventReminderUseCase,
          socketService: _socketService, // Usar variable estática
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => CommentProvider(
          getCommentDetailsUseCase: useCases.getCommentDetailsUseCase,
          createCommentUseCase: useCases.createCommentUseCase,
          updateCommentUseCase: useCases.updateCommentUseCase,
          deleteCommentUseCase: useCases.deleteCommentUseCase,
          getCommentsByEventUseCase: useCases.getCommentsByEventUseCase,
          likeCommentUseCase: useCases.likeCommentUseCase,
          getCommentLikesUseCase: useCases.getCommentLikesUseCase,
          reportCommentUseCase: useCases.reportCommentUseCase,
          socketService: _socketService, // Usar variable estática
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => CommunityProvider(
          getCommunityDetailsUseCase: useCases.getCommunityDetailsUseCase,
          createCommunityUseCase: useCases.createCommunityUseCase,
          updateCommunityUseCase: useCases.updateCommunityUseCase,
          deleteCommunityUseCase: useCases.deleteCommunityUseCase,
          addModeratorUseCase: useCases.addModeratorUseCase,
          removeModeratorUseCase: useCases.removeModeratorUseCase,
          getFeaturedCommunitiesUseCase: useCases.getFeaturedCommunitiesUseCase,
          filterCommunitiesUseCase: useCases.filterCommunitiesUseCase,
          getAllCommunitiesUseCase: useCases.getAllCommunitiesUseCase,
          getTypesUseCase: useCases.getCommunityTypesUseCase,
          getCategoriesUseCase: useCases.getCommunityCategoriesUseCase,
          getLocationsUseCase: useCases.getCommunityLocationsUseCase,
          socketService: _socketService, // Usar variable estática
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => EventProvider(
          getEventDetailsUseCase: useCases.getEventDetailsUseCase,
          createEventUseCase: useCases.createEventUseCase,
          updateEventUseCase: useCases.updateEventUseCase,
          deleteEventUseCase: useCases.deleteEventUseCase,
          addAttendeeUseCase: useCases.addAttendeeUseCase,
          removeAttendeeUseCase: useCases.removeAttendeeUseCase,
          getFeaturedEventsUseCase: useCases.getFeaturedEventsUseCase,
          filterEventsUseCase: useCases.filterEventsUseCase,
          manageRecurrenceUseCase: useCases.manageRecurrenceUseCase,
          cancelEventUseCase: useCases.cancelEventUseCase,
          getEventCategoriesUseCase: useCases.getEventCategoriesUseCase,
          getEventTypesUseCase: useCases.getEventTypesUseCase,
          getEventLocationsUseCase: useCases.getEventLocationsUseCase,
          socketService: _socketService, // Usar variable estática
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => NotificationProvider(
          createNotificationUseCase: useCases.createNotificationUseCase,
          markNotificationAsReadUseCase: useCases.markNotificationAsReadUseCase,
          getNotificationByIdUseCase: useCases.getNotificationByIdUseCase,
          getNotificationsByUserUseCase: useCases.getNotificationsByUserUseCase,
          deleteNotificationUseCase: useCases.deleteNotificationUseCase,
          socketService: _socketService, // Inyectar SocketService correctamente
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => RatingProvider(
          createRatingUseCase: useCases.createRatingUseCase,
          updateRatingUseCase: useCases.updateRatingUseCase,
          deleteRatingUseCase: useCases.deleteRatingUseCase,
          getRatingByIdUseCase: useCases.getRatingByIdUseCase,
          getRatingsByEventUseCase: useCases.getRatingsByEventUseCase,
          calculateAverageRatingUseCase: useCases.calculateAverageRatingUseCase,
          socketService:
              _socketService, // Inyectar SocketService si es necesario
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => ReplyProvider(
          createReplyUseCase: useCases.createReplyUseCase,
          getReplyByIdUseCase: useCases.getReplyByIdUseCase,
          updateReplyUseCase: useCases.updateReplyUseCase,
          deleteReplyUseCase: useCases.deleteReplyUseCase,
          getRepliesByCommentUseCase: useCases.getRepliesByCommentUseCase,
          likeReplyUseCase: useCases.likeReplyUseCase,
          getReplyLikesUseCase: useCases.getReplyLikesUseCase,
          socketService:
              _socketService, // Inyectar SocketService si es necesario
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => SettingsProvider(_prefs),
      ),
    ];
  }
}

/// Contenedor para todas las fuentes de datos
class _DataSourceContainer {
  final UserRemoteDataSource userRemoteDataSource;
  final CalendarRemoteDataSource calendarRemoteDataSource;
  final CommentRemoteDataSource commentRemoteDataSource;
  final CommunityRemoteDataSource communityRemoteDataSource;
  final EventRemoteDataSource eventRemoteDataSource;
  final NotificationRemoteDataSource notificationRemoteDataSource;
  final RatingRemoteDataSource ratingRemoteDataSource;
  final ReplyRemoteDataSource replyRemoteDataSource;

  _DataSourceContainer({
    required this.userRemoteDataSource,
    required this.calendarRemoteDataSource,
    required this.commentRemoteDataSource,
    required this.communityRemoteDataSource,
    required this.eventRemoteDataSource,
    required this.notificationRemoteDataSource,
    required this.ratingRemoteDataSource,
    required this.replyRemoteDataSource,
  });
}

/// Contenedor para todos los repositorios
class _RepositoryContainer {
  final UserRepositoryImpl userRepository;
  final CalendarRepositoryImpl calendarRepository;
  final CommentRepositoryImpl commentRepository;
  final CommunityRepositoryImpl communityRepository;
  final EventRepositoryImpl eventRepository;
  final NotificationRepositoryImpl notificationRepository;
  final RatingRepositoryImpl ratingRepository;
  final ReplyRepositoryImpl replyRepository;

  _RepositoryContainer({
    required this.userRepository,
    required this.calendarRepository,
    required this.commentRepository,
    required this.communityRepository,
    required this.eventRepository,
    required this.notificationRepository,
    required this.ratingRepository,
    required this.replyRepository,
  });
}

/// Contenedor para todos los casos de uso
class _UseCaseContainer {
  // User use cases
  final RegisterUserUseCase registerUserUseCase;
  final LoginUserUseCase loginUserUseCase;
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final UpdatePasswordUseCase updatePasswordUseCase;
  final DisableUserUseCase disableUserUseCase;
  final ValidateTokenUseCase validateTokenUseCase;

  // Calendar use cases
  final CreateCalendarUseCase createCalendarUseCase;
  final UpdateCalendarUseCase updateCalendarUseCase;
  final DeleteCalendarUseCase deleteCalendarUseCase;
  final GetCalendarByIdUseCase getCalendarByIdUseCase;
  final GetAllCalendarsUseCase getAllCalendarsUseCase;
  final AddEventToCalendarUseCase addEventToCalendarUseCase;
  final RemoveEventFromCalendarUseCase removeEventFromCalendarUseCase;
  final ListPublicCalendarsUseCase listPublicCalendarsUseCase;
  final ShareCalendarUseCase shareCalendarUseCase;
  final GetCalendarSubscribersUseCase getCalendarSubscribersUseCase;
  final SetEventReminderUseCase setEventReminderUseCase;

  // Comment use cases
  final CreateCommentUseCase createCommentUseCase;
  final DeleteCommentUseCase deleteCommentUseCase;
  final GetCommentDetailsUseCase getCommentDetailsUseCase;
  final GetCommentLikesUseCase getCommentLikesUseCase;
  final GetCommentsByEventUseCase getCommentsByEventUseCase;
  final UpdateCommentUseCase updateCommentUseCase;
  final LikeCommentUseCase likeCommentUseCase;
  final ReportCommentUseCase reportCommentUseCase;

  // Community use cases
  final CreateCommunityUseCase createCommunityUseCase;
  final UpdateCommunityUseCase updateCommunityUseCase;
  final DeleteCommunityUseCase deleteCommunityUseCase;
  final GetCommunityDetailsUseCase getCommunityDetailsUseCase;
  final GetAllCommunitiesUseCase getAllCommunitiesUseCase;
  final AddModeratorUseCase addModeratorUseCase;
  final RemoveModeratorUseCase removeModeratorUseCase;
  final GetFeaturedCommunitiesUseCase getFeaturedCommunitiesUseCase;
  final FilterCommunitiesUseCase filterCommunitiesUseCase;
  final GetCommunityTypesUseCase getCommunityTypesUseCase;
  final GetCommunityCategoriesUseCase getCommunityCategoriesUseCase;
  final GetCommunityLocationsUseCase getCommunityLocationsUseCase;

  // Event use cases
  final CreateEventUseCase createEventUseCase;
  final UpdateEventUseCase updateEventUseCase;
  final DeleteEventUseCase deleteEventUseCase;
  final GetEventDetailsUseCase getEventDetailsUseCase;
  final AddAttendeeUseCase addAttendeeUseCase;
  final RemoveAttendeeUseCase removeAttendeeUseCase;
  final GetFeaturedEventsUseCase getFeaturedEventsUseCase;
  final FilterEventsUseCase filterEventsUseCase;
  final ManageRecurrenceUseCase manageRecurrenceUseCase;
  final CancelEventUseCase cancelEventUseCase;
  final GetEventCategoriesUseCase getEventCategoriesUseCase;
  final GetEventTypesUseCase getEventTypesUseCase;
  final GetEventLocationsUseCase getEventLocationsUseCase;

  // Notification use cases
  final CreateNotificationUseCase createNotificationUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;
  final GetNotificationByIdUseCase getNotificationByIdUseCase;
  final GetNotificationsByUserUseCase getNotificationsByUserUseCase;
  final DeleteNotificationUseCase deleteNotificationUseCase;

  // Rating use cases
  final CreateRatingUseCase createRatingUseCase;
  final UpdateRatingUseCase updateRatingUseCase;
  final DeleteRatingUseCase deleteRatingUseCase;
  final GetRatingByIdUseCase getRatingByIdUseCase;
  final GetRatingsByEventUseCase getRatingsByEventUseCase;
  final CalculateAverageRatingUseCase calculateAverageRatingUseCase;

  // Reply use cases
  final CreateReplyUseCase createReplyUseCase;
  final GetReplyByIdUseCase getReplyByIdUseCase;
  final UpdateReplyUseCase updateReplyUseCase;
  final DeleteReplyUseCase deleteReplyUseCase;
  final GetRepliesByCommentUseCase getRepliesByCommentUseCase;
  final LikeReplyUseCase likeReplyUseCase;
  final GetReplyLikesUseCase getReplyLikesUseCase;

  _UseCaseContainer({
    // User use cases
    required this.registerUserUseCase,
    required this.loginUserUseCase,
    required this.getUserProfileUseCase,
    required this.updateUserProfileUseCase,
    required this.resetPasswordUseCase,
    required this.updatePasswordUseCase,
    required this.disableUserUseCase,
    required this.validateTokenUseCase,

    // Calendar use cases
    required this.createCalendarUseCase,
    required this.updateCalendarUseCase,
    required this.deleteCalendarUseCase,
    required this.getCalendarByIdUseCase,
    required this.getAllCalendarsUseCase,
    required this.addEventToCalendarUseCase,
    required this.removeEventFromCalendarUseCase,
    required this.listPublicCalendarsUseCase,
    required this.shareCalendarUseCase,
    required this.getCalendarSubscribersUseCase,
    required this.setEventReminderUseCase,

    // Comment use cases
    required this.createCommentUseCase,
    required this.deleteCommentUseCase,
    required this.getCommentDetailsUseCase,
    required this.getCommentLikesUseCase,
    required this.getCommentsByEventUseCase,
    required this.updateCommentUseCase,
    required this.likeCommentUseCase,
    required this.reportCommentUseCase,

    // Community use cases
    required this.createCommunityUseCase,
    required this.updateCommunityUseCase,
    required this.deleteCommunityUseCase,
    required this.getCommunityDetailsUseCase,
    required this.getAllCommunitiesUseCase,
    required this.addModeratorUseCase,
    required this.removeModeratorUseCase,
    required this.getFeaturedCommunitiesUseCase,
    required this.filterCommunitiesUseCase,
    required this.getCommunityTypesUseCase,
    required this.getCommunityCategoriesUseCase,
    required this.getCommunityLocationsUseCase,

    // Event use cases
    required this.createEventUseCase,
    required this.updateEventUseCase,
    required this.deleteEventUseCase,
    required this.getEventDetailsUseCase,
    required this.addAttendeeUseCase,
    required this.removeAttendeeUseCase,
    required this.getFeaturedEventsUseCase,
    required this.filterEventsUseCase,
    required this.manageRecurrenceUseCase,
    required this.cancelEventUseCase,
    required this.getEventCategoriesUseCase,
    required this.getEventTypesUseCase,
    required this.getEventLocationsUseCase,

    // Notification use cases
    required this.createNotificationUseCase,
    required this.markNotificationAsReadUseCase,
    required this.getNotificationByIdUseCase,
    required this.getNotificationsByUserUseCase,
    required this.deleteNotificationUseCase,

    // Rating use cases
    required this.createRatingUseCase,
    required this.updateRatingUseCase,
    required this.deleteRatingUseCase,
    required this.getRatingByIdUseCase,
    required this.getRatingsByEventUseCase,
    required this.calculateAverageRatingUseCase,

    // Reply use cases
    required this.createReplyUseCase,
    required this.getReplyByIdUseCase,
    required this.updateReplyUseCase,
    required this.deleteReplyUseCase,
    required this.getRepliesByCommentUseCase,
    required this.likeReplyUseCase,
    required this.getReplyLikesUseCase,
  });
}
