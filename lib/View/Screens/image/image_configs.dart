import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class ImageConfig {
  static ProImageEditorConfigs proImageEditorConfigs = ProImageEditorConfigs(
    textEditor: TextEditorConfigs(
      showSelectFontStyleBottomBar: true,
      customTextStyles: [
        GoogleFonts.oldStandardTt(),
        GoogleFonts.montserrat(),
        GoogleFonts.greatVibes(),
        GoogleFonts.monteCarlo(),
        GoogleFonts.eagleLake(),
        GoogleFonts.mrsSheppards(),
        GoogleFonts.creepster(),
        GoogleFonts.gelasio(),
        GoogleFonts.shrikhand(),
        GoogleFonts.poppins(),
        GoogleFonts.meaCulpa(),
        GoogleFonts.openSans(),
        GoogleFonts.leagueSpartan(),
        GoogleFonts.alike(),
        GoogleFonts.lobster(),
        GoogleFonts.pacifico(),
        GoogleFonts.roboto(),
        GoogleFonts.permanentMarker(),
        GoogleFonts.modernAntiqua(),
        GoogleFonts.kalam(),
        GoogleFonts.kanit(),
        GoogleFonts.merienda(),
        GoogleFonts.satisfy(),
      ],
    ),
    emojiEditor: const EmojiEditorConfigs(),

    // designMode: ImageEditor,
    // cropRotateEditorConfigs: const CropRotateEditorConfigs(

    // ),
    paintEditor: const PaintEditorConfigs(),
    stickerEditor: const StickerEditorConfigs(
      enabled: true,
    ),
  );
}

class StickersWidget extends StatefulWidget {
  final Function(Widget, {WidgetLayerExportConfigs? exportConfigs}) setLayer;
  const StickersWidget({super.key, required this.setLayer});

  @override
  State<StickersWidget> createState() => _StickersWidgetState();
}

class _StickersWidgetState extends State<StickersWidget> {
  List<XFile> mediaList = [];
  bool loading = false;

  fetchNewMedia() async {
    final ImagePicker imagePicker = ImagePicker();
    final List<XFile> images = await imagePicker.pickMultiImage();

    for (var image in images) {
      setState(() {
        mediaList.add(image);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNewMedia();
  }

  @override
  Widget build(BuildContext context) {
    print(mediaList.length);
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        height: loading ? 200 : null,
        color: const Color.fromARGB(255, 224, 239, 251),
        child: loading
            ? const Center(child: CircularProgressIndicator.adaptive())
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 150,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: mediaList.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  Widget widgetData = ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: FutureBuilder(
                        future: mediaList[index].readAsBytes(),
                        builder: (BuildContext context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return snapshot.data == null
                                ? const SizedBox()
                                : Image.memory(
                                    snapshot.data as Uint8List,
                                    fit: BoxFit.cover,
                                  );
                          }
                          return const Center(
                              child: CircularProgressIndicator.adaptive());
                        },
                      )
                      //  Image.network(
                      //   'https://picsum.photos/id/${(index + 3) * 3}/2000',
                      //   width: 120,
                      //   height: 120,
                      //   fit: BoxFit.cover,
                      //   loadingBuilder: (context, child, loadingProgress) {
                      //     return AnimatedSwitcher(
                      //       layoutBuilder: (currentChild, previousChildren) {
                      //         return SizedBox(
                      //           width: 120,
                      //           height: 120,
                      //           child: Stack(
                      //             fit: StackFit.expand,
                      //             alignment: Alignment.center,
                      //             children: <Widget>[
                      //               ...previousChildren,
                      //               if (currentChild != null) currentChild,
                      //             ],
                      //           ),
                      //         );
                      //       },
                      //       duration: const Duration(milliseconds: 200),
                      //       child: loadingProgress == null
                      //           ? child
                      //           : Center(
                      //               child: CircularProgressIndicator(
                      //                 value: loadingProgress.expectedTotalBytes !=
                      //                         null
                      //                     ? loadingProgress.cumulativeBytesLoaded /
                      //                         loadingProgress.expectedTotalBytes!
                      //                     : null,
                      //               ),
                      //             ),
                      //     );
                      //   },
                      // ),
                      );
                  return GestureDetector(
                    onTap: () => widget.setLayer(
                      Image.file(
                        File(mediaList[index].path),
                        fit: BoxFit.cover,
                      ),
                      exportConfigs: WidgetLayerExportConfigs(
                        fileUrl: mediaList[index].path, // ✅ THIS IS CRUCIAL
                      ),
                    ),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: widgetData,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
