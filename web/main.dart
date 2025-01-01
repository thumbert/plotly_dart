import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:math';

import 'package:web/web.dart' as web;
import 'package:plotly_dart/plotly_dart.dart';

/// Example 1
void lineAndScatter() {
  const traces = [
    {
      'x': [1, 2, 3, 4],
      'y': [10, 15, 13, 17],
      'mode': 'markers'
    },
    {
      'x': [2, 3, 4, 5],
      'y': [16, 5, 11, 10],
      'mode': 'lines'
    },
    {
      'x': [1, 2, 3, 4],
      'y': [12, 9, 15, 12],
      'mode': 'lines+markers'
    }
  ];

  const layout = {
    'title': 'Line and Scatter Plot',
    'hovermode': 'closest', // this is needed to select the points
    'height': 500, 'width': 700,
  };

  final message = 'Move the mouse over a data point to see a message:';

  web.document.body!.append(web.HTMLHeadingElement.h3()..text = 'Example 1');
  var messageDiv = web.HTMLDivElement()..text = message;
  var extraDiv = web.HTMLDivElement()..text = 'None';
  extraDiv.style.color = 'blue';
  web.document.body!.append(messageDiv);
  web.document.body!.append(extraDiv);

  var plot = Plotly(divId: 'line-and-scatter', traces: traces, layout: layout);
  plot.onHover((JSObject data) {
    var points = (data.getProperty('points'.toJS) as JSArray).toDart;
    var pointNumber =
        ((points[0] as JSObject).getProperty('pointNumber'.toJS) as JSNumber)
            .toDartInt;
    var traceNumber =
        ((points[0] as JSObject).getProperty('curveNumber'.toJS) as JSNumber)
            .toDartInt;
    extraDiv.text = 'Hovering over point $pointNumber of trace $traceNumber';
    extraDiv.style.color = 'blue';
  });
  plot.onUnhover((JSObject data) {
    extraDiv.text = 'None';
  });

  // download the chart in the folder your browser downloads files
  // plot.downloadImage(filename: 'line_and_scatter.png', width: 700, height: 500);
}

/// Example 2
void plotInteractions() {
  final random = Random(10);
  late var traces = <Map<String, dynamic>>[];

  void addSeries() {
    var epsilon = List.generate(8760, (i) => random.nextDouble() - 0.5);
    var current = 0.0;
    traces.add({
      'x': List.generate(8760, (i) => i),
      'y': epsilon.map((e) {
        current += e;
        return current;
      }),
      'mode': 'lines',
      'name': 'series${traces.length}',
    });
  }

  addSeries();
  addSeries();
  final layout = {'title': 'TimeSeries Plot', 'height': 650, 'width': 800};
  bool showHighlights = true;

  web.document.body!.append(web.HTMLHeadingElement.h3()..text = 'Example 2');
  var messageDiv = web.HTMLDivElement()
    ..text = 'Show various interactions with plot.  Select area on plot!';
  web.document.body!.append(messageDiv);

  var addSeriesButton = web.HTMLButtonElement()
    ..text = 'Add'
    ..title = 'Add a series';
  var deleteSeriesButton = web.HTMLButtonElement()
    ..text = 'Delete'
    ..title = 'Delete last series';
  var relayoutButton = web.HTMLButtonElement()..text = 'Relayout';
  var extendSeriesButton = web.HTMLButtonElement()
    ..text = 'Extend'
    ..title = 'Extend first series';

  var buttonGroup = web.HTMLDivElement()..className = 'btn-group';
  buttonGroup.appendChild(addSeriesButton);
  buttonGroup.appendChild(deleteSeriesButton);
  buttonGroup.appendChild(relayoutButton);
  buttonGroup.appendChild(extendSeriesButton);
  web.document.body!.append(buttonGroup);

  var plot = Plotly(divId: 'timeseries', traces: traces, layout: layout);
  var relayoutMessageDiv = web.HTMLDivElement()..text = 'Nothing selected';
  web.document.body!.append(relayoutMessageDiv);

  plot.onRelayout((JSObject data) {
    if (data.hasProperty('xaxis.range[0]'.toJS).toDart) {
      var x0 =
          (data.getProperty('xaxis.range[0]'.toJS) as JSNumber).toDartDouble;
      var x1 =
          (data.getProperty('xaxis.range[1]'.toJS) as JSNumber).toDartDouble;
      print((x0, x1));
      relayoutMessageDiv.text =
          'Selected xaxis from: (${x0.toStringAsFixed(2)}, ${x1.toStringAsFixed(2)})';
    } else {
      relayoutMessageDiv.text = 'Nothing selected';
    }
  });
  // add buttons
  addSeriesButton.onclick = ((JSAny? e) {
    addSeries();
    plot.addTraces([traces.last], [traces.length - 1]);
  }).toJS;
  deleteSeriesButton.onclick = ((JSAny? e) {
    plot.deleteTraces([traces.length - 1]);
    traces.removeAt(traces.length - 1);
  }).toJS;
  relayoutButton.onclick = ((JSAny? e) {
    if (showHighlights) {
      layout['shapes'] = [
        {
          'type': 'rect',
          'xref': 'x',
          'yref': 'paper',
          'x0': 720,
          'y0': 0,
          'x1': 2150,
          'y1': 1,
          'fillcolor': '#800000',
          'opacity': 0.2,
          'line': {
            'width': 0,
          }
        },
        {
          'type': 'rect',
          'xref': 'x',
          'yref': 'paper',
          'x0': 5120,
          'y0': 0,
          'x1': 6350,
          'y1': 1,
          'fillcolor': '#800000',
          'opacity': 0.2,
          'line': {
            'width': 0,
          }
        },
      ];
    } else {
      layout['shapes'] = [];
    }
    plot.relayout(layout);
    showHighlights = showHighlights ? false : true;
  }).toJS;
  extendSeriesButton.onclick = ((JSAny? e) {
    // the data property contains the traces
    var data = (plot.proxy.getProperty('data'.toJS) as JSArray).toDart;
    // get the 'y' of the first trace  
    var y = ((data[0] as JSObject).getProperty('y'.toJS) as JSArray).toDart;
    var n = y.length;
    // append 2000 hours of observations to the end of the series
    var epsilon = List.generate(2000, (i) => random.nextDouble() - 0.5);
    var current = y.last as num;
    var ext = {
      'x': [List.generate(2000, (i) => n + i)],
      'y': [
        epsilon.map((e) {
          current += e;
          return current;
        }).toList()
      ],
    };
    plot.extendTraces(ext, [0], n + 2000);
  }).toJS;
}

void main() {
  lineAndScatter();
  plotInteractions();

  /// You can add a general event to the window.  Below, you print
  /// something to the console every time you click in the window.
  // web.window.onclick = ((JSAny? e) => print('you clicked!')).toJS;
}
