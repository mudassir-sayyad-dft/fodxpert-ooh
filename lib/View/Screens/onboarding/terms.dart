import 'package:flutter/material.dart';
import 'package:fodex_new/View/Components/Loaders/full_screen_loader.dart';
import 'package:fodex_new/View/Components/buttons/expanded_btn.dart';
import 'package:fodex_new/View/Components/primary_app_bar.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/routes/route_constants.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/auth_controller.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/user_controller.dart';
import 'package:fodex_new/view_model/enums/enums.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class TermsAndConditions extends StatefulWidget {
  const TermsAndConditions({super.key});

  @override
  State<TermsAndConditions> createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
  bool isAccepted = false;

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final user = Get.find<UserController>();
    print(user.currentUser);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) =>
          AppServices.pushAndRemoveUntil(RouteConstants.login),
      child: Stack(
        children: [
          Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(AppServices.getScreenHeight * 0.1),
              child: PrimaryAppBar(leading: true),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() => authController.toc.status == ApiStatus.ERROR
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [Text(authController.toc.message!)],
                    )
                  : Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: SfPdfViewer.network(
                                authController.toc.data?.docPath ?? '')),
                        Row(
                          children: [
                            Checkbox(
                              value: isAccepted,
                              onChanged: (bool? value) {
                                setState(() {
                                  isAccepted = value ?? false;
                                });
                              },
                            ),
                            const Text('I accept the terms and conditions'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: AppServices.getScreenWidth,
                          child: isAccepted
                              ? ExpandedButton(
                                  isExpanded: false,
                                  onPressed: () async {
                                    await authController.updateTOCDetails();
                                  },
                                  title: 'Next')
                              : const SizedBox(),
                        ),
                        AppServices.addHeight(20),
                      ],
                    )),
            ),
          ),
          GetBuilder<AuthController>(
              builder: (ctrller) =>
                  ctrller.loading ? FullScreenLoader() : SizedBox())
        ],
      ),
    );
  }
}
