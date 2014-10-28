library avatar;

import 'package:react/react.dart' as react;
import 'package:issues_leaderboard/stores/leaderboard_store.dart';

class _Avatar extends react.Component {
  render() {
    var children = [react.img({'src': position.player.user.avatarUrl})];
    
    if (position.rank == 1)
      children.add(react.img({'key': 'sheriff', 'src': '/images/sheriff.png', 'className': 'sheriff'}));
    if (position.isTied)
      children.add(react.div({'key': 'duel', 'className': 'deul'}, 'Duel'));
    
    return react.div({'className': 'avatar'}, children);
  }
  
  Position get position => props['position'];
}

var Avatar = react.registerComponent(() => new _Avatar());
