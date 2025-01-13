import 'package:get/get.dart';
import 'package:letsmeet/screens/video_call_zego.dart';

class DeepLinkHandler {
  void handleDeepLink(Uri uri) {
    if (uri.pathSegments.first == 'join') {
      String meetingCode = uri.queryParameters['meetingCode'] ?? '';
      Get.to(VideoCallZ(
        channelName: meetingCode.trim(),
        conferenceID: meetingCode,
        role: Role.Participant,
      ));
    }
  }
}