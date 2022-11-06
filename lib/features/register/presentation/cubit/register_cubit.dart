import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:elwatn/core/models/response_message.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/map_failure_message.dart';
import '../../../login/data/models/login_data_model.dart';
import '../../../login/domain/entities/login_domain_model.dart';
import '../../data/models/register_data_model.dart';
import '../../domain/use_cases/check_code_use_case.dart';
import '../../domain/use_cases/post_register_user_use_case.dart';
import '../../domain/use_cases/reset_password_use_case.dart';
import '../../domain/use_cases/send_code_use_case.dart';
import '../../domain/use_cases/update_profile_use_case.dart';
import '../../domain/use_cases/update_store_profile_use_case.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(
    this.postRegisterUserUseCase,
    this.updateProfileUseCase,
    this.updateStoreProfileUseCase,
    this.sendCodeUseCase,
    this.checkCodeUseCase, this.resetPasswordUseCase,
  ) : super(RegisterInitial());

  bool choose1 = false;
  bool choose2 = false;
  int userType = 0;
  XFile? image;
  String checkCodeOfEmail = '';
  final picker = ImagePicker();
  String imageLink = "";
  String registerBtn = "";
  String token = "";
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController whatsappController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController facebookController = TextEditingController();
  TextEditingController instaController = TextEditingController();
  TextEditingController twitterController = TextEditingController();
  TextEditingController snapController = TextEditingController();

  final PostRegisterUserUseCase postRegisterUserUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final UpdateStoreProfileUseCase updateStoreProfileUseCase;
  final SendCodeUseCase sendCodeUseCase;
  final CheckCodeUseCase checkCodeUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  putDataToEdit(LoginDataModel userModel) {
    registerBtn = "update";
    if(userModel.data!.user!.phone!=null){
      registerBtn = "update";
      token = userModel.data!.accessToken!;
      userType = userModel.data!.user!.userType!;
    }else{
      token =userModel.data!.accessToken!;
      registerBtn = "save";
    }
    emailController.text = userModel.data!.user!.email!;
    passwordController.text = "";
    nameController.text = userModel.data!.user!.name ?? "";
    whatsappController.text = userModel.data!.user!.whatsapp ?? "";
    phoneController.text = userModel.data!.user!.phone ?? "";
    facebookController.text = userModel.data!.user!.facebook ?? "";
    instaController.text = userModel.data!.user!.instagram ?? "";
    twitterController.text = userModel.data!.user!.twitter ?? "";
    snapController.text = userModel.data!.user!.snapchat ?? "";
    imageLink = userModel.data!.user!.image ?? "";
  }

  updateLoginStoreData(String token) async {
    final response = await updateStoreProfileUseCase(token);
    response.fold(
      (l) => emit(
        UpdateStoreDataFailure(),
      ),
      (loginModel) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(loginModel)).then(
          (value) {
            emit(UpdateStoreDataSuccessfully());
            Future.delayed(
              const Duration(seconds: 2),
              () {
                emit(RegisterInitial());
              },
            );
          },
        );
      },
    );
  }

  changeUser(bool ch1, bool ch2, int type) {
    choose1 = ch1;
    choose2 = ch2;
    userType = type;
    emit(RegisterUserChanged());
  }

  postRegisterData(RegistrationUserModel user) async {
    emit(RegisterLoading());
    Either<Failure, RegistrationDataModel> response =
        await postRegisterUserUseCase(user);
    response.fold(
      (failure) {
        return RegisterFailure(
            message: MapFailureMessage.mapFailureToMessage(failure));
      },
      (userModel) => RegisterLoaded(userModel),
    );
  }

  updateProfileData() async {
    emit(UpdateProfileLoading());
    Either<Failure, LoginModel> response = await updateProfileUseCase(
      RegistrationUserModel(
        name: nameController.text,
        phone: phoneController.text,
        whatsapp: whatsappController.text,
        email: emailController.text,
        password: passwordController.text,
        userType: userType.toString(),
        image: image != null ? image!.path : "",
        token: token,
      ),
    );
    response.fold(
      (failure) {
        return UpdateProfileFailure(
            message: MapFailureMessage.mapFailureToMessage(failure));
      },
      (statusResponse) {
        if (statusResponse.code == 200) {
          print("update Successfully");
          updateLoginStoreData(statusResponse.data!.accessToken!);
        } else {
          print("Error");
          print(statusResponse.code);
          print(statusResponse.message);
        }
        return UpdateProfileLoaded(statusResponse);
      },
    );
  }

  sendCodeToEmail(String email) async {
    emit(SendCodeLoading());
    final response = await sendCodeUseCase(email);
    response.fold((l) => emit(SendCodeFailure()), (r) {
      if (r.code == 200) {
        emit(SendCodeSuccessfully());
        Future.delayed(Duration(seconds: 2), () {
          emit(RegisterInitial());
        });
      } else if (r.code == 422) {
        emit(SendCodeInvalidEmail());
        Future.delayed(Duration(milliseconds: 700), () {
          emit(RegisterInitial());
        });
      }
    });
  }

  checkCode(String code) async {
    emit(CheckCodeLoading());
    final response = await checkCodeUseCase(code);
    response.fold((l) => emit(CheckCodeFailure()), (r) {
      if (r.code==200) {
        checkCodeOfEmail = r.checkCode;
        emit(CheckCodeSuccessfully());
        Future.delayed(Duration(seconds: 2), () {
          emit(RegisterInitial());
        });
      } else if (r.code == 422) {
        emit(CheckCodeInvalidCode());
        Future.delayed(Duration(seconds: 2), () {
          emit(RegisterInitial());
        });
      }
    });
  }

  resetPassword(String password) async {
    emit(ResetPasswordLoading());
    final response = await resetPasswordUseCase([checkCodeOfEmail,password]);
    response.fold((l) => emit(ResetPasswordFailure()), (r) {
      if (r.code==200) {
        emit(ResetPasswordSuccessfully());
        Future.delayed(const Duration(seconds: 2), () {
          emit(RegisterInitial());
        });
      } else if (r.code == 422) {
        emit(ResetPasswordInvalidCode());
        Future.delayed(Duration(seconds: 2), () {
          emit(RegisterInitial());
        });
      }
    });
  }

}
