import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:path_provider/path_provider.dart';
import 'package:gsheets/gsheets.dart';

class GoogleSheetsHelper {
  final _credentials = '''
{
  "type": "service_account",
  "project_id": "flutter-todo-410304",
  "private_key_id": "3f1111c5c56ea63069e0e6c379fa2a9232d3f71b",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDx+YJejY8z/OwM\nosVGqyEoexw6NlC1/oPBMIlmfKTuvOrGfjvWkA3z0nPd0AREaIXUziPp3bfbLkiO\nlql3BX4F4extVeiEDFeuI+X+aqow4PN9wB+QbSEmbmlq8mTfi3gFVGaY9NG3N9Pm\ngveTPBAhZGXgnCbNFsfauMO2IfIFlRlK4L6XFPQyMn0k4eJMwsZum/9J+0LxEr3g\nT70R0SLKwrim6/IIncK7IJpWssJ9KacMsjSBXHFmr8yUpktiYQZQyj9a76aP8pqQ\nQFUsaOd9HK5Ge/5/SgtBlCTwtXEx7B7UdgA1P2YPX7q1CWBWj2GwUKzlP1tnWRpt\nCVjfSc9VAgMBAAECggEABeZtlVyiR0Q9hTla0hROJKyLzaeRZD6me8lxMDyN0Pxu\nRRTC5MJydKWHCbuOvxRFXyD/oy4y03dXcZKe4zYREpelqizUFJQwdyCM9R0otTRm\n+4P5wQ3IJyW+EEuExiaicI7USZp+mpcT5aT/4Gkwg3/tNALat1l82gpzSzecrSIf\nbohagn7PohM4byIEVrrlg9kstORfdcpQaNxxTDSztVKZQ9HaQ5ri7Puf29e4jow2\n51uyhMxA7fs0IqOl/0Y4sy53WwsC9/ZZYjvRaSW/tvhMxkiX+uqFn6iWqDfVam65\np0A55sallaeA4QMTvoKhpBysKuSVDwi//KdEooUnaQKBgQD5a9MSbmcHKqsms+Ds\neAGR+uXxc0TIQpbIXxkE6zCAxjzTS7a2souPmMdl9GcKqdKBqiEy3izteADJ9Kda\nfqaxS3De7sWSz0W5saKLLKcQ0JiQ/BJDkMk/mvQc7gDj64P/MGXQao9tkU3s6gAN\nG3AAVSDzYTFXRckAS9QpsjrflwKBgQD4W2c3t6/T5W3xx3CLVqOwU+GKJLe0U9jX\n1vHOy6I/ppi0lp+XYMfIJC7G5HIaJT1IDoZz8OtQT2xZKIVoQEngK5xBGhU/z9fq\ntWme6SS0RqBZwL30Cp4vlkAuVFQrgp6T8zixZLZSKAclLgwWa8NmrxTEKJ7YTDTx\n2tbHuHdl8wKBgQDER9wk5wjhFOz3WhspPA9QR/fomOOKDQ0Hxf60ZjkXPenkBfNV\ntxApAvv3+euU8qucKrxRgZItloBYbdW9W2nmoA3FAnYs4Dxos6fMimk2zFEj15qv\n3SLikRiGI65DrrWDfxzAdPtGKFEAne1IY00ylcuGe/gOS/av6vydi4rVJQKBgQDT\nU0s30NgPELkFszOjjLxJ7IYMOwQJsBLiTeaBlSpgyMxFValEcLhuJ8OZv4cLkkZb\nyuhDPWutcXd7QgyKUbHKyrDxgFU2cA+EioruCeoOb84/sM6xGlvRmCLSiTT5tPJk\nZ+AEqfKtY5v42f61EUs6U53y77GB0Q54AUMivGb0WwKBgQCiJwybYVWOfeDJv03X\nWrx59wyt0AlzeGduCmV35+yWsisVZGe0ssK6kId88oRd2Y77xY3dAtHFcciVbvHU\nFdIE7tU44rC3J3EtbrzzenVTyly0oIg3/04o29qb1hIX/Ar3+1BMMUCWA4VCoUTg\n9EyqTiq5sMId/sdbTObstjQB3Q==\n-----END PRIVATE KEY-----\n",
  "client_email": "todo-391@flutter-todo-410304.iam.gserviceaccount.com",
  "client_id": "108358005783626916037",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/todo-391%40flutter-todo-410304.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
''';

  static const _spreadsheetId = '1P49heOLMT5_VUJfLENtz1PPA5dPGORxUQULQAPxmKAY';
  static const _worksheetTitle =
      'todo'; // Change this if your sheet has a different title

  GoogleSheetsHelper() {
    _init();
  }

  Future<void> _init() async {
    await auth.clientViaServiceAccount(
        _credentials as auth.ServiceAccountCredentials, [
      'https://www.googleapis.com/auth/spreadsheets',
    ]).then((client) async {
      final gsheets = GSheets(client);
      _spreadsheet = await gsheets.spreadsheet(_spreadsheetId);
    });
  }

  Spreadsheet? _spreadsheet;

  Future<List<List<String>>> readTasks() async {
    final sheet = await _spreadsheet?.worksheetByTitle(_worksheetTitle);
    final values = await sheet?.values.allRows();
    return values ?? [];
  }

  Future<void> addTask(String task) async {
    final sheet = await _spreadsheet?.worksheetByTitle(_worksheetTitle);
    await sheet?.values.appendRow([task]);
  }

  Future<void> updateTask(int rowIndex, String task) async {
    final sheet = await _spreadsheet?.worksheetByTitle(_worksheetTitle);
    await sheet?.values.insertValue(task, column: 1, row: rowIndex + 1);
  }

  Future<void> deleteTask(int rowIndex) async {
    final sheet = await _spreadsheet?.worksheetByTitle(_worksheetTitle);
    await sheet?.deleteRow(rowIndex + 1);
  }
}
