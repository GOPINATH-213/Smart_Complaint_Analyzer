import os

replacements = {
    'features/onboarding/presentation/screens/splash_screen.dart': 'features/auth/presentation/splash/splash_screen.dart',
    'features/onboarding/presentation/screens/onboarding_screen.dart': 'features/auth/presentation/onboarding/onboarding_screen.dart',
    'features/auth/presentation/screens/login_screen.dart': 'features/auth/presentation/login/login_screen.dart',
    'features/auth/presentation/screens/register_screen.dart': 'features/auth/presentation/register/register_screen.dart',
    'features/auth/presentation/screens/forgot_password_screen.dart': 'features/auth/presentation/forgot_password/forgot_password_screen.dart',
    'features/auth/presentation/screens/verify_email_screen.dart': 'features/auth/presentation/verify_email/verify_email_screen.dart',
    'features/auth/presentation/screens/user_type_screen.dart': 'features/auth/presentation/role_selection/user_type_screen.dart',
    'features/profile/presentation/screens/profile_completion_screen.dart': 'features/auth/presentation/profile_completion/profile_completion_screen.dart',
    'features/profile/presentation/screens/home_stub_screen.dart': 'features/user/dashboard/presentation/user_dashboard_screen.dart',
    'features/complaints/presentation/screens/submit_complaint_screen.dart': 'features/user/submit_complaint/presentation/submit_complaint_screen.dart',
    'features/complaints/presentation/screens/my_complaints_screen.dart': 'features/user/my_complaints/presentation/my_complaints_screen.dart',
    'features/complaints/presentation/screens/staff_dashboard_screen.dart': 'features/department_staff/dashboard/presentation/staff_dashboard_screen.dart',
    'features/complaints/presentation/screens/complaint_detail_screen.dart': 'features/complaints/presentation/complaint_details/complaint_detail_screen.dart',
    'features/profile/presentation/screens/profile_screen.dart': 'features/profile/presentation/profile/profile_screen.dart',
    'features/profile/presentation/screens/settings_screen.dart': 'features/profile/presentation/settings/settings_screen.dart'
}

lib_dir = "lib"

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            new_content = content
            for old, new in replacements.items():
                new_content = new_content.replace(old, new)
                
            if new_content != content:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                print(f"Updated {filepath}")
