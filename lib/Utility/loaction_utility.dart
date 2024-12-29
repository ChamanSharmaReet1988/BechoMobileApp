class LocationUtility {
  static double? latitude;
  static double? longitude;
  static String? address;

  static void setLocation(double lat, double lng, String address) {
    latitude = lat;
    longitude = lng;
    address = address;
  }
}