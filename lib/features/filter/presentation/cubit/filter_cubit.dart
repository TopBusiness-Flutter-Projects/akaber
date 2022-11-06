import 'package:dartz/dartz.dart';
import 'package:elwatn/core/error/failures.dart';
import 'package:elwatn/core/utils/map_failure_message.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../data/models/agent_list_data_model.dart';
import '../../data/models/amenities_data_model.dart';
import '../../data/models/cities_data_model.dart';
import '../../data/models/cities_location_data_model.dart';
import '../../domain/entities/filterModel.dart';
import '../../domain/entities/filter_response_domian_model.dart';
import '../../domain/use_cases/filter_use_case.dart';
import '../../domain/use_cases/get_agent_list_use_case.dart';
import '../../domain/use_cases/get_amenities_use_case.dart';
import '../../domain/use_cases/get_cities_location_use_case.dart';
import '../../domain/use_cases/get_cities_use_case.dart';

part 'filter_state.dart';

class FilterCubit extends Cubit<FilterState> {
  FilterCubit(
    this.getAmenitiesUseCase,
    this.getCitiesLocationUseCase,
    this.getCitiesUseCase,
    this.getAgentUseCase,
    this.getFiltersResponse,
  ) : super(FilterInitial()) {
    getAllFilterCities();
    getAllFilterAgentList();
  }

  final GetAgentUseCase getAgentUseCase;
  final GetCitiesUseCase getCitiesUseCase;
  final GetAmenitiesUseCase getAmenitiesUseCase;
  final GetCitiesLocationUseCase getCitiesLocationUseCase;
  final GetFiltersResponseUseCase getFiltersResponse;
  late CitiesFilterModel citiesFilterModel;
  late CitiesLocationsModel citiesLocationsModel;
  late FilterAgentListModel filterAgentListModel;
  late FilterResponse filterResponse;
  bool isAgentDropdown = false;
  bool isCitiesDropdown = false;
  bool isCitiesLocationsDropdown = false;

  List<String> citiesEn = [];
  List<String> citiesAr = [];
  List<String> citiesKu = [];
  List<String> citiesLocationEn = [];
  List<String> citiesLocationAr = [];
  List<String> citiesLocationKu = [];
  List<String> agentNameEn = [];
  List<String> agentNameAr = [];
  List<String> agentNameKu = [];

  String status = 'sale';
  String currency = '';
  int cityId = 0;

  int locationId = 0;

  int type = -1;

  int priceFrom = 0;

  int priceTo = 0;

  int bedroom = -1;

  int bathroom = 0;

  int sizeFrom = 0;

  int sizeTo = 0;

  int agentId = 0;

  TextEditingController priceFromController = TextEditingController();
  TextEditingController priceToController = TextEditingController();
  TextEditingController areaFromController = TextEditingController();
  TextEditingController areaToController = TextEditingController();

  int propertySelected = -1;

  getCities() {
    for (var element in citiesFilterModel.data!) {
      citiesEn.add("${element.nameEn!}/${element.id}/");
      citiesAr.add("${element.nameAr!}/${element.id}/");
      citiesKu.add("${element.nameKu!}/${element.id}/");
    }
  }

  getCitiesLocations() {
    for (var element in citiesLocationsModel.data!) {
      citiesLocationEn.add("${element.nameEn!}/${element.id}/");
      citiesLocationAr.add("${element.nameAr!}/${element.id}/");
      citiesLocationKu.add("${element.nameKu!}/${element.id}/");
    }
  }

  getAgentList() {
    for (var element in filterAgentListModel.data!) {
      agentNameEn.add("${element.nameEn!}/${element.id}/");
      agentNameAr.add("${element.nameAr!}/${element.id}/");
      agentNameKu.add("${element.nameKu!}/${element.id}/");
    }
  }

  clearCitiesLocations() {
    citiesLocationEn.clear();
    citiesLocationAr.clear();
    citiesLocationKu.clear();
  }

  getAllFilterCities() async {
    emit(FilterCitiesLoading());
    Either<Failure, CitiesFilterModel> response =
        await getCitiesUseCase(NoParams());
    emit(
      response.fold(
          (failure) =>
              FilterCitiesError(MapFailureMessage.mapFailureToMessage(failure)),
          (citiesFilterModel) {
        this.citiesFilterModel = citiesFilterModel;
        getCities();
        isCitiesDropdown = true;
        return FilterCitiesLoaded(citiesFilterModel);
      }),
    );
  }

  getAllLocationOfCitiesById(String id) async {
    emit(FilterCitiesLocationLoading());
    Either<Failure, CitiesLocationsModel> response =
        await getCitiesLocationUseCase(id);
    emit(
      response.fold(
          (failure) =>
              FilterCitiesError(MapFailureMessage.mapFailureToMessage(failure)),
          (citiesLocationsModel) {
        this.citiesLocationsModel = citiesLocationsModel;
        getCitiesLocations();
        isCitiesLocationsDropdown = true;
        return FilterCitiesLocationLoaded(citiesLocationsModel);
      }),
    );
  }

  getAllFilterAmenities() async {
    emit(FilterAmenitiesLoading());
    Either<Failure, AmenitiesFilterModel> response =
        await getAmenitiesUseCase(NoParams());
    emit(
      response.fold(
          (failure) =>
              FilterCitiesError(MapFailureMessage.mapFailureToMessage(failure)),
          (amenitiesFilterModel) =>
              FilterAmenitiesLoaded(amenitiesFilterModel)),
    );
  }

  getAllFilterAgentList() async {
    emit(FilterAgentsLoading());
    Either<Failure, FilterAgentListModel> response =
        await getAgentUseCase(NoParams());
    emit(
      response.fold(
          (failure) =>
              FilterAgentsError(MapFailureMessage.mapFailureToMessage(failure)),
          (agentListModel) {
        filterAgentListModel = agentListModel;
        getAgentList();
        isAgentDropdown = true;
        return FilterAgentsLoaded(agentListModel);
      }),
    );
  }

  getFilterResponse() async {
    emit(FilterResponseLoading());
    Either<Failure, FilterResponse> response =
        await getFiltersResponse(FilterModel());
    emit(
      response.fold(
          (failure) => FilterResponseError(
              MapFailureMessage.mapFailureToMessage(failure)),
          (filterResponse) {
        this.filterResponse = filterResponse;
        return FilterResponseLoaded(filterResponse);
      }),
    );
  }

  pageChange() {
    emit(PageChanged());
  }
}
