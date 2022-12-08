class Chain {
  static const String MAIN = "main";
  static const String TEST = "test";
}

class BroadcastResult {
  late bool propagated;
  late String msg;

  BroadcastResult(this.propagated, this.msg);
}