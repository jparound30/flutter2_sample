import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'backlog_api.dart';
import 'models/issue.dart';
import 'models/project.dart';
import 'provider/credential_info.dart';
import 'provider/selected_project.dart';

/// 課題のフィールド列挙型（ソートキー用）
enum IssueField {
  /// 種類
  issueType,

  /// カテゴリー
  category,

  /// 発生バージョン
  version,

  /// マイルストーン
  milestone,

  /// 要約
  summary,

  /// 状態
  status,

  /// 優先度
  priority,

  /// 添付ファイル
  attachment,

  /// 共有ファイル
  sharedFile,

  /// 作成日時
  created,

  /// 作成者
  createdUser,

  /// 更新日時
  updated,

  /// 更新者
  updatedUser,

  /// 担当者
  assignee,

  /// 開始日
  startDate,

  /// 期限日
  dueDate,

  /// 予定時間
  estimatedHours,

  /// 実績時間
  actualHours,

  /// 子課題
  childIssue,
  // customField_${id},
}

abstract class EnumHelper<T> {
  List<T> values();

  Map<T, String> maps();

  T valueOf(String value) {
    return values().firstWhere((e) => name(e) == value,
        orElse: () => throw new Exception("INVALID ENUM"));
  }

  String name(T value) {
    return value.toString().split('.').last;
  }

  String description(T value) {
    return maps()[value]!;
  }
}

class IssueFieldEnumHelper extends EnumHelper<IssueField> {
  @override
  List<IssueField> values() => IssueField.values;

  @override
  Map<IssueField, String> maps() {
    final ret = Map<IssueField, String>();
    ret[IssueField.issueType] = "種類";
    ret[IssueField.category] = "カテゴリー";
    ret[IssueField.version] = "発生バージョン";
    ret[IssueField.milestone] = "マイルストーン";
    ret[IssueField.summary] = "要約";
    ret[IssueField.status] = "状態";
    ret[IssueField.priority] = "優先度";
    ret[IssueField.attachment] = "添付ファイル";
    ret[IssueField.sharedFile] = "共有ファイル";
    ret[IssueField.created] = "作成日時";
    ret[IssueField.createdUser] = "作成者";
    ret[IssueField.updated] = "更新日時";
    ret[IssueField.updatedUser] = "更新者";
    ret[IssueField.assignee] = "担当者";
    ret[IssueField.startDate] = "開始日";
    ret[IssueField.dueDate] = "期限日";
    ret[IssueField.estimatedHours] = "予定時間";
    ret[IssueField.actualHours] = "実績時間";
    ret[IssueField.childIssue] = "子課題";
    return ret;
  }
}

class IssueList extends StatelessWidget {
  IssueList({Key? key}) : super(key: key);
  final backlogApiClient = BacklogApiClient();

  @override
  Widget build(BuildContext context) {
    final selectedProject = Provider.of<SelectedProject>(context, listen: true);
    if (selectedProject.project == null) {
      return Center(child: Text("プロジェクトを選択してください"));
    }
    return IssueListView();
  }
}

class IssueListView extends StatefulWidget {
  final IssueFieldEnumHelper _issueFieldEnumHelper = IssueFieldEnumHelper();
  final backlogApiClient = BacklogApiClient();

  IssueListView({Key? key}) : super(key: key);

  @override
  _IssueListViewState createState() => _IssueListViewState();
}

class _IssueListViewState extends State<IssueListView> {
  IssueField? _selectedSortField;
  List<Issue> _issues = [];

  void _onSortFieldChanged(IssueField? v) {
    setState(() {
      _selectedSortField = v;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedProject = Provider.of<SelectedProject>(context, listen: true);
    return showList(context, selectedProject);
  }

  Widget showList(BuildContext context, SelectedProject selectedProject) {
    var paginatedDataTable = Expanded(
      child: SingleChildScrollView(
        child: PaginatedDataTable(
          columns: [
            DataColumn(label: Text("種別")),
            DataColumn(label: Text("キー")),
            DataColumn(label: Text("件名")),
            DataColumn(label: Text("担当者")),
            DataColumn(label: Text("状態")),
            DataColumn(label: Text("優先度")),
            DataColumn(label: Text("登録日")),
            DataColumn(label: Text("開始日")),
            DataColumn(label: Text("期限日")),
            DataColumn(label: Text("予定時間")),
            DataColumn(label: Text("実績時間")),
            DataColumn(label: Text("更新日")),
            DataColumn(label: Text("登録者")),
            // DataColumn(label: Text("添付")),
          ],
          source: IssueTableSource(context, selectedProject),
        ),
      ),
    );

    var listView = Flexible(
      child: Scrollbar(
        child: ListView.separated(
          itemCount: _issues.length,
          itemBuilder: (context, index) {
            return IssueSimple(_issues[index]);
          },
          separatorBuilder: (context, index) {
            return Divider();
          },
        ),
      ),
    );

    List<DropdownMenuItem<IssueField>> dropDownItems =
        IssueField.values.map<DropdownMenuItem<IssueField>>((IssueField value) {
      return DropdownMenuItem<IssueField>(
        value: value,
        child: Text(widget._issueFieldEnumHelper.description(value)),
      );
    }).toList();

    var dropdownButton = DropdownButton<IssueField>(
      value: _selectedSortField,
      hint: Text("並び替え"),
      items: dropDownItems,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      underline: Container(
        height: 2,
        color: Colors.blueAccent.shade100,
      ),
      onChanged: (IssueField? newValue) {
        _onSortFieldChanged(newValue);
      },
    );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // dropdownButton,
          paginatedDataTable,
        ],
      ),
    );
  }
}

class IssueSimple extends StatelessWidget {
  final Issue _issue;

  IssueSimple(this._issue);

  @override
  Widget build(BuildContext context) {
    final credentialInfo = Provider.of<CredentialInfo>(context);
    final apiKey = credentialInfo.apiKey;
    final space = credentialInfo.space!;
    Uri userIconUri = Uri.https(
        space,
        "/api/v2/users/" + _issue.createdUser.id.toString() + "/icon",
        {'apiKey': apiKey});
    var dateFormat = DateFormat('yyyy/MM/dd HH:mm', 'ja');
    return ListTile(
      title: Text(
        _issue.summary,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      leading: Image.network(userIconUri.toString()),
      subtitle: Text(
        _issue.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        children: [
          if (_issue.updated != null)
            Text(dateFormat.format(_issue.updated!))
          else if (_issue.created != null)
            Text(dateFormat.format(_issue.created!)),
          Text(_issue.createdUser.name),
        ],
      ),
    );
  }
}

class IssueTableSource extends DataTableSource {
  IssueField? sort;
  int sortOrder = 0; //0:desc, 1:asc

  List<Issue>? cachedIssues;
  int pageOfCachedIssues = 0;
  int itemPerPage = 20;

  int? totalRowCount;

  BuildContext _context;
  Project? _project;

  bool requestInProgress = false;

  BacklogApiClient apiClient = BacklogApiClient();

  IssueTableSource(BuildContext context, SelectedProject selectedProject)
      : _context = context,
        _project = selectedProject.project {
    print('IssueTableSource called');
    apiClient
        .fetchIssueCount(context: _context, project: _project)
        .then((value) => totalRowCount = value);
  }

  @override
  DataRow? getRow(int index) {
    var page = (index / itemPerPage).floor();
    if (cachedIssues == null ||
        (cachedIssues != null && pageOfCachedIssues != page)) {
      if (requestInProgress) {
        return null;
      }
      requestInProgress = true;
      // request
      apiClient
          .fetchIssues(
        context: _context,
        project: _project,
      )
          .then(
        (value) {
          cachedIssues = value;
          pageOfCachedIssues = page;
          notifyListeners();
        },
      ).whenComplete(() => requestInProgress = false);
      return null;
    } else {
      var translateIndex = index - (page * itemPerPage);
      if (cachedIssues!.length <= translateIndex) {
        Timer(Duration(seconds: 0), () => notifyListeners());
        return null;
      }
      var issue = cachedIssues![translateIndex];
      var dateFormat = DateFormat('yyyy/MM/dd HH:mm', 'ja');
      var dateFormatYmd = DateFormat('yyyy/MM/dd', 'ja');

      var startDate =
          issue.startDate != null ? dateFormatYmd.format(issue.startDate!) : "";
      var dueDate =
          issue.dueDate != null ? dateFormatYmd.format(issue.dueDate!) : "";

      var estimateHours =
          issue.estimatedHours != null ? issue.estimatedHours.toString() : "";
      var actualHours =
          issue.actualHours != null ? issue.actualHours.toString() : "";

      return DataRow.byIndex(
        index: index,
        color: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.hovered))
            return Theme.of(_context).colorScheme.secondary.withOpacity(0.08);
          return null;
        }),
        cells: [
          DataCell(
            Text(issue.issueType.name),
          ),
          DataCell(
            Text(issue.issueKey),
          ),
          DataCell(
            SizedBox(
              width: 400,
              child: Tooltip(
                message: issue.summary,
                padding: EdgeInsets.all(16.0),
                textStyle: TextStyle(
                  fontSize: 14.0,
                  color: Colors.white,
                ),
                child: Text(
                  issue.summary,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
          ),
          DataCell(
            Text(issue.assignee != null ? issue.assignee!.name : ""),
          ),
          DataCell(
            Text(issue.status.name),
          ),
          DataCell(
            Text(issue.priority.name),
          ),
          DataCell(
            Text(dateFormat.format(issue.created!)),
          ),
          DataCell(
            Text(startDate),
          ),
          DataCell(
            Text(dueDate),
          ),
          DataCell(
            Text(estimateHours),
          ),
          DataCell(
            Text(actualHours),
          ),
          DataCell(
            Text(dateFormat.format(issue.updated!)),
          ),
          DataCell(
            Text(issue.createdUser.name),
          ),
        ],
      );
    }
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate {
    print("called isRowCountApproximate");
    if (totalRowCount != null) {
      return false;
    }
    return true;
  }

  @override
  // TODO: implement rowCount
  int get rowCount {
    print("called rowCount");
    if (_project == null ||
        (cachedIssues != null && cachedIssues!.length == 0)) {
      print("called totalRowCount = 0");
      totalRowCount = 0;
      return 0;
    } else {
      if (totalRowCount != null) {
        print("called totalRowCount = " + totalRowCount!.toString());
        return totalRowCount!;
      } else {
        print("called totalRowCount = 0");
        return 0;
      }
    }
  }

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
}
