import 'dart:js';

CSSTransitionGroup(Map props, children) {
  var _addons = context['React']['addons'];
  
  return _addons.callMethod('CSSTransitionGroup',
    [new JsObject.jsify(props), new JsObject.jsify(children)]);
}
