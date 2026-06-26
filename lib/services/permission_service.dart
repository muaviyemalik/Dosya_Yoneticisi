import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Depolama iznini isteyen ve sonucu döndüren fonksiyon
  static Future<bool> depolamaIzniniIste() async {
    // Android 11 ve üzeri cihazlar için tüm dosyaları yönetme izni durumu
    var status = await Permission.manageExternalStorage.status;
    
    if (!status.isGranted) {
      // Eğer izin henüz verilmemişse, sistemden talep et
      status = await Permission.manageExternalStorage.request();
    }

    // Daha eski Android sürümleri (Android 10 ve altı) için klasik depolama izni (Fallback)
    if (!status.isGranted) {
      var eskiSurumStatus = await Permission.storage.request();
      return eskiSurumStatus.isGranted;
    }

    return status.isGranted;
  }
}