Windows Runbook (Flutter + WSL paths)

Option A: Run from C:\dev (recommended)
1) Copy the project from WSL to Windows (from Ubuntu terminal):
   mkdir -p /mnt/c/dev
   rsync -a --exclude=build --exclude=.dart_tool --exclude=.git ~/project/expense_tracker_windows/ /mnt/c/dev/expense_tracker_windows/
2) PowerShell:
   cd C:\dev\expense_tracker_windows
   flutter pub get
   flutter config --enable-web
   flutter run -d chrome --dart-define-from-file=env.json

Option B: Use UNC path (no copy)
1) Find your WSL distro name:
   PowerShell: wsl -l -v  (e.g., Ubuntu-24.04)
2) Use CMD to map the UNC path temporarily:
   cmd /c "pushd \\wsl$\\Ubuntu-24.04\\home\\mcsmart\\project\\expense_tracker_windows && flutter pub get && flutter run -d chrome --dart-define-from-file=env.json"

Android Studio
1) Open the folder (C:\dev\expense_tracker_windows)
2) Create run configuration:
   Program: lib/main.dart
   Additional args: --dart-define-from-file=env.json
3) Select an emulator or device and Run

Common Issues
- flutter not recognized: add C:\src\flutter\bin to PATH and reopen PowerShell.
- No Chrome device: install Chrome; run flutter devices.
- Supabase init error: verify env.json and pass --dart-define-from-file=env.json.

