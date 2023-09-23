# widget_tools

A set of useful widget tools that are missing from the flutter framework.

## [ListenableBuilder]

The [ListenableBuilder] widget allows for grouping of multiple slivers together such that they can be returned as a single widget.
For instance when one wants to wrap a few slivers with some padding or an inherited widget.


### Example
```dart
class TestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final focusNode = FocusNode();
    return ListenableBuilder(
        listenable: focusNode,  // required
        builder: (context, focusNode, child) { // required
            return ElevatedButton(
                onPressed: () {
                    print('submitted');
                },
                child: Text('Submit'),
            );
        },
    );
  }
}
```
