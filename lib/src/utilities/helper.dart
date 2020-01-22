class Helper {
  static String stringJoiner(List<String> list, String delimiter) {
    String string = "";
    list.forEach((name) {
      string += name + delimiter;
    });
    string = string.substring(0, string.length - 1);
    return string;
  }
}
