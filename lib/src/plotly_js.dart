@JS()
library plotly.js;

import 'dart:js_interop';
import 'package:web/web.dart' as web;

enum DisplayModeBar {
  hover,
  no,
  yes,
}

// class FlagList {
//   FlagList(this.values) {
//     value = values.join('+');
//   }
//   final List<String> values;

//   late dynamic value;
// }

/// So many of them, only a few implemented now.  Will have to add more later
/// if needed.
///
class PlotlyOptions {
  /// See https://github.com/plotly/plotly.js/blob/master/src/plot_api/plot_config.js
  PlotlyOptions({
    bool? displaylogo,
    DisplayModeBar? displayModeBar,
    bool? editable,
    bool? responsive,
    dynamic scrollZoom,
    bool? showLink,
    bool? staticPlot,
  }) {
    this.displaylogo = displaylogo ?? false;
    this.displayModeBar = displayModeBar ?? DisplayModeBar.hover;
    this.editable = editable ?? false;
    this.responsive = responsive ?? false;
    this.scrollZoom = scrollZoom ?? 'gl3d+geo+map';
    this.showLink = showLink ?? false;
    this.staticPlot = staticPlot ?? false;
  }

  late final bool displaylogo;
  late final DisplayModeBar displayModeBar;
  late final bool editable;
  late final bool responsive;
  late final dynamic scrollZoom;
  late final bool showLink;
  late final bool staticPlot;

  ///
  JSObject get toJS {
    return {
      'displaylogo': displaylogo,
      if (displayModeBar != DisplayModeBar.hover)
        'displayModeBar': true, // fix me
      if (!editable) 'editable': editable,
      if (!responsive) 'responsive': responsive,
      if (scrollZoom != 'gl3d+geo+map') 'scrollZoom': scrollZoom,
      if (!showLink) 'showLink': showLink,
      if (!staticPlot) 'staticPlot': staticPlot,
    }.jsify() as JSObject;
  }
}

class Plotly {
  Plotly({
    required this.divId,
    required this.traces,
    required this.layout,
    PlotlyOptions? options,
  }) {
    this.options = options ?? PlotlyOptions();

    chartDiv = web.HTMLDivElement()..id = divId;
    web.document.body!.append(chartDiv);
    proxy = chartDiv as PlotlyExt;

    // create the new plot
    PlotlyExt.newPlot(chartDiv, traces.jsify() as JSObject,
        layout.jsify() as JSObject, this.options.toJS);
  }

  final String divId;
  final List<Map<String, dynamic>> traces;
  final Map<String, dynamic> layout;
  late final PlotlyOptions options;

  /// The actual Plotly JavaScript object
  late final PlotlyExt proxy;

  /// Where the chart will be embedded
  late final web.HTMLDivElement chartDiv;

  /// Add new traces at the [positionIndices] positions.
  void addTraces(List<Map<String, dynamic>> traces, List<int> positionIndices) {
    PlotlyExt.addTraces(chartDiv, traces.jsify() as JSObject,
        positionIndices.jsify() as JSArray);
  }

  /// Delete the traces at this [index]
  void deleteTraces(List<int> positionIndices) {
    PlotlyExt.deleteTraces(chartDiv, positionIndices.jsify() as JSArray);
  }

  /// See https://github.com/plotly/plotly.js/blob/master/src/plot_api/to_image.js
  /// The [format] can be one of ```'png', 'jpeg', 'webp', 'svg', 'full-json'```.
  void downloadImage(
      {required String filename,
      required int width,
      required int height,
      String format = 'png',
      num scale = 1,
      bool imageDataOnly = false,
      bool setBackground = false}) {
    var options = {
      'filename': filename,
      'width': width,
      'height': height,
      if (format != 'png') 'format': format,
      if (scale != 1) 'scale': scale,
      if (!imageDataOnly) 'imageDataOnly': imageDataOnly,
      if (!setBackground) 'setBackground': setBackground,
    };
    PlotlyExt.downloadImage(chartDiv, options.jsify() as JSObject);
  }

  /// Extend existing traces at the [positionIndices] positions.
  void extendTraces(
      Map<String, dynamic> update, List<int> positionIndices, int maxPoints) {
    PlotlyExt.extendTraces(chartDiv, update.jsify() as JSObject,
        positionIndices.jsify() as JSArray, maxPoints.toJS);
  }

  /// Delete the traces at this [index]
  void moveTraces(List<int> currentIndices, List<int> newIndices) {
    PlotlyExt.moveTraces(chartDiv, currentIndices.jsify() as JSArray,
        newIndices.jsify() as JSArray);
  }

  /// Add values at the beginning of the trace for trace at [positionIndices].
  void prependTraces(
      Map<String, dynamic> update, List<int> positionIndices, int maxPoints) {
    PlotlyExt.prependTraces(chartDiv, update.jsify() as JSObject,
        positionIndices.jsify() as JSArray, maxPoints.toJS);
  }

  /// For example:
  /// ```
  ///   f = (JSAny? e) => print('Hi!'));
  /// ```
  void onClick(void Function(JSObject) f) {
    proxy.on('plotly_click'.toJS, f.toJS);
  }

  void onHover(void Function(JSObject) f) {
    proxy.on('plotly_hover'.toJS, f.toJS);
  }

  void onRelayout(void Function(JSObject) f) {
    proxy.on('plotly_relayout'.toJS, f.toJS);
  }

  void onUnhover(void Function(JSObject) f) {
    proxy.on('plotly_unhover'.toJS, f.toJS);
  }

  /// After the plot is made, use this method to update it as it will be
  /// much faster than recreating the plot.
  void react() {}

  /// An efficient way of updating just the layout of a plot.
  void relayout(Map<String, dynamic> object) {
    PlotlyExt.relayout(chartDiv, object.jsify() as JSObject);
  }

  /// An efficient means of changing parameters in the data array. When
  /// restyling, you may choose to have the specified changes effect as
  /// many traces as desired. The update is given as a single [Map] and
  /// the traces that are effected are given as a list of traces indices.
  void restyle(Map<String, dynamic> object, List<int> traceIndex) {
    PlotlyExt.restyle(
        chartDiv, object.jsify() as JSObject, traceIndex.jsify() as JSArray);
  }

  void redraw(void Function() f) {
    proxy.on('plotly_redraw'.toJS, f.toJS);
  }

  /// An efficient means of updating both the data array and layout object in
  /// an existing plot, basically a combination of Plotly.restyle and Plotly.relayout.
  void update(Map<String, dynamic> dataUpdate,
      Map<String, dynamic> layoutUpdate, List<int> traceIndices) {
    PlotlyExt.update(chartDiv, dataUpdate.jsify() as JSObject,
        layoutUpdate.jsify() as JSObject, traceIndices.jsify() as JSArray);
  }
}

/// See the corresponding JS API implementation here:
/// https://github.com/plotly/plotly.js/blob/master/src/plot_api/plot_api.js
@JS('Plotly')
extension type PlotlyExt(JSObject _) implements JSObject {
  external static void newPlot(
      web.HTMLElement gd, JSObject traces, JSObject layout, JSObject config);

  /// Add new traces at the [positionIndices] positions.
  external static void addTraces(
      web.HTMLElement gd, JSObject newTraces, JSArray positionIndices);

  /// Add new traces at the [positionIndices] positions.
  external static void deleteTraces(
      web.HTMLElement gd, JSArray positionIndices);

  ///
  external static void downloadImage(web.HTMLElement gd, JSObject options);

  external static void extendTraces(web.HTMLElement gd, JSObject dataUpdate,
      JSArray positionIndices, JSNumber maxPoints);

  external static void moveTraces(
      web.HTMLElement gd, JSArray currentIndices, JSArray newIndices);

  external static void prependTraces(web.HTMLElement gd, JSObject dataUpdate,
      JSArray positionIndices, JSNumber maxPoints);

  external void on(JSString name, JSFunction f);

  external static void relayout(web.HTMLElement gd, JSObject data);

  external static void restyle(
      web.HTMLElement gd, JSObject data, JSArray traceIndex);

  external static void update(
      web.HTMLElement gd, JSObject data, JSObject layout, JSArray traceIndices);
}
