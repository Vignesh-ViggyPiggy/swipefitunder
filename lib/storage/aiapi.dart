// // // import 'dart:io';
// // // import 'dart:typed_data';
// //
// // // import 'package:firebase_storage/firebase_storage.dart';
// // // import 'package:http/http.dart' as http;
// // // import 'package:path_provider/path_provider.dart';
// //
// // // class TryOnApiClient {
// // //   final String baseUrl;
// // //   final FirebaseStorage storage;
// //
// // //   TryOnApiClient(this.baseUrl) : storage = FirebaseStorage.instance;
// //
// // //   Future<void> uploadImages(File humanImage, String garmentImagePath) async {
// // //     // Download garment image from Firebase Cloud Storage
// // //     final ref = storage.ref(garmentImagePath);
// // //     final Directory tempDir = await getTemporaryDirectory();
// // //     final File tempGarmentImage =
// // //         File('${tempDir.path}/temp_garment_image.jpg');
// //
// // //     try {
// // //       await ref.writeToFile(tempGarmentImage);
// // //     } catch (e) {
// // //       throw Exception('Failed to download garment image: $e');
// // //     }
// //
// // //     // Prepare the multipart request
// // //     var request =
// // //         http.MultipartRequest('POST', Uri.parse('$baseUrl/upload_images/'));
// //
// // //     // Add human image
// // //     request.files
// // //         .add(await http.MultipartFile.fromPath('human_image', humanImage.path));
// //
// // //     // Add garment image
// // //     request.files.add(await http.MultipartFile.fromPath(
// // //         'garment_image', tempGarmentImage.path));
// //
// // //     // Send the request
// // //     var response = await request.send();
// //
// // //     // Delete the temporary file
// // //     await tempGarmentImage.delete();
// //
// // //     if (response.statusCode != 200) {
// // //       throw Exception('Failed to upload images');
// // //     }
// // //   }
// //
// // //   Future<void> runTryOn({
// // //     required String garmentDes,
// // //     required bool isChecked,
// // //     required bool isCheckedCrop,
// // //     required int denoiseSteps,
// // //     required int seed,
// // //   }) async {
// // //     var response = await http.post(
// // //       Uri.parse('$baseUrl/run_tryon/'),
// // //       body: {
// // //         'garment_des': garmentDes,
// // //         'is_checked': isChecked.toString(),
// // //         'is_checked_crop': isCheckedCrop.toString(),
// // //         'denoise_steps': denoiseSteps.toString(),
// // //         'seed': seed.toString(),
// // //       },
// // //     );
// // //     if (response.statusCode != 200) {
// // //       throw Exception('Failed to run try-on');
// // //     }
// // //   }
// //
// // //   Future<Uint8List> getOutputImage() async {
// // //     var response = await http.get(Uri.parse('$baseUrl/get_output_image/'));
// // //     if (response.statusCode == 200) {
// // //       return response.bodyBytes;
// // //     } else {
// // //       throw Exception('Failed to get output image');
// // //     }
// // //   }
// //
// // //   Future<Uint8List> getMaskedImage() async {
// // //     var response = await http.get(Uri.parse('$baseUrl/get_masked_image/'));
// // //     if (response.statusCode == 200) {
// // //       return response.bodyBytes;
// // //     } else {
// // //       throw Exception('Failed to get masked image');
// // //     }
// // //   }
// // // }
// //
// // import 'dart:io';
// //
// // import 'package:http/http.dart' as http;
// // import 'package:path_provider/path_provider.dart';
// //
// // class TryOnApiClient {
// //   final String baseUrl;
// //
// //   TryOnApiClient(this.baseUrl);
// //
// //   // Future<void> uploadImages(File humanImage, String garmentImageUrl) async {
// //   //   // Download garment image from URL
// //   //   final http.Response garmentResponse =
// //   //       await http.get(Uri.parse(garmentImageUrl));
// //   //   final Directory tempDir = await getTemporaryDirectory();
// //   //   final File tempGarmentImage =
// //   //       File('${tempDir.path}/temp_garment_image.jpg');
// //   //   await tempGarmentImage.writeAsBytes(garmentResponse.bodyBytes);
// //
// //   //   var request =
// //   //       http.MultipartRequest('POST', Uri.parse('$baseUrl/upload_images/'));
// //   //   request.files
// //   //       .add(await http.MultipartFile.fromPath('human_image', humanImage.path));
// //   //   request.files.add(await http.MultipartFile.fromPath(
// //   //       'garment_image', tempGarmentImage.path));
// //
// //   //   var response = await request.send();
// //   //   await tempGarmentImage.delete();
// //
// //   //   if (response.statusCode != 200) {
// //   //     throw Exception('Failed to upload images');
// //   //   }
// //   // }
// //
// //   Future<void> uploadImages(File humanImage, String garmentImageUrl) async {
// //     try {
// //       print('Downloading garment image from: $garmentImageUrl');
// //       final http.Response garmentResponse =
// //           await http.get(Uri.parse(garmentImageUrl));
// //
// //       if (garmentResponse.statusCode != 200) {
// //         throw Exception(
// //             'Failed to download garment image. Status: ${garmentResponse.statusCode}');
// //       }
// //
// //       print('Garment image downloaded successfully');
// //
// //       final Directory tempDir = await getTemporaryDirectory();
// //       final File tempGarmentImage =
// //           File('${tempDir.path}/temp_garment_image.jpg');
// //       await tempGarmentImage.writeAsBytes(garmentResponse.bodyBytes);
// //
// //       print('Temporary garment image created at: ${tempGarmentImage.path}');
// //
// //       var request =
// //           http.MultipartRequest('POST', Uri.parse('$baseUrl/upload_images/'));
// //       print('baseurl:    ${baseUrl}');
// //
// //       print('Adding human image from: ${humanImage.path}');
// //       request.files.add(
// //           await http.MultipartFile.fromPath('human_image', humanImage.path));
// //
// //       print('Adding garment image from: ${tempGarmentImage.path}');
// //       request.files.add(await http.MultipartFile.fromPath(
// //           'garment_image', tempGarmentImage.path));
// //
// //       print('Sending request to: ${request.url}');
// //       var streamedResponse = await request.send();
// //       var response = await http.Response.fromStream(streamedResponse);
// //
// //       print('Response received. Status: ${response.statusCode}');
// //       print('Response body: ${response.body}');
// //
// //       await tempGarmentImage.delete();
// //
// //       if (response.statusCode != 200) {
// //         throw Exception(
// //             'Failed to upload images. Status: ${response.statusCode}, Body: ${response.body}');
// //       }
// //
// //       print('Images uploaded successfully');
// //     } catch (e) {
// //       print('Error in uploadImages: $e');
// //       throw Exception('Failed to upload images: $e');
// //     }
// //   }
// //
// //   Future<void> runTryOn({
// //     required String garmentDes,
// //     required bool isChecked,
// //     required bool isCheckedCrop,
// //     required int denoiseSteps,
// //     required int seed,
// //   }) async {
// //     try {
// //       var response = await http.post(
// //         Uri.parse('$baseUrl/run_tryon/'),
// //         body: {
// //           'garment_des': garmentDes,
// //           'is_checked': isChecked.toString(),
// //           'is_checked_crop': isCheckedCrop.toString(),
// //           'denoise_steps': denoiseSteps.toString(),
// //           'seed': seed.toString(),
// //         },
// //       );
// //
// //       if (response.statusCode != 200) {
// //         throw Exception(
// //             'Failed to run try-on. Status: ${response.statusCode}, Body: ${response.body}');
// //       }
// //
// //       print('Try-on completed successfully');
// //     } catch (e) {
// //       print('Error in runTryOn: $e');
// //       throw Exception('Failed to run try-on: $e');
// //     }
// //   }
// //
// //   Future<File> getOutputImage() async {
// //     var response = await http.get(Uri.parse('$baseUrl/get_output_image/'));
// //     if (response.statusCode == 200) {
// //       final Directory tempDir = await getTemporaryDirectory();
// //       final File file = File('${tempDir.path}/output_image.png');
// //       await file.writeAsBytes(response.bodyBytes);
// //       return file;
// //     } else {
// //       throw Exception('Failed to get output image');
// //     }
// //   }
// //
// //   Future<File> getMaskedImage() async {
// //     var response = await http.get(Uri.parse('$baseUrl/get_masked_image/'));
// //     if (response.statusCode == 200) {
// //       final Directory tempDir = await getTemporaryDirectory();
// //       final File file = File('${tempDir.path}/masked_image.png');
// //       await file.writeAsBytes(response.bodyBytes);
// //       return file;
// //     } else {
// //       throw Exception('Failed to get masked image');
// //     }
// //   }
// //
// //   // Future<Uint8List> getOutputImage() async {
// //   //   var response = await http.get(Uri.parse('$baseUrl/get_output_image/'));
// //   //   if (response.statusCode == 200) {
// //   //     return response.bodyBytes;
// //   //   } else {
// //   //     throw Exception('Failed to get output image');
// //   //   }
// //   // }
// //
// //   // Future<Uint8List> getMaskedImage() async {
// //   //   var response = await http.get(Uri.parse('$baseUrl/get_masked_image/'));
// //   //   if (response.statusCode == 200) {
// //   //     return response.bodyBytes;
// //   //   } else {
// //   //     throw Exception('Failed to get masked image');
// //   //   }
// //   // }
// // }
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class TryOnApiClient {
  String? _predictionId;
  String? _outputUrl;

  TryOnApiClient();

  // Future<File?> generateVirtualTryOn(
  //     String humanImage, String garmentImage) async {
  //   const String apiKey = "r8_WztMDsolFmCtNunjVGD7d53ngx96ZOk2aXpye";
  //
  //   if (apiKey.isEmpty) {
  //     print("Error: API key is missing.");
  //     return File("assets/icons/error_upload.jpg");
  //   }
  //
  //   final input = {
  //     "garm_img": garmentImage,
  //     "human_img": humanImage,
  //     "garment_des": ""
  //   };
  //
  //   try {
  //     // Start prediction
  //     final uri = Uri.parse("https://api.replicate.com/v1/predictions");
  //     final response = await http.post(
  //       uri,
  //       headers: {
  //         "Authorization": "Token $apiKey",
  //         "Content-Type": "application/json",
  //       },
  //       body: jsonEncode({
  //         "version":
  //             "c871bb9b046607b680449ecbae55fd8c6d945e0a1948644bf2361b3d021d3ff4",
  //         "input": input,
  //       }),
  //     );
  //
  //     if (response.statusCode != 201 && response.statusCode != 200) {
  //       print("Failed to start prediction: ${response.body}");
  //       return AssetImage("assets/icons/error_upload.jpg");
  //     }
  //
  //     final responseData = jsonDecode(response.body);
  //     final predictionId = responseData['id'];
  //     final getUri = responseData['urls']['get'];
  //     final streamUri = responseData['urls']['stream'];
  //
  //     print("Prediction started. ID: $predictionId");
  //
  //     int attempts = 0;
  //     final maxAttempts = 60;
  //
  //     while (attempts < maxAttempts) {
  //       attempts++;
  //
  //       // Poll the prediction status
  //       final pollResponse = await http.get(Uri.parse(getUri),
  //           headers: {"Authorization": "Token $apiKey"});
  //       if (pollResponse.statusCode == 200) {
  //         final pollData = jsonDecode(pollResponse.body);
  //
  //         if (pollData['status'] == 'succeeded') {
  //           final outputUrl = pollData['output'];
  //           if (outputUrl != null) {
  //             // Download the image
  //             final imageResponse = await http.get(Uri.parse(outputUrl));
  //             if (imageResponse.statusCode == 200) {
  //               final Directory tempDir = await getTemporaryDirectory();
  //               final File file = File('${tempDir.path}/output_image.png');
  //               if (imageResponse.headers['content-type']
  //                       ?.startsWith('image/') ??
  //                   false) {
  //                 await file.writeAsBytes(imageResponse.bodyBytes);
  //                 return file;
  //               } else {
  //                 print("Error: Output is not a valid image.");
  //                 return File("assets/icons/error_upload.jpg");
  //               }
  //             }
  //           }
  //         } else if (pollData['status'] == 'failed') {
  //           print("Prediction failed: ${pollData['error']}");
  //           return File("assets/icons/error_upload.jpg");
  //         }
  //       }
  //
  //       print("Status: ${pollResponse.body}. Retrying in 2 seconds...");
  //       await Future.delayed(Duration(seconds: 2));
  //     }
  //
  //     print("Timed out after $maxAttempts attempts.");
  //     return File("assets/icons/error_upload.jpg");
  //   } catch (e) {
  //     print("Error: $e");
  //     return File("assets/icons/error_upload.jpg");
  //   }
  // }
  Future<File?> generateVirtualTryOn(
      String humanImageUrl, String garmentImageUrl) async {
    const String apiKey = "r8_WztMDsolFmCtNunjVGD7d53ngx96ZOk2aXpye";
    if (apiKey.isEmpty) {
      print("Error: API key is missing.");
      return null;
    }

    final input = {
      "garm_img": garmentImageUrl,
      "human_img": humanImageUrl,
      "garment_des": "" // Optional: description of the garment
    };

    try {
      // Step 1: Start the prediction request
      final uri = Uri.parse("https://api.replicate.com/v1/predictions");
      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Token $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "version":
              "c871bb9b046607b680449ecbae55fd8c6d945e0a1948644bf2361b3d021d3ff4", // Specify the API version
          "input": input,
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        print("Failed to start prediction: ${response.body}");
        return null;
      }

      final responseData = jsonDecode(response.body);
      final predictionId = responseData['id'];
      final getUri = responseData['urls']['get'];

      print("Prediction started. ID: $predictionId");

      // Step 2: Poll for the prediction result
      int attempts = 0;
      const int maxAttempts = 60;

      while (attempts < maxAttempts) {
        attempts++;

        // Poll the prediction status
        final pollResponse = await http.get(
          Uri.parse(getUri),
          headers: {"Authorization": "Token $apiKey"},
        );

        if (pollResponse.statusCode == 200) {
          final pollData = jsonDecode(pollResponse.body);

          // Check the prediction status
          if (pollData['status'] == 'succeeded') {
            final outputUrl = pollData['output'];
            if (outputUrl != null) {
              print(
                  "Prediction succeeded. Downloading output from: $outputUrl");

              // Step 3: Download the output image
              final imageResponse = await http.get(Uri.parse(outputUrl));
              if (imageResponse.statusCode == 200) {
                final Directory tempDir = await getTemporaryDirectory();
                final File outputFile =
                    File('${tempDir.path}/output_image.png');
                await outputFile.writeAsBytes(imageResponse.bodyBytes);
                print("Output image saved at: ${outputFile.path}");
                return outputFile;
              } else {
                print(
                    "Failed to download the output image. Status: ${imageResponse.statusCode}");
                return null;
              }
            }
          } else if (pollData['status'] == 'failed') {
            print("Prediction failed: ${pollData['error']}");
            return null;
          }
        }

        print("Status: ${pollResponse.body}. Retrying in 2 seconds...");
        await Future.delayed(const Duration(seconds: 2));
      }

      print("Timed out after $maxAttempts attempts.");
      return null;
    } catch (e) {
      print("Error in generateVirtualTryOn: $e");
      return null;
    }
  }
}
//   Future<void> uploadImages(File humanImage, String garmentImageUrl) async {
//     try {
//       print('Processing images for virtual try-on');
//
//       // Store the image paths for later use
//       final Directory tempDir = await getTemporaryDirectory();
//       final File tempGarmentImage =
//           File('${tempDir.path}/temp_garment_image.jpg');
//
//       // Download garment image
//       print('Downloading garment image from: $garmentImageUrl');
//       final http.Response garmentResponse =
//           await http.get(Uri.parse(garmentImageUrl));
//
//       if (garmentResponse.statusCode != 200) {
//         throw Exception(
//             'Failed to download garment image. Status: ${garmentResponse.statusCode}');
//       }
//
//       await tempGarmentImage.writeAsBytes(garmentResponse.bodyBytes);
//       print('Garment image downloaded successfully');
//
//       // Upload images to Replicate API
//       print('Preparing images for Replicate API');
//
//       // Convert images to base64 for Replicate API
//       final String humanBase64 = base64Encode(await humanImage.readAsBytes());
//       final String garmentBase64 =
//           base64Encode(await tempGarmentImage.readAsBytes());
//
//       // Store the prediction ID and URLs for later use
//       _predictionId = null;
//       _outputUrl = null;
//
//       await tempGarmentImage.delete();
//       print('Images processed successfully');
//     } catch (e) {
//       print('Error in uploadImages: $e');
//       throw Exception('Failed to upload images: $e');
//     }
//   }
//
//   Future<void> runTryOn(
//       {required String garmentDes,
//       required bool isChecked,
//       required bool isCheckedCrop,
//       required int denoiseSteps,
//       required int seed,
//       required String garmentImageUrl,
//       required String humanImageUrl}) async {
//     try {
//       final input = {
//         "garm_img": garmentImageUrl, // Using the stored garment URL
//         "human_img": humanImageUrl, // Using the stored human image URL
//         "garment_des": "",
//       };
//
//       // Start the prediction
//       final uri = Uri.parse("https://api.replicate.com/v1/predictions");
//       final response = await http.post(
//         uri,
//         headers: {
//           "Authorization": "Token $apiKey",
//           "Content-Type": "application/json",
//         },
//         body: jsonEncode({
//           "version":
//               "c871bb9b046607b680449ecbae55fd8c6d945e0a1948644bf2361b3d021d3ff4",
//           "input": input,
//         }),
//       );
//
//       if (response.statusCode != 201 && response.statusCode != 200) {
//         throw Exception('Failed to start prediction: ${response.body}');
//       }
//
//       final responseData = jsonDecode(response.body);
//       _predictionId = responseData['id'];
//       final getUri = responseData['urls']['get'];
//       final streamUri = responseData['urls']['stream'];
//
//       print("Prediction started. ID: $_predictionId");
//
//       bool isCompleted = false;
//       int attempts = 0;
//       final maxAttempts = 60;
//
//       while (!isCompleted && attempts < maxAttempts) {
//         try {
//           // Check stream endpoint
//           final streamResponse = await http.get(
//             Uri.parse(streamUri),
//             headers: {"Authorization": "Token $apiKey"},
//           );
//
//           if (streamResponse.statusCode == 200) {
//             final contentType = streamResponse.headers['content-type'] ?? '';
//             if (contentType.contains('image')) {
//               _outputUrl = streamUri;
//               isCompleted = true;
//               break;
//             }
//           }
//
//           // Check regular endpoint
//           final pollResponse = await http.get(
//             Uri.parse(getUri),
//             headers: {"Authorization": "Token $apiKey"},
//           );
//
//           if (pollResponse.statusCode == 200) {
//             final pollData = jsonDecode(pollResponse.body);
//             final status = pollData['status'];
//
//             if (status == 'succeeded') {
//               _outputUrl = pollData['output'];
//               if (_outputUrl != null && _outputUrl!.isNotEmpty) {
//                 isCompleted = true;
//                 break;
//               }
//             } else if (status == 'failed') {
//               throw Exception("Prediction failed: ${pollData['error']}");
//             }
//           }
//         } catch (e) {
//           print("Warning: Error during check (attempt $attempts): $e");
//         }
//
//         attempts++;
//         await Future.delayed(Duration(seconds: 2));
//       }
//
//       if (attempts >= maxAttempts) {
//         throw Exception("Timed out after $maxAttempts attempts");
//       }
//
//       print('Try-on completed successfully');
//     } catch (e) {
//       print('Error in runTryOn: $e');
//       throw Exception('Failed to run try-on: $e');
//     }
//   }
//
//   Future<File> getOutputImage() async {
//     if (_outputUrl == null) {
//       throw Exception('No output image available. Run try-on first.');
//     }
//
//     try {
//       final response = await http.get(
//         Uri.parse(_outputUrl!),
//         headers: {"Authorization": "Token $apiKey"},
//       );
//
//       if (response.statusCode == 200) {
//         final Directory tempDir = await getTemporaryDirectory();
//         final File file = File('${tempDir.path}/output_image.png');
//         await file.writeAsBytes(response.bodyBytes);
//         return file;
//       } else {
//         throw Exception('Failed to get output image: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error getting output image: $e');
//       throw Exception('Failed to get output image');
//     }
//   }
// //
// //   Future<File> getMaskedImage() async {
// //     // Since the new API doesn't provide a masked image separately,
// //     // we'll return the same output image for compatibility
// //     return getOutputImage();
// //   }
// // }
// }
