import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../viewmodels/login_viewmodel.dart';

/// Extracted form widget for the login screen.
///
/// Owns the [GlobalKey<FormState>] and the [TextEditingController]s for the
/// email and password fields. Calls [LoginViewModel.login] on valid
/// submission.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(LoginViewModel vm) {
    if (_formKey.currentState?.validate() ?? false) {
      vm.login(_emailController.text.trim(), _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<LoginViewModel>();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: AppStrings.email,
            hint: AppStrings.emailHint,
            controller: _emailController,
            validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: AppStrings.password,
            hint: AppStrings.passwordHint,
            controller: _passwordController,
            validator: Validators.required,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(vm),
          ),
          const SizedBox(height: 24),
          Obx(
            () => AppButton(
              label: AppStrings.loginButton,
              onPressed: vm.isLoading.value ? null : () => _submit(vm),
              isLoading: vm.isLoading.value,
            ),
          ),
        ],
      ),
    );
  }
}
