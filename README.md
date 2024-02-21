# flutter_au10tix_sample

A Flutter project that demonstrates how to integrate AU10TIX's Smart Document Capture (SDC) and Passive Face Liveness (PFL) Flutter plugins.

## Table of Contents

- [flutter_au10tix_sample](#flutter_au10tix_sample)
  - [Table of Contents](#table-of-contents)
  - [Compatibility](#compatibility)
    - [AU10TIX SDK](#au10tix-sdk)
    - [Flutter SDK](#flutter-sdk)
  - [Project Setup](#project-setup)
    - [Prerequisite](#prerequisite)
    - [AU10TIX SDK Setup](#au10tix-sdk-setup)
    - [Permissions](#permissions)
  - [Usage](#usage)
    - [Preparing the SDK](#preparing-the-sdk)
    - [Custom UI Implementation](#custom-ui-implementation)
      - [Smart Document Capture (SDC) & Proof of Address (POA)](#smart-document-capture-sdc--proof-of-address-poa)
        - [Front End Classification (FEC)](#front-end-classification-fec)
      - [Passive Face Liveness (PFL)](#passive-face-liveness-pfl)
        - [PFL Status Codes](#pfl-status-codes)
    - [UI Component Implementation](#ui-component-implementation)
      - [UI Configurations](#ui-configurations)
    - [Au10tixCameraView Usage](#au10tixcameraview-usage)
    - [Backend Integration](#backend-integration)
  - [Support](#support)
    - [Contact](#contact)

## Compatibility

### AU10TIX SDK

The plugin is compatible with the following native AU10TIX SDK versions:

- Android: 3.7.2
- iOS: 3.26.0

### Flutter SDK

Tested with channel stable 3.16.5.

## Project Setup

### Prerequisite

Before getting started, make sure you are setup on GitHub with our native SDK and have all the necessary credentials. If you need assistance, please contact AU10TIX support.

### AU10TIX SDK Setup

1. Create a new Flutter project.
2. Open the `pubspec.yaml` file.
3. Add the AU10TIX plugin dependencies from pub.dev as follows:

   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     sdk_sdc_flutter: ^1.3.4
     sdk_pfl_flutter: ^1.3.4
   ```

   SDC - <https://pub.dev/packages/sdk_sdc_flutter>

   PFL - <https://pub.dev/packages/sdk_pfl_flutter>

4. Android:

   1. In the `android` folder, open the `local.properties` file.
   2. Add the following:

      ```gradle
      key=<your_au10tix_pat>
      ```

      The AU10TIX Android SDK will use your PAT to implement the dependencies.

5. iOS:

   1. In the `iOS` folder, open the `podfile`.
   2. Make sure you set the `platform` as follows:

      ```json
      platform :ios, '13.0'
      ```

   3. Find the following line `flutter_ios_podfile_setup` and paste the following:

      ```json
      flutter_ios_podfile_setup
      source 'https://github.com/CocoaPods/Specs.git'
      source 'https://github.com/au10tixmobile/iOS_Artifacts_cocoapods_spec.git'
      ```

   4. Save and run `pod install` in the terminal.

6. Run `flutter pub get`.

### Permissions

The AU10TIX SDK requires the following permissions:

- Camera
- Storage
- Location
- Microphone

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

### Custom UI Implementation

#### Smart Document Capture (SDC) & Proof of Address (POA)

Now that the session is ready, we can start the SDC feature:

1. The SDC camera session requires a native view to be passed for the frames to be previewed. To achieve this with Flutter code use the `Au10tixCameraView` widget, and set the `viewType` to "au10tixCameraViewSDC". Read more about the view [here](#au10tixcameraview-usage).

1. Import the SDC plugin:

   ```dart
   import 'package:sdk_sdc_flutter/sdk_sdc_flutter.dart';
   ```

1. Start the feature:

   ```dart
   //For SDC
   SdkSdcFlutter.startSDC();
   //Add isFronSide: false in case you want to declare that you are starting SDC for backside.

   //For POA
   SdkSdcFlutter.startPOA();
   ```

   The method above returns a `Future<dynamic>`, specifically for SDC is of type `Map`. The object contains three keys; `status`, `imagePath` and `croppedFilePath`.  
   The `status` key contains a value that reflects the image situation:

   | Status | Description            |
   | ------ | ---------------------- |
   | 0      | Bad Image Quality      |
   | 1      | Hold Steady            |
   | 2      | No ID Detected         |
   | 3      | Image Too Far          |
   | 4      | Image Too Close        |
   | 5      | Image Outside of Frame |

   **Note**: In the result status, only one of the first three will be returned, the rest are used for live updates.

   The `imagePath` contains a string with the path to the cached original captured image. This is usually used to display what was captured to the user.

   The `croppedFilePath` contains a string to the path of the cropped captured image, which is the same image containing only the ID itself. This is the image recommended to send to the AU10TIX server.  
    To parse these fields:

   ```dart
   final featureName = 'sdc' // or 'poa'
   final result = await SdkSdcFlutter.startSDC();
   final status = result[featureName]['status']
   final imagePath = result[featureName]['imagePath']
   final croppedImagePath = result[featureName]['croppedFilePath']
   ```

1. To receive updates on evaluated frames (see the previous step for the updates table), you set a stream, preferably using a `StreamBuilder`:

   ```dart
   SdkSdcFlutter.streamSdkUpdates()
   ```

   The plugin also contains a method that parses the update statuses and returns a text string:

   ```dart
   //For SDC
   SdkSdcFlutter.getSDCTextUpdates(event)

   //For POA
   SdkSdcFlutter.getPOATextUpdates(event)
   ```

   If you'd like the `StreamBuilder` to output the text instead of the code use something like this:

   ```dart
   StreamBuilder<String>(
                   stream: SdkSdcFlutter.streamSdkUpdates()
                       .map((event) => SdkSdcFlutter.getSDCTextUpdates(event)), //getPOATextUpdates(event)
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
   //For SDC
   SdkSDCFlutter.onCaptureClicked()

   //For POA
   SdkSDCFlutter.onCaptureClicked(isPOA: true)
   ```

   This method returns the same result as above.

1. To upload an image from the gallery:

   ```dart
   SdkSDCFlutter.onUploadClicked(isPOA: true)
   ```

   This method uses the Flutter `image_picker` plugin to show the gallery. Once an image is selected, it is processed and a result is returned.

##### Front End Classification (FEC)

Using the SDC plugin you have the option of sending the captured image to the FEC service.

1. To send the image to the service use the following command:

```dart
final result =
          await SdkSdcFlutter.performFEC(sdcResult['sdc']['croppedFilePath']);
```

1. To parse the result:

```dart
final classificationResult = result["fec"]["classificationResult"]
```

#### Passive Face Liveness (PFL)

Like the SDC, make sure that the session is first prepared before using this plugin. To best understand this section make sure to first read the SDC section above.

1.  Import the package:

    ```dart
    import 'package:sdk_pfl_flutter/sdk_pfl_flutter.dart';
    ```

2.  Add the `Au10tixCameraView` for the camera preview, with the PFL `viewType`, "au10tixCameraViewPFL". Read more about the view [here](#au10tixcameraview-usage)

3.  Start the feature:

    ```dart
    SdkPflFlutter.startPFL();
    ```

4.  The PFL is split into two parts, the first captures the selfie. The selfie is returned in the result that contains the same three keys as the SDC: `status`, `imagePath` and `croppedFilePath`. The status is either `0`, which means no face detected, or `1` which means the image is good and that the face was detected.
    The result is parsed as follows:

        ```dart
        final status = result['pfl']['status']
        ```

        The selfie is used for face compare and also for the second part, the liveness check. To send the image for the liveness check:

        ```dart
        SdkPflFlutter.validateLiveness();
        ```

5.  The liveness result includes the following keys:
    | Key | Values |
    | --- | --- |
    | status | 0 or 1 |
    | details | "Liveness failed" or "Liveness Passed" |
    | result | A json object that holds the liveness detailed response with the keys: `probability`, `quality` and `score`. For more information on the PFL server response see the PFL documentation. |

    The liveness result can be parsed similarly to the selfie result.

6.  To receive streamed updates during the selfie capturing, like in SDC, create a `StreamBuilder` and you can also the map the update statuses to text like this:

    ```dart
    StreamBuilder<String>(
                stream: SdkPflFlutter.streamPFLUpdates()
                    .map((event) => SdkPflFlutter.getPFLTextUpdates(event)),
                builder: (context, snapshot) {
                    .
                })
    ```

    The full list of statuses can be found below.

7.  If you need to stop the session manually:

    ```dart
    SdkPflFlutter.stopSession()
    ```

8.  To capture the selfie manually:

    ```dart
    SdkPflFlutter.onCaptureClicked()
    ```

    The result is returned in the same format as in the auto mode.

##### PFL Status Codes

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

### UI Component Implementation

To start the UI components for SDC and PFL add the following code:

```dart
//PFL
final result = await SdkPflFlutter.startPFLUI();

//SDC
final result = await SdkPflFlutter.startSDCUI();
//isFront: false for backside

//POA
final result = await SdkPflFlutter.startPOAUI();
```

The result will arrive after the user clicks approve.

```dart
    final featureName = 'sdc' // or 'pfl', 'poa'
    final status = result[featureName]['status']
    final imagePath = result[featureName]['imagePath']
    final croppedImagePath = result[featureName]['croppedFilePath']
```

See the sample app for a clean implementation.

#### UI Configurations

For each of the start methods above you can pass a uiConfig parameter like this:

```dart
      UIConfig uiConfig = UIConfig(
          showIntroScreen: true, // show/hide the intro screen
          showCloseButton: true, // show/hide the close button
          showPrimaryButton: true, // show/hide the capture button
          canUpload: true); // show/hide the upload option button

      sdcUIResult = await SdkSdcFlutter.startSDCUI(uiConfig: uiConfig);
```

The default value for all the fields is true unless changed.

### Au10tixCameraView Usage

1. To use the view import the `Au10tixCameraView` widget:

   ```dart
   import 'package:sdk_core_flutter/camera_view.dart';
   ```

2. Add the widget:

   ```dart
   Au10tixCameraView(
        featureHandlerFn: <fn>,
        viewType: <viewTypeString>
        )
   ```

   The widget has six parameters two required and four optional.
   Required:

   - `featureHandlerFn` - function to be trigggered when view is ready. This is a good place to put the function that starts the feature.
   - `viewType` - the feature that the view is being used for. Specifics can be found in the usage of each feature.

   Optional:

   - `width` & `height` which allow you to pass values for the width and height of the camera, although it is recommended to use the default values which will result in the view capturing 3/4 of the screen.
   - `withOverlay` & `overlayColor` are used to start the camera view with an overlay over it. There's a bug in the current Flutter's AndroidViewSurface when it comes to supporting camera in a view which results in a weird affect of the background disappearing a second before the camera preview is shown. To avoid that there's the option of starting the view with the overlay which is removed after the frames start showing. This doesn't always occur and/or is not always noticable. Feel free to try it and decide for yourself whether or not to use it.

### Backend Integration

You have the option of processing flows with the Au10tix backend directly from the mobile. The following flows are available:

- Identity Verification(IDV)
- Face to Face (F2F)
- Proof of Address (POA)
  The SDK knows to cache the media assets collected along the way and depending on the flow triggered they will be used when needed:

```dart
   //For IDV
      final result = await Au10tix.sendIDV();

   //For POA
      final result = await Au10tix.sendPOA("John", "Smith", "123 abbey rd"); //this is the data that will be compared in the POA request

   // For F2F
      final String? imagePath = await Au10tix.getImageFromGallery();
      final result = await Au10tix.sendF2F(imagePath!);

   // Printing the request ID, keep it you will need it to poll for the result
      print(result["beKit"]["requestID"].toString());
```

## Support

### Contact

If you have any questions regarding our implementation guide please contact AU10TIX Customer Service at support.tickets@au10tix.com. AU10TIX's online contains a wealth of information to help get you started with AU10TIX. Check it out at: https://www.au10tix.com.
