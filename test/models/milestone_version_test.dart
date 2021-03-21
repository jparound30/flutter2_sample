import 'dart:convert';

import 'package:flutter2_sample/models/issue.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final normal = '''
{ 
    "id": 3, 
    "projectId": 1, 
    "name": "いますぐ", 
    "description": "", 
    "startDate": null, 
    "releaseDueDate": null, 
    "archived": false, 
    "displayOrder": 0 
}
''';
  test(
    'MilestoneVersion should be deserialized',
    () {
      var milestoneVersion = MilestoneVersion.fromJson(jsonDecode(normal));
      expect(milestoneVersion.id, 3);
      expect(milestoneVersion.projectId, 1);
      expect(milestoneVersion.name, "いますぐ");
      expect(milestoneVersion.description, "");
      expect(milestoneVersion.startDate, null);
      expect(milestoneVersion.releaseDueDate, null);
      expect(milestoneVersion.archived, false);
      expect(milestoneVersion.displayOrder, 0);
    },
  );

  final startDate = '''
{ 
    "id": 3, 
    "projectId": 1, 
    "name": "いますぐ", 
    "description": "", 
    "startDate": "2021-01-02T03:04:05Z", 
    "releaseDueDate": null, 
    "archived": false, 
    "displayOrder": 0 
}
''';
  test(
    'MilestoneVersion with startDate should be deserialized',
    () {
      var milestoneVersion = MilestoneVersion.fromJson(jsonDecode(startDate));
      expect(milestoneVersion.id, 3);
      expect(milestoneVersion.projectId, 1);
      expect(milestoneVersion.name, "いますぐ");
      expect(milestoneVersion.description, "");
      expect(milestoneVersion.startDate,
          DateTime.utc(2021, 1, 2, 3, 4, 5).toLocal());
      expect(milestoneVersion.releaseDueDate, null);
      expect(milestoneVersion.archived, false);
      expect(milestoneVersion.displayOrder, 0);
    },
  );

  final releaseDueDate = '''
{ 
    "id": 3, 
    "projectId": 1, 
    "name": "いますぐ", 
    "description": "", 
    "startDate": null, 
    "releaseDueDate": "2021-01-02T03:04:05Z", 
    "archived": false, 
    "displayOrder": 0 
}
''';
  test(
    'MilestoneVersion with releaseDueDate should be deserialized',
    () {
      var milestoneVersion =
          MilestoneVersion.fromJson(jsonDecode(releaseDueDate));
      expect(milestoneVersion.id, 3);
      expect(milestoneVersion.projectId, 1);
      expect(milestoneVersion.name, "いますぐ");
      expect(milestoneVersion.description, "");
      expect(milestoneVersion.startDate, null);
      expect(milestoneVersion.releaseDueDate,
          DateTime.utc(2021, 1, 2, 3, 4, 5).toLocal());
      expect(milestoneVersion.archived, false);
      expect(milestoneVersion.displayOrder, 0);
    },
  );
}
