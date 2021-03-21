import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'backlog_api.dart';
import 'models/issue.dart';
import 'models/project.dart';
import 'providers/credential_info.dart';
import 'providers/selected_project.dart';
import 'views/components/issue_type_chip.dart';
import 'views/components/status_chip.dart';
import 'views/screens/issue_detail_page.dart';

/// 課題のフィールド列挙型（ソートキー用）
enum IssueField {
  /// 種類
  issueType,

  /// ID
  id,

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
    ret[IssueField.id] = "キー";
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

  int? _sortColumnIndex = 2;
  bool _ascending = false;
  int _itemPerPage = 10;
  int _firstRowIndex = 0;

  _IssueListViewState() {
    print('_IssueListViewState()');
  }

  void _onSortFieldChanged(IssueField? v) {
    setState(() {
      _selectedSortField = v;
    });
  }

  void _toggleSortOrder(int columnIndex, bool ascending) {
    setState(() {
      print("_toggleSortOrder: ascending = " + ascending.toString());
      _ascending = ascending;
      _sortColumnIndex = columnIndex;
      // TODO カラムのリストと連動させる
      switch (_sortColumnIndex) {
        case 0:
          _selectedSortField = IssueField.issueType;
          break;
        case 1:
          _selectedSortField = IssueField.id;
          break;
        case 3:
          _selectedSortField = IssueField.assignee;
          break;
        case 4:
          _selectedSortField = IssueField.status;
          break;
        case 5:
          _selectedSortField = IssueField.priority;
          break;
        case 6:
          _selectedSortField = IssueField.created;
          break;
        case 7:
          _selectedSortField = IssueField.startDate;
          break;
        case 8:
          _selectedSortField = IssueField.dueDate;
          break;
        case 9:
          _selectedSortField = IssueField.estimatedHours;
          break;
        case 10:
          _selectedSortField = IssueField.actualHours;
          break;
        case 11:
          _selectedSortField = IssueField.updated;
          break;
        case 12:
          _selectedSortField = IssueField.createdUser;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("_IssueListViewState: build() _ascending = " + _ascending.toString());
    final selectedProject = Provider.of<SelectedProject>(context, listen: true);
    return showList(context, selectedProject);
  }

  Widget showList(BuildContext context, SelectedProject selectedProject) {
    var paginatedDataTable = Expanded(
      child: SingleChildScrollView(
        child: PaginatedDataTable(
          rowsPerPage: _itemPerPage,
          onRowsPerPageChanged: (value) {
            if (value == null) {
              return;
            }
            setState(() {
              _itemPerPage = value;
            });
          },
          onPageChanged: (value) {
            print('onPageChanged: ' + value.toString());
            setState(() {
              _firstRowIndex = value;
            });
          },
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _ascending,
          columnSpacing: 16,
          columns: [
            DataColumn(
              label: Expanded(child: Center(child: Text("種別"))),
              onSort: _toggleSortOrder,
            ),
            DataColumn(
              label: Expanded(child: Center(child: Text("キー"))),
              onSort: _toggleSortOrder,
            ),
            DataColumn(label: Expanded(child: Center(child: Text("件名")))),
            DataColumn(
              label: Expanded(child: Center(child: Text("担当者"))),
              onSort: _toggleSortOrder,
            ),
            DataColumn(
              label: Expanded(child: Center(child: Text("状態"))),
              onSort: _toggleSortOrder,
            ),
            DataColumn(
              label: Expanded(child: Center(child: Text("優先度"))),
              onSort: _toggleSortOrder,
            ),
            DataColumn(
              label: Expanded(child: Center(child: Text("登録日"))),
              onSort: _toggleSortOrder,
            ),
            DataColumn(
              label: Expanded(child: Center(child: Text("開始日"))),
              onSort: _toggleSortOrder,
            ),
            DataColumn(
              label: Expanded(child: Center(child: Text("期限日"))),
              onSort: _toggleSortOrder,
            ),
            DataColumn(
              label:
                  Expanded(child: Center(child: Text("予定\n時間", maxLines: 2))),
              onSort: _toggleSortOrder,
            ),
            DataColumn(
              label:
                  Expanded(child: Center(child: Text("実績\n時間", maxLines: 2))),
              onSort: _toggleSortOrder,
            ),
            DataColumn(
              label: Expanded(child: Center(child: Text("更新日"))),
              onSort: _toggleSortOrder,
            ),
            DataColumn(
              label: Expanded(child: Center(child: Text("登録者"))),
              onSort: _toggleSortOrder,
            ),
            // DataColumn(label: Text("添付")),
          ],
          source: IssueTableSource(
            context: context,
            selectedProject: selectedProject,
            sort: _selectedSortField,
            ascending: _ascending,
            itemPerPage: _itemPerPage,
            firstRowIndex: _firstRowIndex,
          ),
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

  // TODO このへんの数字の辻褄はAPIのリクエスト内容などとあってないので直す
  List<Issue>? cachedIssues;
  int pageOfCachedIssues = 0;
  int _itemPerPage;
  int _firstRowIndex;

  int? totalRowCount;

  late CredentialInfo _credentialInfo;
  BuildContext _context;
  Project? _project;
  IssueField? _sort;
  bool? _ascending;

  bool requestInProgress = false;

  BacklogApiClient apiClient = BacklogApiClient();
  final TextStyle textStyleInCells = TextStyle(
    fontSize: 12.0,
  );
  final TextStyle textStyleInCellsWhile = TextStyle(
    fontSize: 12.0,
    color: Colors.white,
  );

  IssueTableSource({
    required BuildContext context,
    required SelectedProject selectedProject,
    IssueField? sort,
    bool? ascending,
    required int itemPerPage,
    required int firstRowIndex,
  })   : _context = context,
        _project = selectedProject.project,
        _sort = sort,
        _ascending = ascending,
        _itemPerPage = itemPerPage,
        _firstRowIndex = firstRowIndex {
    print('IssueTableSource called');
    _credentialInfo = Provider.of<CredentialInfo>(context);

    apiClient
        .fetchIssueCount(
      credentialInfo: _credentialInfo,
      project: _project,
      sort: _sort,
      ascending: _ascending,
    )
        .then((value) {
      totalRowCount = value;
      notifyListeners();
    });
  }

  @override
  DataRow? getRow(int index) {
    if (totalRowCount == null) {
      // fetchIssueCount() is running...
      return null;
    }
    var page = (index / _itemPerPage).floor();
    if (cachedIssues == null ||
        (cachedIssues != null && pageOfCachedIssues != page)) {
      if (requestInProgress) {
        return null;
      }
      requestInProgress = true;
      // request
      apiClient
          .fetchIssues(
        credentialInfo: _credentialInfo,
        project: _project,
        sort: _sort,
        ascending: _ascending,
        count: _itemPerPage,
        offset: _firstRowIndex,
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
      var translateIndex = index - (page * _itemPerPage);
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
            Center(
              child: IssueTypeChip(issue.issueType),
            ),
          ),
          DataCell(
            Text(
              issue.issueKey,
              style: textStyleInCells,
            ),
          ),
          DataCell(
            SizedBox(
              width: 400,
              child: Tooltip(
                message: issue.summary,
                padding: EdgeInsets.all(16.0),
                textStyle: textStyleInCellsWhile,
                child: Text(
                  issue.summary,
                  style: textStyleInCells,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
            onTap: () {
              // TODO 詳細画面の表示
              Navigator.of(_context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return IssueDetailPage(issue: issue);
                  },
                ),
              );
            },
          ),
          DataCell(
            Text(
              issue.assignee != null ? issue.assignee!.name : "",
              style: textStyleInCells,
            ),
          ),
          DataCell(
            Center(
              child: Text(
                issue.status.name,
                style: textStyleInCells,
              ),
            ),
          ),
          DataCell(
            Center(
              child: Text(
                issue.priority.name,
                style: textStyleInCells,
              ),
            ),
          ),
          DataCell(
            Center(
              child: Text(
                dateFormat.format(issue.created!),
                style: textStyleInCells,
              ),
            ),
          ),
          DataCell(
            Center(
              child: Text(
                startDate,
                style: textStyleInCells,
              ),
            ),
          ),
          DataCell(
            Center(
              child: Text(
                dueDate,
                style: textStyleInCells,
              ),
            ),
          ),
          DataCell(
            Center(
              child: Text(
                estimateHours,
                style: textStyleInCells,
              ),
            ),
          ),
          DataCell(
            Center(
              child: Text(
                actualHours,
                style: textStyleInCells,
              ),
            ),
          ),
          DataCell(
            Center(
              child: Text(
                dateFormat.format(issue.updated!),
                style: textStyleInCells,
              ),
            ),
          ),
          DataCell(
            Center(
              child: Text(
                issue.createdUser.name,
                style: textStyleInCells,
              ),
            ),
          ),
        ],
      );
    }
  }

  @override
  bool get isRowCountApproximate {
    print("called isRowCountApproximate: " + totalRowCount.toString());
    if (totalRowCount != null) {
      return false;
    }
    return true;
  }

  @override
  int get rowCount {
    print("called rowCount");
    if (_project == null ||
        (cachedIssues != null && cachedIssues!.length == 0)) {
      print("called project is null or cachedIssues.length == 0 ");
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
