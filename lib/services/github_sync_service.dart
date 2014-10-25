library github_sync_service;

import 'package:github/common.dart';
import 'package:issues_leaderboard/services/github_api_client.dart';
import 'package:issues_leaderboard/actions.dart' as actions;
import 'package:issues_leaderboard/app_dispatcher.dart';
import 'dart:async';

class GithubSyncService {
  static const POLL_INTERVAL = 60; // in seconds
  
  final String token;
  final String owner;
  final String repoName;
  final DateTime rangeStart;
  final String labelName;
  GithubApiClient github;
  RepositorySlug slug;
  
  GithubSyncService(this.token, this.owner, this.repoName, {this.rangeStart, this.labelName}) {
    github = createGithubApiClient(token);
    slug   = new RepositorySlug(owner, repoName);
  }

  scheduleNextSync() {
    new Timer(new Duration(seconds: POLL_INTERVAL), _syncIssues);
  }

  start() {
    _syncIssues();
  }

  _syncIssues() {
    github.issues.listByRepo(slug, state: 'closed', labels: [labelName], closedSince: rangeStart)
      .toList()
      .then((issues) {
        appDispatcher.dispatch({
          'message': actions.LOAD_ISSUES,
          'data': issues
        });
      })
      .then((_) => scheduleNextSync());
  }
}
