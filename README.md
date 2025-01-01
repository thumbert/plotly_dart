Expose [Plotly JS](https://plotly.com/javascript/) to Dart.

Make use of the new [`package:web`](https://pub.dev/packages/web)
to interop with JS and the DOM.

This is a pure Dart implementation, won't work with Flutter. 

## Running and building

To run the example,
activate and use [`package:webdev`](https://dart.dev/tools/webdev):

```
dart pub global activate webdev
webdev serve
```

![alt text](plotly_example_1.png "Example")

Look at the code example to get a sense for what is possible.  Not all functionality has been made available.  If there is something in Plotly JS that is not available in Dart, please submit a PR. 

It can be as simple as 
```dart
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
    'hovermode': 'closest',
    'height': 500, 'width': 700,
  };

  // gets added to the html document body element 
  var plot = Plotly(divId: 'line-and-scatter', traces: traces, layout: layout);
  plot.downloadImage(filename: 'line_and_scatter.png', width: 700, height: 500);
```
