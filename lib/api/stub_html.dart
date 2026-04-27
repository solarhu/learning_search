class Range {
  @override
  String toString() => '';
}

class Selection {
  int rangeCount = 0;
  Range getRangeAt(int index) => Range();
  @override
  String toString() => '';
}

class Window {
  Selection? getSelection() => null;
}

final window = Window();