// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

// Assuming that the test container is 800x600. The height of the
// viewport's contents is 650.0, the top and bottom text children
// are 100 pixels high and top/left edge of both widgets are visible.
// The top of the bottom widget is at 550 (the top of the top widget
// is at 0). The top of the bottom widget is 500 when it has been
// scrolled completely into view.
Widget buildFrame(ScrollableEdge clampedEdge) {
  return new ClampOverscrolls(
    edge: clampedEdge,
    child: new ScrollableViewport(
      scrollableKey: new UniqueKey(),
      child: new SizedBox(
        height: 650.0,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new SizedBox(height: 100.0, child: new Text('top')),
            new Flexible(child: new Container()),
            new SizedBox(height: 100.0, child: new Text('bottom')),
          ]
        )
      )
    )
  );
}

void main() {
  testWidgets('ClampOverscrolls', (WidgetTester tester) async {

    // Scroll the target text widget by offset and then return its origin
    // in global coordinates.
    Future<Point> locationAfterScroll(String target, Offset offset) async {
      await tester.scrollAt(tester.getTopLeft(find.text(target)), offset);
      await tester.pump();
      final RenderBox textBox = tester.renderObject(find.text(target));
      final Point widgetOrigin = textBox.localToGlobal(Point.origin);
      await tester.pump(const Duration(seconds: 1)); // Allow overscroll to settle
      return new Future<Point>.value(widgetOrigin);
    }

    await tester.pumpWidget(buildFrame(ScrollableEdge.none));
    Point origin = await locationAfterScroll('top', const Offset(0.0, 400.0));
    expect(origin.y, greaterThan(0.0));
    origin = await locationAfterScroll('bottom', const Offset(0.0, -400.0));
    expect(origin.y, lessThan(500.0));


    await tester.pumpWidget(buildFrame(ScrollableEdge.both));
    origin = await locationAfterScroll('top', const Offset(0.0, 400.0));
    expect(origin.y, equals(0.0));
    origin = await locationAfterScroll('bottom', const Offset(0.0, -400.0));
    expect(origin.y, equals(500.0));

    await tester.pumpWidget(buildFrame(ScrollableEdge.leading));
    origin = await locationAfterScroll('top', const Offset(0.0, 400.0));
    expect(origin.y, equals(0.0));
    origin = await locationAfterScroll('bottom', const Offset(0.0, -400.0));
    expect(origin.y, lessThan(500.0));

    await tester.pumpWidget(buildFrame(ScrollableEdge.trailing));
    origin = await locationAfterScroll('top', const Offset(0.0, 400.0));
    expect(origin.y, greaterThan(0.0));
    origin = await locationAfterScroll('bottom', const Offset(0.0, -400.0));
    expect(origin.y, equals(500.0));
  });
}
