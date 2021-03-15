import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'issuesList.dart';
import 'log.dart';
import 'models/activity.dart';
import 'const.dart';
import 'models/issue.dart';
import 'models/project.dart';
import 'models/space.dart';
import 'provider/credential_info.dart';

const int HTTP_STATUS_OK = 200;

const String RECENT_ACTIVITIES_COUNTS = "40";
const String ISSUES_COUNTS = "40";

class BacklogApiClient {
  final http.Client _client;

  BacklogApiClient() : _client = http.Client();

  Future<String> _get(Uri uri) async {
    final response = await _client.get(uri);
    final responseBody = utf8.decode(response.bodyBytes, allowMalformed: true);
    Log.httpRequest("HTTP GET: " + uri.toString());
    Log.httpResponse(responseBody);
    return responseBody;
  }

  Future<Space> login(String space, String apiKey) async {
    var uri = Uri.https(space, SPACE_INFO, {
      'apiKey': apiKey,
    });

    final response = await _client.get(uri);
    Log.httpRequest("HTTP GET: " + uri.toString());
    final responseBody = utf8.decode(response.bodyBytes, allowMalformed: true);
    Log.httpResponse(responseBody);

    final parsed = jsonDecode(responseBody);
    return Space.fromJson(parsed);
  }

  static List<Activity> _parseActivities(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<Activity>((json) => Activity.fromJson(json)).toList();
  }

  Future<List<Activity>> fetchActivities(BuildContext context) async {
    final credentialInfo = Provider.of<CredentialInfo>(context);
    final apiKey = credentialInfo.apiKey;
    final space = credentialInfo.space!;
    var url = Uri.https(space, SPACE_ACTIVITIES,
        {'apiKey': apiKey, 'count': RECENT_ACTIVITIES_COUNTS});

    final responseBody = await _get(url);
    return compute(_parseActivities, responseBody);
  }

  static List<Project> _parseProjects(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<Project>((json) => Project.fromJson(json)).toList();
  }

  Future<List<Project>> fetchProjects(BuildContext context) async {
    final credentialInfo = Provider.of<CredentialInfo>(context);
    final apiKey = credentialInfo.apiKey;
    final space = credentialInfo.space!;
    var url = Uri.https(space, PROJECTS, {
      'apiKey': apiKey,
      'archived': false.toString(),
    });

    final responseBody = await _get(url);
    return compute(_parseProjects, responseBody);
  }

  static List<Issue> _parseIssues(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<Issue>((json) => Issue.fromJson(json)).toList();
  }

  Future<List<Issue>> fetchIssues({
    required BuildContext context,
    required Project? project,
    IssueField? sort,
  }) async {
    final credentialInfo = Provider.of<CredentialInfo>(context);
    final apiKey = credentialInfo.apiKey;
    final space = credentialInfo.space!;
    final query = Map<String, dynamic>();
    query['apiKey'] = apiKey;
    query['count'] = ISSUES_COUNTS;
    if (project != null) {
      query['projectId[]'] = project.id.toString();
    }
    if (sort != null) {
      query['sort'] = IssueFieldEnumHelper().name(sort);
    }

    var url = Uri.https(space, ISSUES, query);

    final responseBody = await _get(url);
    return compute(_parseIssues, responseBody);
  }

  Future<int> fetchIssueCount({
    required BuildContext context,
    required Project? project,
    IssueField? sort,
  }) async {
    final credentialInfo = Provider.of<CredentialInfo>(context);
    final apiKey = credentialInfo.apiKey;
    final space = credentialInfo.space!;
    final query = Map<String, dynamic>();
    // TODO fetchIssuesのリクエスト生成処理（クエリー）などを共通化
    query['apiKey'] = apiKey;
    if (project != null) {
      query['projectId[]'] = project.id.toString();
    }
    if (sort != null) {
      query['sort'] = IssueFieldEnumHelper().name(sort);
    }

    var url = Uri.https(space, ISSUES_COUNT, query);

    final responseBody = await _get(url);
    final parsed = jsonDecode(responseBody);
    return parsed['count'];
  }

}
