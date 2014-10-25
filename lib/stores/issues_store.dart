library issues_store;

import 'package:dispatch/dispatch.dart';
import 'package:github/common.dart';
import 'package:issues_leaderboard/actions.dart' as actions;
import 'package:issues_leaderboard/app_dispatcher.dart';
import 'dart:async';

class IssuesStore extends SingleStore {
  List<Issue> issues = [];
  bool firstLoad = true;

  IssuesStore(Dispatch d) : super(d);
  
  void delegate(message) {
    switch (message['message']) {
      case actions.LOAD_ISSUES:
        _loadIssues(message['data']);
        break;
    }
  }
  
  _loadIssues(List<Issue> issuesToCompare) {
    var assignedIssues = issuesToCompare.where((issue) => issue.assignee != null);
    // first load
    if (firstLoad) {
      issues = assignedIssues.toList();
      firstLoad = false;
    }
    
    // update existing issues
    issues = assignedIssues.where(issueExists).toList();
    appDispatcher.dispatch({
      'message': actions.STORE_CHANGE,
      'data': this
    });

    // add new issues
    var index = 0;
    assignedIssues.where((issue) => !issueExists(issue))
      .forEach((newIssue) {
        new Timer(new Duration(seconds: 4 * index++), () {
          issues.add(newIssue);
          appDispatcher.dispatch({
            'message': actions.STORE_CHANGE,
            'data': this
          });
          appDispatcher.dispatch({
            'message': actions.NEW_ISSUE_CLOSED,
            'data': newIssue
          });
        });
      });
  }

  bool issueExists(Issue issue) => issues.any((i) => i.number == issue.number);
}

IssuesStore issuesStore = new IssuesStore(appDispatcher);
