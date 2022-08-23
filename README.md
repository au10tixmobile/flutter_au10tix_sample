# flutter_au10tix_sample

A Flutter project that demonstrates how to integrate AU10TIX's Smart Document Capture (SDC) and Passive Face Liveness (PFL) Flutter plugins.

## Table of Contents

* [Compatibility](#compatibility)
  * [AU10TIX SDK](#au10tix-sdk)
  * [Flutter SDK](#flutter-sdk)
* [Project Setup](#setup)
  * [Prerequisite](#prerequisite)
    * [AU10TIX SDK Setup](#au10tix-sdk-setup)
      * [Android](#android)
      * [iOS](#ios)
    * [Permissions](#permissions)
  * [Usage](#usage)
    * [Preparing The SDK](#change-log)
    * [Smart Document Capture (SDC)](#smart-document-capture-sdc)
    * [Passive Face Liveness (PFL)](#passive-face-liveness-pfl)
      * [PFL Status Codes](#pfl-status-codes)
* [Support](#support)
    * [Contact](#contact)

## Compatibility

### AU10TIX SDK

The plugin is compatible with the following native AU10TIX SDK versions:

* Android: 2.7.3
* iOS: 3.6.0

### Flutter SDK

Due to the fact that the SDK uses an AndroidView widget for the camera it is recommended to use:

* Flutter SDK <= 2.10.5

**Note**: Although later versions of the plugin work, there is a bug in the AndroidView widget causing it to ignore positioning and constraints stopping you from positioning it as you see fit.

## Project Setup

### Prerequisite

Before getting started, make sure you are setup on GitHub with our native SDK and have all the necessary credentials. If you need assistance, please contact AU10TIX support.

### AU10TIX SDK Setup

1. Create a new Flutter project.
1. Open the `pubspec.yaml` file.
1. Add the AU10TIX plugin dependencies as follows:

    ```yaml
    dependencies:
      flutter:
        sdk: flutter
      sdk_sdc_flutter: ^1.0.0
      sdk_pfl_flutter: ^1.0.0
    ```

1. Android:

    1. In the `android` folder, open the `local.properties` file.
    1. Add the following:

        ```js
        key=<your_au10tix_pat>
        ```

       The AU10TIX Android SDK will use your PAT to implement the dependencies.

1. iOS:

    1. In the `iOS` folder, open the `podfile`.
    1. Make sure you set the `platform` as follows:

        ```json
        platform :ios, '13.0'
        ```

    1. Find the following line `flutter_ios_podfile_setup` and paste the following:

        ```json
        flutter_ios_podfile_setup
        source 'https://github.com/CocoaPods/Specs.git'
        source 'https://github.com/Au10tixOrg/iOS_Artifacts_cocoapods_spec.git'
        ```

    1. Save and run `pod install` in the terminal.
1. Run `flutter pub get`.

### Permissions

The AU10TIX SDK requires the following permissions:

* Camera
* Storage
* Location
* Microphone

In this sample we use the `permission_handler` plugin: <https://pub.dev/packages/permission_handler>.

Follow the guide in the plugin to add the permissions above.

## Usage

### Preparing the SDK

1. Import the AU10TIX Core plugin:

    ```dart
    import 'package:sdk_core_flutter/sdk_core_flutter.dart';
    ```

1. Initialize the SDK:

    ```dart
    Au10tix.init(<jwt_token>);
    ```

1. As the `init` function is of type `Future<Map<dynamic, dynamic>>` if you would like to parse the session ID from the result, do this as follows (remember to add `await`):

    ```dart
    result['init']
    ```

### Smart Document Capture (SDC)

Now that the session is ready, we can start the SDC feature:

1. The SDC camera session requires a native view to be passed for the frames to be previewed. To achieve this with Flutter code import the `Au10tixCameraView` widget.

    ```dart
    import 'package:sdk_core_flutter/camera_view.dart';
    ```

1. The widget contains two parameters; `viewType` and `featureHandlerFn`. The view type should be of type "au10tixCameraViewSDC" and the handler function will be triggered once the view is ready, that is when it best recommended to start the SDC feature. Add the widget to yours like so:

    ```dart
    Au10tixCameraView(
                        featureHandlerFn: _startSDC,
                        viewType: "au10tixCameraViewSDC")                      
    ```

1. Import the SDC plugin:

    ```dart
    import 'package:sdk_sdc_flutter/sdk_sdc_flutter.dart';
    ```

1. Start the feature:

    ```dart
    SdkSdcFlutter.startSDC();
    ```

   The method above returns a `Future<dynamic>`, specifically for SDC is of type `Map`. The object contains three keys; `status`, `imagePath` and `croppedFilePath`.  
   The `status` key contains a value that reflects the image situation:

   | Status | Description |
   | ----------- | ----------- |
   | 0 | Bad Image Quality |
   | 1 | Hold Steady |
   | 2 | No ID Detected |
   | 3 | Image Too Far |
   | 4 | Image Too Close |
   | 5 | Image Outside of Frame |

    **Note**: In the result status, only one of the first three will be returned, the rest are used for live updates.

    The `imagePath` contains a string with the path to the cached original captured image. This is usually used to display what was captured to the user.

    The `croppedFilePath` contains a string to the path of the cropped captured image, which is the same image containing only the ID itself. This is the image recommended to send to the AU10TIX server.  
    To parse these fields:

    ```dart
    final result = await SdkSdcFlutter.startSDC();
    final status = result['sdc']['status']
    final imagePath = result['sdc']['imagePath']
    final croppedImagePath = result['sdc']['croppedFilePath']
    ```

1. To receive updates on evaluated frames (see the previous step for the updates table), you set a stream, preferably using a `StreamBuilder`:

    ```dart
    SdkSdcFlutter.streamSdkUpdates()
    ```

    The plugin also contains a method that parses the update statuses and returns a text string:

    ```dart
    SdkSdcFlutter.getSDCTextUpdates(event)
    ```

    If you'd like the `StreamBuilder` to output the text instead of the code use something like this:

    ```dart
    StreamBuilder<String>(
                    stream: SdkSdcFlutter.streamSdkUpdates()
                        .map((event) => SdkSdcFlutter.getSDCTextUpdates(event)),
                    builder: (context, snapshot) {
                        ...
                        })
    ```

1. If for some reason you want to stop the session:

    ```dart
    SdkSDCFlutter.stopSession()
    ```

1. To manually capture an image:

    ```dart
    SdkSDCFlutter.onCaptureClicked()
    ```

    This method returns the same result as above.

1. To upload an image from the gallery:

    ```dart
    SdkSDCFlutter.onUploadClicked()
    ```

    This method uses the Flutter `image_picker` plugin to show the gallery. Once an image is selected, it is processed and a result is returned.

### Passive Face Liveness (PFL)

Like the SDC, make sure that the session is first prepared before using this plugin. To best understand this section make sure to first read the SDC section above.

1. Import the package:

    ```dart
    import 'package:sdk_pfl_flutter/sdk_pfl_flutter.dart';
    ```

1. Add the `Au10tixCameraView` for the camera preview, this time with the PFL `viewType` and a PFL handler:

    ```dart
    Au10tixCameraView(
                        featureHandlerFn: _startPFL,
                        viewType: "au10tixCameraViewPFL")                      
    ```

1. Start the feature:

    ```dart
    SdkPflFlutter.startPFL();
    ```

1. The PFL is split into two parts, the first captures the selfie. The selfie is returned in the result that contains the same three keys as the SDC: `status`, `imagePath` and `croppedFilePath`. The status is either `0`, which means no face detected, or `1` which means the image is good and that the face was detected.
The result is parsed as follows:

    ```dart
    final status = result['pfl']['status']
    ```

    The selfie is used for face compare and also for the second part, the liveness check. To send the image for the liveness check:

    ```dart
    SdkPflFlutter.validateLiveness();
    ```

1. The liveness result includes the following keys:
    | Key | Values |
    | --- | --- |
    | status | 0 or 1 |
    | details | "Liveness failed" or "Liveness Passed" |
    | result | A json object that holds the liveness detailed response with the keys: `probability`, `quality` and `score`. For more information on the PFL server response see the PFL documentation. |

    The liveness result can be parsed similarly to the selfie result.
1. To receive streamed updates during the selfie capturing, like in SDC, create a `StreamBuilder` and you can also the map the update statuses to text like this:

    ```dart
    StreamBuilder<String>(
                stream: SdkPflFlutter.streamPFLUpdates()
                    .map((event) => SdkPflFlutter.getPFLTextUpdates(event)),
                builder: (context, snapshot) {
                    .
                })
    ```

    The full list of statuses can be found below.
1. If you need to stop the session manually:

    ```dart
    SdkPflFlutter.stopSession()
    ```

1. To capture the selfie manually:

    ```dart
    SdkPflFlutter.onCaptureClicked()
    ```

    The result is returned in the same format as in the auto mode.

#### PFL Status Codes

The following is a list of codes for updates and errors:

```dart
static const int RECORDING_STARTED = 9;
static const int USER_INTERRUPTED = 12;
static const int RECORDING_ENDED = 13;
static const int HOLD_STEADY = 200;
static const int ERROR_INTERNAL = 300;
static const int ERROR_HOLD_DEVICE_STRAIGHT = 301;
static const int ERROR_NO_FACE_DETECTED = 302;
static const int ERROR_MULTIPLE_FACES_DETECTED = 303;
static const int ERROR_FACE_TOO_FAR = 304;
static const int ERROR_FACE_TOO_CLOSE = 305;
static const int ERROR_HOLD_DEVICE_STEADY = 306;
static const int ERROR_FAILED_ALL_RETRIES = 307;
static const int ERROR_FACE_TOO_CLOSE_TO_BORDER = 309;
static const int ERROR_FACE_TOO_CLOSE_TO_RIGHT = 310;
static const int ERROR_FACE_TOO_CLOSE_TO_LEFT = 311;
static const int ERROR_FACE_TOO_CLOSE_TO_TOP = 312;
static const int ERROR_FACE_TOO_CLOSE_TO_BOTTOM = 313;
static const int ERROR_FACE_CROPPED = 314;
static const int ERROR_FACE_ANGLE_TOO_LARGE = 315;
static const int ERROR_FACE_IS_OCCLUDED = 316;
static const int ERROR_FAILED_TO_READ_IMAGE = 317;
static const int ERROR_FAILED_TO_WRITE_IMAGE = 318;
static const int ERROR_FAILED_TO_READ_MODEL = 319;
static const int ERROR_FAILED_TO_ALLOCATE = 320;
static const int ERROR_INVALID_CONFIG = 321;
static const int ERROR_NO_SUCH_OBJECT_IN_BUILD = 322;
static const int ERROR_FAILED_TO_PREPROCESS_IMAGE_WHILE_PREDICT = 323;
static const int ERROR_FAILED_TO_PREPROCESS_IMAGE_WHILE_DETECT = 324;
static const int ERROR_FAILED_TO_PREDICT_LANDMARKS = 325;
static const int ERROR_INVALID_FUSE_MODE = 326;
static const int ERROR_NULLPTR = 327;
static const int ERROR_LICENSE_ERROR = 328;
static const int ERROR_INVALID_META = 329;
static const int ERROR_UNKNOWN = 330;
```

## Support

### Contact

If you have any questions regarding our implementation guide please contact AU10TIX Customer Service at support.tickets@au10tix.com. AU10TIX's online contains a wealth of information to help get you started with AU10TIX. Check it out at: https://www.au10tix.com.