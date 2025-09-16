/// CameraService: captura simulada de imágenes.
library;

class CameraService {
  Future<List<int>> takePictureBytes() async {
    // TODO: Integrar con camera o image_picker.
    return List<int>.filled(10, 0);
  }
}
