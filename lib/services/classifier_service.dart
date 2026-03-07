import 'package:tflite_v2/tflite_v2.dart';

class ClassifierService {
  static Future<void> loadModel() async {
    await Tflite.loadModel(
      model: "assets/waste_wise_model.tflite",
      labels: "assets/labels.txt",
    );
  }

  static Future<Map<String, dynamic>?> predict(String imagePath) async {
    var recognitions = await Tflite.runModelOnImage(
      path: imagePath,
      numResults: 1,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    if (recognitions != null && recognitions.isNotEmpty) {
      return {
        "label": recognitions[0]["label"],
        "confidence": recognitions[0]["confidence"],
      };
    }
    return null;
  }

  static void dispose() {
    Tflite.close();
  }
}
