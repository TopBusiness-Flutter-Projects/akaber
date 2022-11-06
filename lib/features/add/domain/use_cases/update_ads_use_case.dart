import 'package:dartz/dartz.dart';
import 'package:elwatn/core/error/failures.dart';
import 'package:elwatn/core/usecases/usecase.dart';

import '../../../../core/models/response_message.dart';
import '../entities/add_ads_model.dart';
import '../repositories/add_ads_base_repositories.dart';

class UpdateAdsUseCase extends UseCase<StatusResponse,AddAdsModel>{
  final BaseAddAdsRepositories baseAddAdsRepositories;

  UpdateAdsUseCase(this.baseAddAdsRepositories);
  @override
  Future<Either<Failure, StatusResponse>> call(AddAdsModel params) =>
      baseAddAdsRepositories.updateAds(params);
}