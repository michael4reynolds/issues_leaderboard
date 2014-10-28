library leaderboard;

import 'package:dispatch/dispatch.dart';
import 'package:github/common.dart';
import 'package:react/react.dart' as react;
import 'package:issues_leaderboard/actions.dart' as actions;
import 'package:issues_leaderboard/components/avatar.dart';
import 'package:issues_leaderboard/stores/leaderboard_store.dart';
import 'package:issues_leaderboard/util/react/css_transition_group.dart';

class _Leaderboard extends react.Component {
  static const NUMBER_OF_POSITIONS_TO_SHOW = 7;
  
  getInitialState() => {'positions': []};
  
  DispatchWatcher _watcher;
  componentWillMount() {
    _watcher = _dispatcher.watch((action) {
      switch (action['message']) {
        case actions.STORE_CHANGE:
          if (action['data'] is LeaderboardStore)
            setState({'positions': leaderboardStore.positions});
          break;
      }
    });
  }
  
  componentWillUnmount() {
    _watcher.destroy();
  }
  
  render() {
    return react.div({'className': 'leaderboard'}, [
      _renderTitle(),
      CSSTransitionGroup({'transitionName': 'player', 'key': 'players'},
        _renderPositions())
    ]);
  }
  
  _renderTitle() {
    return react.table({'key': 'title'}, [
      react.tr({}, [
        react.td({'key': 'gun1'}, react.img({'src': '/images/gun.png', 'className': 'gun gun-1'})),
        react.td({'key': 'title'}, react.h1({'key': 'title'}, 'OrgSync Bug Shootout')),
        react.td({'key': 'gun2'}, react.img({'src': '/images/gun.png', 'className': 'gun gun-2'}))
      ])
    ]);
  }
  
  _renderPositions() {
    return _positions.take(NUMBER_OF_POSITIONS_TO_SHOW)
      .map((position) {
        return react.table({'key': position.player.user.id},  
          react.tr({}, [
            react.td({'key': 'rank', 'className': 'rank-cell'},
              position.rank),
            react.td({'key': 'avatar', 'className': 'avatar-cell'},
              Avatar({'position': position})),
            react.td({'key': 'points', 'className': 'points-cell'},
              CSSTransitionGroup({'transitionName': 'point'},
                _renderIssues(position.player.issues))),
            react.td({'key': 'total', 'className': 'total-cell'},
              '${position.player.points} ${position.player.points == 1 ? 'point' : 'points'}')
          ])
        );
      });
  }

  _renderIssues(List<Issue> issues) {
    var key = 0;
    return issues.map((issue) {
      var rotation = issue.number % 9 - 4;
      var style = {
        'background-color': _colorForIssue(issue),
        'transform': 'rotate(${rotation}deg)'
      };
      return react.div({'key': key++, 'className': 'point', 'style': style}, [
        react.div({'key': 'tint', 'className': 'tint'}),
        react.span({'key': 'points'}, pointsForIssue(issue))
      ]);
    });
  }
  
  Dispatch get _dispatcher => props['dispatcher'];
  
  List<Position> get _positions => state['positions'];
}

String _colorForIssue(Issue issue) {
  var points = pointsForIssue(issue);
  var label = issue.labels.firstWhere((label) => label.name == points.toString());
  return label != null ? '#${label.color}' : 'rgb(88, 51, 27)';
}

var Leaderboard = react.registerComponent(() => new _Leaderboard());
