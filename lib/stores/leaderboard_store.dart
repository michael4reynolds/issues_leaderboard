library leaderboard_store;

import 'package:dispatch/dispatch.dart';
import 'package:github/common.dart';
import 'package:issues_leaderboard/actions.dart' as actions;
import 'package:issues_leaderboard/app_dispatcher.dart';
import 'package:issues_leaderboard/stores/issues_store.dart';

class LeaderboardStore extends SingleStore {
  List<Player> players = [];
  List<Position> positions = [];
  
  LeaderboardStore(Dispatch d) : super(d);

  void delegate(action) {
    print(action['message']);
    
    switch (action['message']) {
      case actions.NEW_ISSUE_CLOSED:
        Issue issue = action['data'];
        appDispatcher.dispatch({
          'message': actions.POINTS_AWARDED,
          'data': pointsForIssue(issue)
        });
        break;
        
      case actions.STORE_CHANGE:
        if (action['data'] is IssuesStore) {
          _calculateLeaderboard();
          appDispatcher.dispatch({
            'message': actions.STORE_CHANGE,
            'data': this
          });
        }
        break;
    }
  }
  
  Player _findOrCreateUserPlayer(User user) {
    return players.firstWhere((player) => player.user.id == user.id,
      orElse: () {
        var player = new Player(user);
        players.add(player);
        return player;
      });
  }
  
  _calculateLeaderboard() {
    _calculatePlayers();
    _calculatePositions();
  }
  
  _calculatePlayers() {
    players = [];
    issuesStore.issues.forEach((issue) {
      if (pointsForIssue(issue) > 0) {
        var player = _findOrCreateUserPlayer(issue.assignee);
        player.issues.add(issue);
      }
    });
  }
  
  _calculatePositions() {
    var _players = new List<Player>.from(players);
    _players.sort((a,b) => b.points.compareTo(a.points));

    var rankIndex = 0;
    var lastPoints = -1;
    var lastRank; 
    positions = _players.map((player) {
      rankIndex++;
      var rank = player.points == lastPoints ? lastRank : rankIndex;
      lastRank = rank;
      lastPoints = player.points;
      return new Position(player, rank);
    }).toList();
    positions.sort((a,b) => a.rank.compareTo(b.rank));
  }
}

LeaderboardStore leaderboardStore = new LeaderboardStore(appDispatcher);

class Player {
  final User user;
  List<Issue> issues = [];
  
  Player(this.user);
  
  List<num> get issuePoints => issues.map(pointsForIssue).toList();
  num get points => _sum(issuePoints);
}

num pointsForIssue(Issue issue) {
  return _sum(issue.labels.map(_labelValue).toList());
}

num _labelValue(label) {
  try {
    return int.parse(label.name);
  } on FormatException {
    return 0;
  }
}

class Position {
  final Player player;
  final num rank;
  
  Position(this.player, this.rank);
}

_sum(List<num> numbers) => numbers.fold(0, (sum, number) => sum = sum + number);
