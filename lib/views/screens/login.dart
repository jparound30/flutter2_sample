import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../backlog_api.dart';
import '../../env_vars.dart';
import '../../providers/credential_info.dart';
import 'home_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width;
    if (MediaQuery.of(context).size.width > 500) {
      width = 500;
    } else {
      width = MediaQuery.of(context).size.width;
    }
    return Scaffold(
      body: Center(
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(vertical: 48.0),
          child: Column(
            children: [
              const Spacer(),
              const Text("Welcome to Backlog Alternate with Flutter2"),
              LoginForm(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  LoginFormState createState() {
    return LoginFormState();
  }
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController(text: EnvVars.spaceName);
  final _passwordController = TextEditingController(text: EnvVars.apiKey);

  bool _isValid = true; // TODO initial state handling

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var spaceField = TextFormField(
      controller: _userController,
      decoration: const InputDecoration(
        labelText: "スペース",
        helperText: 'Backlogのスペース名を入力してください 例) example.backlog.jp',
        enabled: true,
      ),
      autofillHints: const [AutofillHints.username],
      obscureText: false,
      onSaved: (value) => print("スペース: ${value!}"),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );

    final apiKeyField = TextFormField(
      controller: _passwordController,
      decoration: const InputDecoration(
        labelText: "APIキー",
        helperText: 'Backlogの個人設定で払い出したAPIキーを入力してください',
        enabled: true,
      ),
      autofillHints: const [AutofillHints.password],
      obscureText: true,
      onSaved: (value) => print("APIキー: ${value!}"),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: () {
        var isValid = _formKey.currentState!.validate();
        setState(() {
          _isValid = isValid;
        });
      },
      child: AutofillGroup(
        child: Column(
          children: [
            spaceField,
            apiKeyField,
            Padding(
              padding: const EdgeInsets.only(top: 48.0),
              child: ElevatedButton(
                onPressed: !_isValid
                    ? null
                    : () async {
                  if (_formKey.currentState == null ||
                      !_formKey.currentState!.validate()) {
                    return;
                  }
                  final pass = _passwordController.value.text;
                  final user = _userController.value.text;
                  print("Login pressed:$user:$pass");
                  final backlogApiClient = BacklogApiClient();
                  try {
                    final space =
                    await backlogApiClient.login(user, pass);
                    final credentialInfo = Provider.of<CredentialInfo>(
                        context,
                        listen: false);
                    credentialInfo.apiKey = pass;
                    credentialInfo.space = user;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) {
                          return HomePage(
                            title: '[${space.name}]',
                          );
                        },
                      ),
                    );
                  } catch (e) {
                    // TODO エラー表示 statefulに修正必要？
                    print(e);
                  }
                },
                child: const Text("ログイン"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
