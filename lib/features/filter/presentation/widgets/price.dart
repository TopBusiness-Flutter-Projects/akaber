import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/assets_manager.dart';
import '../../../../core/utils/translate_text_method.dart';
import '../cubit/filter_cubit.dart';
import 'dropdown_search.dart';

class PriceWidget extends StatelessWidget {
  const PriceWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SvgPicture.asset(
              ImageAssets.priceIcon,
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 10),
             Text(
              translateText(AppStrings.priceText,context),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: context.read<FilterCubit>().priceFromController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: "0",
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 16),
             Text(
              translateText(AppStrings.toText,context),
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: context.read<FilterCubit>().priceToController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    hintText: "any"),
              ),
            ),
            const SizedBox(width: 25),
             Expanded(
                child: DropdownSearchWidget(
              dropdownList: const ["USD/1", "IQD/2"],
              isEnable: true,
              labelText: translateText(AppStrings.currencyText,context),
              icon: Icons.abc,
            ))
          ],
        )
      ],
    );
  }
}
