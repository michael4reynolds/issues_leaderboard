library github_api_client;

import 'dart:async';
import 'package:github/browser.dart' ;

class GithubApiClient extends GitHub {
  ExtendedIssuesService _issues;
  
  GithubApiClient(String token) : super(auth: new Authentication.withToken(token));
  
  ExtendedIssuesService get issues {
    if (_issues == null) {
      _issues = new ExtendedIssuesService(this, this);
    }
    return _issues;
  }
}

class ExtendedIssuesService extends IssuesService {
  GithubApiClient _github;
  
  ExtendedIssuesService(GithubApiClient this._github, GithubApiClient github) : super(github);
  
  // Adds additional parameters for querying
  @override
  Stream<Issue> listByRepo(RepositorySlug slug, {String state: "open",
      List<String> labels, DateTime closedSince}) {
    var params = {"state": state};
    
    if (labels != null) params['labels'] = labels.join(',');
    if (closedSince != null) params['since']  = dateToGithubIso8601(closedSince);
    
    return new PaginationHelper(_github)
      .objects("GET", "/repos/${slug.fullName}/issues", buildIssue, params: params)
      .where(_filterClosedAt(closedSince));
  }
  
  _filterClosedAt(DateTime since) {
    return (Issue issue) => since == null || issue.closedAt.isAfter(since);
  }
}

Issue buildIssue(input) {
  if (input == null) return null;
  
  return new Issue()
    ..url = input['url']
    ..htmlUrl = input['html_url']
    ..number = input['number']
    ..state = input['state']
    ..title = input['title']
    ..user = User.fromJSON(input['user'])
    // labels assignment was broken in default Issue.fromJSON
    ..labels = input['labels'].map((label) => IssueLabel.fromJSON(label)).toList()
    ..assignee = User.fromJSON(input['assignee'])
    ..milestone = Milestone.fromJSON(input['milestone'])
    ..commentsCount = input['comments']
    ..pullRequest = IssuePullRequest.fromJSON(input['pull_request'])
    ..createdAt = parseDateTime(input['created_at'])
    ..updatedAt = parseDateTime(input['updated_at'])
    ..closedAt = parseDateTime(input['closed_at'])
    ..closedBy = User.fromJSON(input['closed_by'])
    ..body = input['body'];
}

GithubApiClient createGithubApiClient(token) {
  initGitHub();
  return new GithubApiClient(token);   
}
