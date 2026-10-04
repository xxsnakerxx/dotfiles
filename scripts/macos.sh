# shellcheck shell=bash
COMPUTER_NAME="Dimkol-Mac"
LANGUAGES=(en pl)
LOCALE="en_US@currency=EUR"
MEASUREMENT_UNITS="Centimeters"
SCREENSHOTS_FOLDER="${HOME}/Desktop"

# Applies "domain|key|type|value|description" rows via `defaults write`.
# The trailing description field is documentation only; it is not emitted.
apply_defaults() {
  local entry domain key type value description
  for entry in "$@"; do
    # shellcheck disable=SC2034 # description field is documentation-only
    IFS='|' read -r domain key type value description <<< "$entry"
    defaults write "$domain" "$key" "$type" "$value"
  done
}

setup_macos() {
  info "Setting up macOS..."

  osascript -e 'tell application "System Preferences" to quit'

  # Ask for the administrator password upfront
  sudo -v
  sudo_keepalive

  setup_computer_name
  setup_localization
  setup_system
  setup_keyboard
  setup_trackpad
  setup_screen
  setup_finder
  setup_dock
  setup_calendar
  setup_terminal
  setup_activity_monitor
  setup_system_updates
  finish_setup

  warn "Please restart the computer to apply all changes"
  success "macOS setup completed"
}

setup_computer_name() {
  info "Setting up computer name..."

  sudo scutil --set ComputerName "$COMPUTER_NAME"
  sudo scutil --set HostName "$COMPUTER_NAME"
  sudo scutil --set LocalHostName "$COMPUTER_NAME"
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$COMPUTER_NAME"

  success "Computer name setup completed"
}

setup_localization() {
  info "Setting up localization..."

  # Set language and text formats
  # shellcheck disable=SC2068 # intentional word-splitting
  defaults write NSGlobalDomain AppleLanguages -array ${LANGUAGES[@]}
  apply_defaults \
    "NSGlobalDomain|AppleLocale|-string|$LOCALE|Set language and text formats" \
    "NSGlobalDomain|AppleMeasurementUnits|-string|$MEASUREMENT_UNITS|Set language and text formats" \
    "NSGlobalDomain|AppleMetricUnits|-bool|true|Set language and text formats"

  # Set the time zone
  sudo defaults write /Library/Preferences/com.apple.timezone.auto Active -bool YES
  sudo systemsetup -setusingnetworktime on

  # Use 24-hour time format in menu bar (day of week, no date)
  apply_defaults \
    "com.apple.menuextra.clock|Show24Hour|-bool|true|Use 24-hour time format in menu bar" \
    "com.apple.menuextra.clock|ShowAMPM|-bool|false|Use 24-hour time format in menu bar" \
    "com.apple.menuextra.clock|ShowDate|-int|0|Use 24-hour time format in menu bar" \
    "com.apple.menuextra.clock|ShowDayOfWeek|-bool|true|Use 24-hour time format in menu bar"
  kill -SIGHUP SystemUIServer 2>/dev/null || true

  success "Localization setup completed"
}

setup_system() {
  info "Setting up system..."

  # Restart automatically if the computer freezes (Error:-99 can be ignored)
  sudo systemsetup -setrestartfreeze on 2> /dev/null

  # Set standby delay to 24 hours (default is 1 hour)
  sudo pmset -a standbydelay 86400

  # Disable Sudden Motion Sensor
  sudo pmset -a sms 0

  # Disable audio feedback when volume is changed
  defaults write com.apple.sound.beep.feedback -bool false

  # Disable the sound effects on boot
  sudo nvram SystemAudioVolume=" "
  sudo nvram StartupMute=%01

  # Menu bar: show battery percentage
  defaults write com.apple.menuextra.battery ShowPercent YES

  apply_defaults \
    "NSGlobalDomain|NSAutomaticWindowAnimationsEnabled|-bool|false|Disable opening and closing window animations" \
    "NSGlobalDomain|NSWindowResizeTime|-float|0.001|Increase window resize speed for Cocoa applications" \
    "NSGlobalDomain|NSNavPanelExpandedStateForSaveMode|-bool|true|Expand save panel by default" \
    "NSGlobalDomain|NSNavPanelExpandedStateForSaveMode2|-bool|true|Expand save panel by default" \
    "NSGlobalDomain|PMPrintingExpandedStateForPrint|-bool|true|Expand print panel by default" \
    "NSGlobalDomain|PMPrintingExpandedStateForPrint2|-bool|true|Expand print panel by default" \
    "NSGlobalDomain|NSDocumentSaveNewDocumentsToCloud|-bool|false|Save to disk (not to iCloud) by default" \
    "com.apple.print.PrintingPrefs|Quit When Finished|-bool|true|Automatically quit printer app once the print jobs complete" \
    "com.apple.LaunchServices|LSQuarantine|-bool|false|Disable the 'Are you sure you want to open this application?' dialog" \
    "com.apple.systempreferences|NSQuitAlwaysKeepsWindows|-bool|false|Disable Resume system-wide" \
    "com.apple.CrashReporter|DialogType|-string|none|Disable the crash reporter"

  success "System setup completed"
}

setup_keyboard() {
  info "Setting up keyboard..."

  apply_defaults \
    "NSGlobalDomain|NSAutomaticQuoteSubstitutionEnabled|-bool|false|Disable smart quotes (annoying when typing code)" \
    "NSGlobalDomain|NSAutomaticDashSubstitutionEnabled|-bool|false|Disable smart dashes (annoying when typing code)" \
    "NSGlobalDomain|AppleKeyboardUIMode|-int|3|Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)" \
    "NSGlobalDomain|ApplePressAndHoldEnabled|-bool|false|Disable press-and-hold for keys in favor of key repeat" \
    "NSGlobalDomain|KeyRepeat|-int|2|Set a blazingly fast keyboard repeat rate" \
    "NSGlobalDomain|InitialKeyRepeat|-int|15|Set a blazingly fast keyboard repeat rate" \
    "com.apple.BezelServices|kDim|-bool|true|Automatically illuminate built-in MacBook keyboard in low light" \
    "com.apple.BezelServices|kDimTime|-int|300|Turn off keyboard illumination when computer is not used for 5 minutes" \
    "NSGlobalDomain|NSAutomaticSpellingCorrectionEnabled|-bool|false|Disable auto-correct" \
    "NSGlobalDomain|com.apple.keyboard.fnState|-bool|true|Press the fn key to use the special features printed on the key" \
    "com.apple.HIToolbox|AppleFnUsageType|-int|1|Switch between keyboard layouts for other languages (input sources)"

  success "Keyboard setup completed"
}

setup_trackpad() {
  info "Setting up trackpad..."

  # Trackpad: enable tap to click for this user and for the login screen
  apply_defaults \
    "com.apple.AppleMultitouchTrackpad|Clicking|-bool|true|Trackpad: enable tap to click for this user and for the login screen" \
    "com.apple.driver.AppleBluetoothMultitouch.trackpad|Clicking|-bool|true|Trackpad: enable tap to click for this user and for the login screen"
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  apply_defaults \
    "NSGlobalDomain|com.apple.mouse.tapBehavior|-int|1|Trackpad: enable tap to click"

  # Trackpad: map bottom right corner to right-click
  apply_defaults \
    "com.apple.driver.AppleBluetoothMultitouch.trackpad|TrackpadCornerSecondaryClick|-int|2|Trackpad: map bottom right corner to right-click" \
    "com.apple.driver.AppleBluetoothMultitouch.trackpad|TrackpadRightClick|-bool|true|Trackpad: map bottom right corner to right-click"
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

  # Trackpad: swipe between pages with three fingers
  apply_defaults \
    "NSGlobalDomain|AppleEnableSwipeNavigateWithScrolls|-bool|true|Trackpad: swipe between pages with three fingers"
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerHorizSwipeGesture -int 1
  apply_defaults \
    "com.apple.driver.AppleBluetoothMultitouch.trackpad|TrackpadThreeFingerHorizSwipeGesture|-int|1|Trackpad: swipe between pages with three fingers"

  success "Trackpad setup completed"
}

setup_screen() {
  info "Setting up screen..."

  # Require password immediately after sleep or screen saver begins
  apply_defaults \
    "com.apple.screensaver|askForPassword|-int|1|Require password immediately after sleep or screen saver begins" \
    "com.apple.screensaver|askForPasswordDelay|-int|0|Require password immediately after sleep or screen saver begins"

  # Save screenshots to the ~/Desktop folder
  mkdir -p "${SCREENSHOTS_FOLDER}"
  apply_defaults \
    "com.apple.screencapture|location|-string|$SCREENSHOTS_FOLDER|Save screenshots to the ~/Desktop folder" \
    "com.apple.screencapture|type|-string|png|Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)" \
    "com.apple.screencapture|disable-shadow|-bool|true|Disable shadow in screenshots" \
    "NSGlobalDomain|AppleFontSmoothing|-int|2|Enable subpixel font rendering on non-Apple LCDs"

  success "Screen setup completed"
}

setup_finder() {
  info "Setting up Finder..."

  apply_defaults \
    "com.apple.finder|DisableAllAnimations|-bool|true|Finder: disable window animations and Get Info animations" \
    "com.apple.finder|AppleShowAllFiles|-bool|true|Finder: show hidden files by default" \
    "NSGlobalDomain|AppleShowAllExtensions|-bool|true|Finder: show all filename extensions" \
    "com.apple.finder|ShowStatusBar|-bool|true|Finder: show status bar" \
    "com.apple.finder|ShowPathbar|-bool|true|Finder: show path bar" \
    "com.apple.finder|QLEnableTextSelection|-bool|true|Finder: allow text selection in Quick Look" \
    "com.apple.finder|_FXShowPosixPathInTitle|-bool|true|Display full POSIX path as Finder window title" \
    "com.apple.finder|_FXSortFoldersFirst|-bool|true|Keep folders on top when sorting by name" \
    "com.apple.finder|FXDefaultSearchScope|-string|SCcf|When performing a search, search the current folder by default" \
    "com.apple.finder|FXEnableExtensionChangeWarning|-bool|false|Disable the warning when changing a file extension" \
    "com.apple.desktopservices|DSDontWriteNetworkStores|-bool|true|Avoid creating .DS_Store files on network or USB volumes" \
    "com.apple.desktopservices|DSDontWriteUSBStores|-bool|true|Avoid creating .DS_Store files on network or USB volumes" \
    "com.apple.frameworks.diskimages|skip-verify|-bool|true|Disable disk image verification" \
    "com.apple.frameworks.diskimages|skip-verify-locked|-bool|true|Disable disk image verification" \
    "com.apple.frameworks.diskimages|skip-verify-remote|-bool|true|Disable disk image verification" \
    "com.apple.NetworkBrowser|BrowseAllInterfaces|-bool|true|Use AirDrop over every interface" \
    "com.apple.finder|FXPreferredViewStyle|-string|clmv|Always open everything in Finder's column view (other view modes: icnv, clmv, Flwv)" \
    "com.apple.finder|WarnOnEmptyTrash|-bool|false|Disable the warning before emptying the Trash"

  # Expand the following File Info panes:
  # "General", "Open with", and "Sharing & Permissions"
  defaults write com.apple.finder FXInfoPanesExpanded -dict General -bool true OpenWith -bool true Privileges -bool true

  success "Finder setup completed"
}

setup_dock() {
  info "Setting up dock..."

  apply_defaults \
    "com.apple.dock|show-process-indicators|-bool|true|Show indicator lights for open applications in the Dock" \
    "com.apple.dock|launchanim|-bool|false|Don't animate opening applications from the Dock" \
    "com.apple.dock|autohide|-bool|false|Automatically hide and show the Dock" \
    "com.apple.dock|showhidden|-bool|true|Make Dock icons of hidden applications translucent" \
    "com.apple.dock|no-bouncing|-bool|false|No bouncing icons" \
    "com.apple.dock|wvous-tl-corner|-int|0|Disable hot corners" \
    "com.apple.dock|wvous-tr-corner|-int|0|Disable hot corners" \
    "com.apple.dock|wvous-bl-corner|-int|0|Disable hot corners" \
    "com.apple.dock|wvous-br-corner|-int|0|Disable hot corners" \
    "com.apple.dock|show-recents|-bool|false|Don't show recently used applications in the Dock"

  success "Dock setup completed"
}

setup_calendar() {
  info "Setting up Calendar..."

  apply_defaults \
    "com.apple.iCal|Show Week Numbers|-bool|true|Show week numbers (10.8 only)" \
    "com.apple.iCal|first day of week|-int|1|Week starts on monday"

  success "Calendar setup completed"
}

setup_terminal() {
  info "Setting up Terminal..."

  # Only use UTF-8 in Terminal.app
  defaults write com.apple.terminal StringEncodings -array 4

  # Appearance
  apply_defaults \
    "com.apple.terminal|Default Window Settings|-string|Pro|Appearance" \
    "com.apple.terminal|Startup Window Settings|-string|Pro|Appearance" \
    "com.apple.Terminal|ShowLineMarks|-int|0|Appearance"

  success "Terminal setup completed"
}

setup_activity_monitor() {
  info "Setting up Activity Monitor..."

  apply_defaults \
    "com.apple.ActivityMonitor|OpenMainWindow|-bool|true|Show the main window when launching Activity Monitor" \
    "com.apple.ActivityMonitor|IconType|-int|5|Visualize CPU usage in the Activity Monitor Dock icon" \
    "com.apple.ActivityMonitor|ShowCategory|-int|0|Show all processes in Activity Monitor" \
    "com.apple.ActivityMonitor|SortColumn|-string|CPUUsage|Sort Activity Monitor results by CPU usage" \
    "com.apple.ActivityMonitor|SortDirection|-int|0|Sort Activity Monitor results by CPU usage"

  success "Activity Monitor setup completed"
}

setup_system_updates() {
  info "Setting up system updates..."

  apply_defaults \
    "com.apple.SoftwareUpdate|AutomaticCheckEnabled|-bool|true|Enable the automatic update check" \
    "com.apple.SoftwareUpdate|ScheduleFrequency|-string|7|Check for software updates weekly (dot update includes software updates)" \
    "com.apple.SoftwareUpdate|AutomaticDownload|-bool|true|Download newly available updates in background" \
    "com.apple.SoftwareUpdate|CriticalUpdateInstall|-bool|true|Install System data files & security updates" \
    "com.apple.commerce|AutoUpdate|-bool|true|Turn on app auto-update" \
    "com.apple.commerce|AutoUpdateRestartRequired|-bool|true|Allow the App Store to reboot machine on macOS updates"

  success "System updates setup completed"
}

finish_setup() {
  info "Finishing setup..."

  for app in "Address Book" "Calendar" "Contacts" "Dock" "Finder" "Mail" "Safari" "SystemUIServer" "iCal"; do
    killall "${app}" &>/dev/null || true
  done
}
