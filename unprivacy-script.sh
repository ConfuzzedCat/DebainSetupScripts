#!/usr/bin/env bash
# https://privacy.sexy — v0.12.10 — Sat, 20 Jan 2024 06:35:44 GMT
if [ "$EUID" -ne 0 ]; then
  script_path=$([[ "$0" = /* ]] && echo "$0" || echo "$PWD/${0#./}")
  sudo "$script_path" || (
    echo 'Administrator privileges are required.'
    exit 1
  )
  exit 0
fi
export HOME="/home/${SUDO_USER:-${USER}}" # Keep `~` and `$HOME` for user not `/root`.


# ----------------------------------------------------------
# ---Disable participation in Popularity Contest (revert)---
# ----------------------------------------------------------
echo '--- Disable participation in Popularity Contest (revert)'
config_file='/etc/popularity-contest.conf'
if [ -f "$config_file" ]; then
  sudo sed -i 's/PARTICIPATE=no/PARTICIPATE=yes/g' "$config_file"
else
  echo "Skipping because configuration file ($config_file) is not found. Is popcon installed?"
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# --Remove Popularity Contest (`popcon`) package (revert)---
# ----------------------------------------------------------
echo '--- Remove Popularity Contest (`popcon`) package (revert)'
if ! command -v 'apt-get' &> /dev/null; then
    >&2 echo 'Cannot revert because "apt-get" is not found.'
  else
    apt_package_name='popularity-contest'
if status="$(dpkg-query -W --showformat='${db:Status-Status}' "$apt_package_name" 2>&1)" \
    && [ "$status" = installed ]; then
  echo "Skipping, no action needed because \"$apt_package_name\" is already installed."
else
  echo "\"$apt_package_name\" is not installed and will be reinstalled."
  sudo apt-get install -y "$apt_package_name"
fi
  fi
# ----------------------------------------------------------


# Remove daily cron entry for Popularity Contest (popcon) (revert)
echo '--- Remove daily cron entry for Popularity Contest (popcon) (revert)'
cronjob_path="/etc/cron.daily/$job_name"
if [[ -f "$cronjob_path" ]]; then
  if [[ -x "$cronjob_path" ]]; then
    echo "Skipping, cronjob \"$job_name\" is already enabled."
  else
    sudo chmod +x "$cronjob_path"
    echo "Succesfully enabled cronjob \"$job_name\"."
  fi
else
  >&2 echo "Failed to enable cronjob \"$job_name\" because it's missing."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------Remove `reportbug` package (revert)------------
# ----------------------------------------------------------
echo '--- Remove `reportbug` package (revert)'
if ! command -v 'apt-get' &> /dev/null; then
    >&2 echo 'Cannot revert because "apt-get" is not found.'
  else
    apt_package_name='reportbug'
if status="$(dpkg-query -W --showformat='${db:Status-Status}' "$apt_package_name" 2>&1)" \
    && [ "$status" = installed ]; then
  echo "Skipping, no action needed because \"$apt_package_name\" is already installed."
else
  echo "\"$apt_package_name\" is not installed and will be reinstalled."
  sudo apt-get install -y "$apt_package_name"
fi
  fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------Remove Python modules for `reportbug` (revert)------
# ----------------------------------------------------------
echo '--- Remove Python modules for `reportbug` (revert)'
if ! command -v 'apt-get' &> /dev/null; then
    >&2 echo 'Cannot revert because "apt-get" is not found.'
  else
    apt_package_name='python3-reportbug'
if status="$(dpkg-query -W --showformat='${db:Status-Status}' "$apt_package_name" 2>&1)" \
    && [ "$status" = installed ]; then
  echo "Skipping, no action needed because \"$apt_package_name\" is already installed."
else
  echo "\"$apt_package_name\" is not installed and will be reinstalled."
  sudo apt-get install -y "$apt_package_name"
fi
  fi
# ----------------------------------------------------------


# Remove UI for reportbug (`reportbug-gtk` package) (revert)
echo '--- Remove UI for reportbug (`reportbug-gtk` package) (revert)'
if ! command -v 'apt-get' &> /dev/null; then
    >&2 echo 'Cannot revert because "apt-get" is not found.'
  else
    apt_package_name='reportbug-gtk'
if status="$(dpkg-query -W --showformat='${db:Status-Status}' "$apt_package_name" 2>&1)" \
    && [ "$status" = installed ]; then
  echo "Skipping, no action needed because \"$apt_package_name\" is already installed."
else
  echo "\"$apt_package_name\" is not installed and will be reinstalled."
  sudo apt-get install -y "$apt_package_name"
fi
  fi
# ----------------------------------------------------------


# Disable automatic Visual Studio Code extension updates (revert)
echo '--- Disable automatic Visual Studio Code extension updates (revert)'
if ! command -v 'python3' &> /dev/null; then
    >&2 echo 'Cannot revert because "python3" is not found.'
  else
    python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'extensions.autoUpdate'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print(f'Skipping, no need to revert because settings file is empty: "{settings_file}".')
    continue
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Skipping, "{property_name}" is not configured.')
    continue
  existing_value = json_object[property_name]
  if existing_value != target:
    print(f'Skipping, "{property_name}" is configured using {json.dumps(existing_value)} instead of {json.dumps(target)}.')
    continue
  del json_object[property_name]
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully reverted "{property_name}" setting.')
EOF
  fi
# ----------------------------------------------------------


# Disable Visual Studio Code automatic extension update checks (revert)
echo '--- Disable Visual Studio Code automatic extension update checks (revert)'
if ! command -v 'python3' &> /dev/null; then
    >&2 echo 'Cannot revert because "python3" is not found.'
  else
    python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'extensions.autoCheckUpdates'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print(f'Skipping, no need to revert because settings file is empty: "{settings_file}".')
    continue
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Skipping, "{property_name}" is not configured.')
    continue
  existing_value = json_object[property_name]
  if existing_value != target:
    print(f'Skipping, "{property_name}" is configured using {json.dumps(existing_value)} instead of {json.dumps(target)}.')
    continue
  del json_object[property_name]
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully reverted "{property_name}" setting.')
EOF
  fi
# ----------------------------------------------------------


# Disable automatic fetching of Microsoft recommendations in Visual Studio Code (revert)
echo '--- Disable automatic fetching of Microsoft recommendations in Visual Studio Code (revert)'
if ! command -v 'python3' &> /dev/null; then
    >&2 echo 'Cannot revert because "python3" is not found.'
  else
    python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'extensions.showRecommendationsOnlyOnDemand'
target = json.loads('true')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print(f'Skipping, no need to revert because settings file is empty: "{settings_file}".')
    continue
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Skipping, "{property_name}" is not configured.')
    continue
  existing_value = json_object[property_name]
  if existing_value != target:
    print(f'Skipping, "{property_name}" is configured using {json.dumps(existing_value)} instead of {json.dumps(target)}.')
    continue
  del json_object[property_name]
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully reverted "{property_name}" setting.')
EOF
  fi
# ----------------------------------------------------------


# Disable synchronization of Visual Studio Code keybindings (revert)
echo '--- Disable synchronization of Visual Studio Code keybindings (revert)'
if ! command -v 'python3' &> /dev/null; then
    >&2 echo 'Cannot revert because "python3" is not found.'
  else
    python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'settingsSync.keybindingsPerPlatform'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print(f'Skipping, no need to revert because settings file is empty: "{settings_file}".')
    continue
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Skipping, "{property_name}" is not configured.')
    continue
  existing_value = json_object[property_name]
  if existing_value != target:
    print(f'Skipping, "{property_name}" is configured using {json.dumps(existing_value)} instead of {json.dumps(target)}.')
    continue
  del json_object[property_name]
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully reverted "{property_name}" setting.')
EOF
  fi
# ----------------------------------------------------------


# Disable synchronization of Visual Studio Code extensions (revert)
echo '--- Disable synchronization of Visual Studio Code extensions (revert)'
if ! command -v 'python3' &> /dev/null; then
    >&2 echo 'Cannot revert because "python3" is not found.'
  else
    python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'settingsSync.ignoredExtensions'
target = json.loads('["*"]')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print(f'Skipping, no need to revert because settings file is empty: "{settings_file}".')
    continue
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Skipping, "{property_name}" is not configured.')
    continue
  existing_value = json_object[property_name]
  if existing_value != target:
    print(f'Skipping, "{property_name}" is configured using {json.dumps(existing_value)} instead of {json.dumps(target)}.')
    continue
  del json_object[property_name]
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully reverted "{property_name}" setting.')
EOF
  fi
# ----------------------------------------------------------


# Disable synchronization of Visual Studio Code settings (revert)
echo '--- Disable synchronization of Visual Studio Code settings (revert)'
if ! command -v 'python3' &> /dev/null; then
    >&2 echo 'Cannot revert because "python3" is not found.'
  else
    python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'settingsSync.ignoredSettings'
target = json.loads('["*"]')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print(f'Skipping, no need to revert because settings file is empty: "{settings_file}".')
    continue
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Skipping, "{property_name}" is not configured.')
    continue
  existing_value = json_object[property_name]
  if existing_value != target:
    print(f'Skipping, "{property_name}" is configured using {json.dumps(existing_value)} instead of {json.dumps(target)}.')
    continue
  del json_object[property_name]
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully reverted "{property_name}" setting.')
EOF
  fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------Disable Visual Studio Code telemetry (revert)-------
# ----------------------------------------------------------
echo '--- Disable Visual Studio Code telemetry (revert)'
if ! command -v 'python3' &> /dev/null; then
    >&2 echo 'Cannot revert because "python3" is not found.'
  else
    python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'telemetry.telemetryLevel'
target = json.loads('"off"')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print(f'Skipping, no need to revert because settings file is empty: "{settings_file}".')
    continue
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Skipping, "{property_name}" is not configured.')
    continue
  existing_value = json_object[property_name]
  if existing_value != target:
    print(f'Skipping, "{property_name}" is configured using {json.dumps(existing_value)} instead of {json.dumps(target)}.')
    continue
  del json_object[property_name]
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully reverted "{property_name}" setting.')
EOF
  fi
if ! command -v 'python3' &> /dev/null; then
    >&2 echo 'Cannot revert because "python3" is not found.'
  else
    python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'telemetry.enableTelemetry'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print(f'Skipping, no need to revert because settings file is empty: "{settings_file}".')
    continue
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Skipping, "{property_name}" is not configured.')
    continue
  existing_value = json_object[property_name]
  if existing_value != target:
    print(f'Skipping, "{property_name}" is configured using {json.dumps(existing_value)} instead of {json.dumps(target)}.')
    continue
  del json_object[property_name]
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully reverted "{property_name}" setting.')
EOF
  fi
if ! command -v 'python3' &> /dev/null; then
    >&2 echo 'Cannot revert because "python3" is not found.'
  else
    python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'telemetry.enableCrashReporter'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print(f'Skipping, no need to revert because settings file is empty: "{settings_file}".')
    continue
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Skipping, "{property_name}" is not configured.')
    continue
  existing_value = json_object[property_name]
  if existing_value != target:
    print(f'Skipping, "{property_name}" is configured using {json.dumps(existing_value)} instead of {json.dumps(target)}.')
    continue
  del json_object[property_name]
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully reverted "{property_name}" setting.')
EOF
  fi
# ----------------------------------------------------------


# Disable online experiments by Microsoft in Visual Studio Code (revert)
echo '--- Disable online experiments by Microsoft in Visual Studio Code (revert)'
if ! command -v 'python3' &> /dev/null; then
    >&2 echo 'Cannot revert because "python3" is not found.'
  else
    python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'workbench.enableExperiments'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print(f'Skipping, no need to revert because settings file is empty: "{settings_file}".')
    continue
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Skipping, "{property_name}" is not configured.')
    continue
  existing_value = json_object[property_name]
  if existing_value != target:
    print(f'Skipping, "{property_name}" is configured using {json.dumps(existing_value)} instead of {json.dumps(target)}.')
    continue
  del json_object[property_name]
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully reverted "{property_name}" setting.')
EOF
  fi
# ----------------------------------------------------------


# Disable fetching release notes from Microsoft servers after an update (revert)
echo '--- Disable fetching release notes from Microsoft servers after an update (revert)'
if ! command -v 'python3' &> /dev/null; then
    >&2 echo 'Cannot revert because "python3" is not found.'
  else
    python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'update.showReleaseNotes'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print(f'Skipping, no need to revert because settings file is empty: "{settings_file}".')
    continue
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Skipping, "{property_name}" is not configured.')
    continue
  existing_value = json_object[property_name]
  if existing_value != target:
    print(f'Skipping, "{property_name}" is configured using {json.dumps(existing_value)} instead of {json.dumps(target)}.')
    continue
  del json_object[property_name]
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully reverted "{property_name}" setting.')
EOF
  fi
# ----------------------------------------------------------


# Disable automatic fetching of remote repositories in Visual Studio Code (revert)
echo '--- Disable automatic fetching of remote repositories in Visual Studio Code (revert)'
if ! command -v 'python3' &> /dev/null; then
    >&2 echo 'Cannot revert because "python3" is not found.'
  else
    python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'git.autofetch'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print(f'Skipping, no need to revert because settings file is empty: "{settings_file}".')
    continue
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Skipping, "{property_name}" is not configured.')
    continue
  existing_value = json_object[property_name]
  if existing_value != target:
    print(f'Skipping, "{property_name}" is configured using {json.dumps(existing_value)} instead of {json.dumps(target)}.')
    continue
  del json_object[property_name]
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully reverted "{property_name}" setting.')
EOF
  fi
# ----------------------------------------------------------


# Disable sending search queries to Microsoft in Visual Studio Code (revert)
echo '--- Disable sending search queries to Microsoft in Visual Studio Code (revert)'
if ! command -v 'python3' &> /dev/null; then
    >&2 echo 'Cannot revert because "python3" is not found.'
  else
    python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'workbench.settings.enableNaturalLanguageSearch'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print(f'Skipping, no need to revert because settings file is empty: "{settings_file}".')
    continue
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Skipping, "{property_name}" is not configured.')
    continue
  existing_value = json_object[property_name]
  if existing_value != target:
    print(f'Skipping, "{property_name}" is configured using {json.dumps(existing_value)} instead of {json.dumps(target)}.')
    continue
  del json_object[property_name]
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully reverted "{property_name}" setting.')
EOF
  fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----Disable Visual Studio Code Edit Sessions (revert)-----
# ----------------------------------------------------------
echo '--- Disable Visual Studio Code Edit Sessions (revert)'
if ! command -v 'python3' &> /dev/null; then
    >&2 echo 'Cannot revert because "python3" is not found.'
  else
    python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'workbench.experimental.editSessions.enabled'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print(f'Skipping, no need to revert because settings file is empty: "{settings_file}".')
    continue
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Skipping, "{property_name}" is not configured.')
    continue
  existing_value = json_object[property_name]
  if existing_value != target:
    print(f'Skipping, "{property_name}" is configured using {json.dumps(existing_value)} instead of {json.dumps(target)}.')
    continue
  del json_object[property_name]
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully reverted "{property_name}" setting.')
EOF
  fi
if ! command -v 'python3' &> /dev/null; then
    >&2 echo 'Cannot revert because "python3" is not found.'
  else
    python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'workbench.experimental.editSessions.autoStore'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print(f'Skipping, no need to revert because settings file is empty: "{settings_file}".')
    continue
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Skipping, "{property_name}" is not configured.')
    continue
  existing_value = json_object[property_name]
  if existing_value != target:
    print(f'Skipping, "{property_name}" is configured using {json.dumps(existing_value)} instead of {json.dumps(target)}.')
    continue
  del json_object[property_name]
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully reverted "{property_name}" setting.')
EOF
  fi
if ! command -v 'python3' &> /dev/null; then
    >&2 echo 'Cannot revert because "python3" is not found.'
  else
    python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'workbench.editSessions.autoResume'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print(f'Skipping, no need to revert because settings file is empty: "{settings_file}".')
    continue
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Skipping, "{property_name}" is not configured.')
    continue
  existing_value = json_object[property_name]
  if existing_value != target:
    print(f'Skipping, "{property_name}" is configured using {json.dumps(existing_value)} instead of {json.dumps(target)}.')
    continue
  del json_object[property_name]
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully reverted "{property_name}" setting.')
EOF
  fi
if ! command -v 'python3' &> /dev/null; then
    >&2 echo 'Cannot revert because "python3" is not found.'
  else
    python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'workbench.editSessions.continueOn'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print(f'Skipping, no need to revert because settings file is empty: "{settings_file}".')
    continue
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Skipping, "{property_name}" is not configured.')
    continue
  existing_value = json_object[property_name]
  if existing_value != target:
    print(f'Skipping, "{property_name}" is configured using {json.dumps(existing_value)} instead of {json.dumps(target)}.')
    continue
  del json_object[property_name]
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully reverted "{property_name}" setting.')
EOF
  fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------Disable .NET telemetry (revert)--------------
# ----------------------------------------------------------
echo '--- Disable .NET telemetry (revert)'
variable='DOTNET_CLI_TELEMETRY_OPTOUT'
value='1'
declaration_file='/etc/environment'
if ! [ -f "$declaration_file" ]; then
  echo "Skipping, \"$declaration_file\" does not exist."
else
  assignment="$variable=$value"
  if grep --quiet "^$assignment$" "${declaration_file}"; then
    if sudo sed --in-place "/^$assignment$/d" "$declaration_file"; then
      echo "Successfully deleted \"$variable\" with \"$value\"."
    else
      >&2 echo "Failed to delete \"$assignment\"."
    fi
  else
    echo "Skipping, \"$variable\" with \"$value\" is not found."
  fi
fi
# ----------------------------------------------------------


echo 'Your privacy and security is now hardened 🎉💪'
echo 'Press any key to exit.'
read -n 1 -s