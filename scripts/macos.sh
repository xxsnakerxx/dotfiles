COMPUTER_NAME="Dimkol-Mac"
LANGUAGES=(en pl)
LOCALE="en_US@currency=EUR"
MEASUREMENT_UNITS="Centimeters"
SCREENSHOTS_FOLDER="${HOME}/Desktop"

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
  defaults write NSGlobalDomain AppleLanguages -array ${LANGUAGES[@]}
  defaults write NSGlobalDomain AppleLocale -string "$LOCALE"
  defaults write NSGlobalDomain AppleMeasurementUnits -string "$MEASUREMENT_UNITS"
  defaults write NSGlobalDomain AppleMetricUnits -bool true

  # Set the time zone
  sudo defaults write /Library/Preferences/com.apple.timezone.auto Active -bool YES
  sudo systemsetup -setusingnetworktime on

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

  # Disable opening and closing window animations
  defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

  # Increase window resize speed for Cocoa applications
  defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

  # Expand save panel by default
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

  # Expand print panel by default
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

  # Save to disk (not to iCloud) by default
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

  # Automatically quit printer app once the print jobs complete
  defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

  # Disable the “Are you sure you want to open this application?” dialog
  defaults write com.apple.LaunchServices LSQuarantine -bool false

  # Disable Resume system-wide
  defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

  # Disable the crash reporter
  defaults write com.apple.CrashReporter DialogType -string "none"

  success "System setup completed"
}

setup_keyboard() {
  info "Setting up keyboard..."

  # Disable smart quotes and dashes as they’re annoying when typing code
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

  # Enable full keyboard access for all controls
  # (e.g. enable Tab in modal dialogs)
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

  # Disable press-and-hold for keys in favor of key repeat
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

  # Set a blazingly fast keyboard repeat rate
  defaults write NSGlobalDomain KeyRepeat -int 1
  defaults write NSGlobalDomain InitialKeyRepeat -int 15

  # Automatically illuminate built-in MacBook keyboard in low light
  defaults write com.apple.BezelServices kDim -bool true

  # Turn off keyboard illumination when computer is not used for 5 minutes
  defaults write com.apple.BezelServices kDimTime -int 300

  # Disable auto-correct
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

  # Press the fn key to use the special features printed on the key.
  defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true

  # Switches between keyboard layouts for writing in other languages (known as input sources).
  defaults write com.apple.HIToolbox AppleFnUsageType -int "1"

  success "Keyboard setup completed"
}

setup_trackpad() {
  info "Setting up trackpad..."

  # Trackpad: enable tap to click for this user and for the login screen
  defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

  # Trackpad: map bottom right corner to right-click
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

  # Trackpad: swipe between pages with three fingers
  defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool true
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerHorizSwipeGesture -int 1
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 1

  success "Trackpad setup completed"
}

setup_screen() {
  info "Setting up screen..."

  # Require password immediately after sleep or screen saver begins
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0

  # Save screenshots to the ~/Desktop folder
  mkdir -p "${SCREENSHOTS_FOLDER}"
  defaults write com.apple.screencapture location -string "${SCREENSHOTS_FOLDER}"

  # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
  defaults write com.apple.screencapture type -string "png"

  # Disable shadow in screenshots
  defaults write com.apple.screencapture disable-shadow -bool true

  # Enable subpixel font rendering on non-Apple LCDs
  defaults write NSGlobalDomain AppleFontSmoothing -int 2

  success "Screen setup completed"
}

setup_finder() {
  info "Setting up Finder..."

  # Finder: disable window animations and Get Info animations
  defaults write com.apple.finder DisableAllAnimations -bool true

  # Finder: show hidden files by default
  defaults write com.apple.finder AppleShowAllFiles -bool true

  # Finder: show all filename extensions
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  # Finder: show status bar
  defaults write com.apple.finder ShowStatusBar -bool true

  # Finder: show path bar
  defaults write com.apple.finder ShowPathbar -bool true

  # Finder: allow text selection in Quick Look
  defaults write com.apple.finder QLEnableTextSelection -bool true

  # Display full POSIX path as Finder window title
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

  # Keep folders on top when sorting by name
  defaults write com.apple.finder _FXSortFoldersFirst -bool true

  # When performing a search, search the current folder by default
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

  # Disable the warning when changing a file extension
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

  # Avoid creating .DS_Store files on network or USB volumes
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

  # Disable disk image verification
  defaults write com.apple.frameworks.diskimages skip-verify -bool true
  defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
  defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

  # Use AirDrop over every interface.
  defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

  # Always open everything in Finder's column view.
  # Use list view in all Finder windows by default
  # Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
  defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

  # Disable the warning before emptying the Trash
  defaults write com.apple.finder WarnOnEmptyTrash -bool false

  # Expand the following File Info panes:
  # “General”, “Open with”, and “Sharing & Permissions”
  defaults write com.apple.finder FXInfoPanesExpanded -dict General -bool true OpenWith -bool true Privileges -bool true

  success "Finder setup completed"
}

setup_dock() {
  info "Setting up dock..."

  # Show indicator lights for open applications in the Dock
  defaults write com.apple.dock show-process-indicators -bool true

  # Don’t animate opening applications from the Dock
  defaults write com.apple.dock launchanim -bool false

  # Automatically hide and show the Dock
  defaults write com.apple.dock autohide -bool false

  # Make Dock icons of hidden applications translucent
  defaults write com.apple.dock showhidden -bool true

  # No bouncing icons
  defaults write com.apple.dock no-bouncing -bool false

  # Disable hot corners
  defaults write com.apple.dock wvous-tl-corner -int 0
  defaults write com.apple.dock wvous-tr-corner -int 0
  defaults write com.apple.dock wvous-bl-corner -int 0
  defaults write com.apple.dock wvous-br-corner -int 0

  # Don't show recently used applications in the Dock
  defaults write com.apple.dock show-recents -bool false

  success "Dock setup completed"
}

setup_calendar() {
  info "Setting up Calendar..."

  # Show week numbers (10.8 only)
  defaults write com.apple.iCal "Show Week Numbers" -bool true

  # Week starts on monday
  defaults write com.apple.iCal "first day of week" -int 1

  success "Calendar setup completed"
}

setup_terminal() {
  info "Setting up Terminal..."

  # Only use UTF-8 in Terminal.app
  defaults write com.apple.terminal StringEncodings -array 4

  # Appearance
  defaults write com.apple.terminal "Default Window Settings" -string "Pro"
  defaults write com.apple.terminal "Startup Window Settings" -string "Pro"
  defaults write com.apple.Terminal ShowLineMarks -int 0

  success "Terminal setup completed"
}

setup_activity_monitor() {
  info "Setting up Activity Monitor..."

  # Show the main window when launching Activity Monitor
  defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

  # Visualize CPU usage in the Activity Monitor Dock icon
  defaults write com.apple.ActivityMonitor IconType -int 5

  # Show all processes in Activity Monitor
  defaults write com.apple.ActivityMonitor ShowCategory -int 0

  # Sort Activity Monitor results by CPU usage
  defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
  defaults write com.apple.ActivityMonitor SortDirection -int 0

  success "Activity Monitor setup completed"
}

setup_system_updates() {
  info "Setting up system updates..."

  # Enable the automatic update check
  defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

  # Check for software updates weekly (`dot update` includes software updates)
  defaults write com.apple.SoftwareUpdate ScheduleFrequency -string 7

  # Download newly available updates in background
  defaults write com.apple.SoftwareUpdate AutomaticDownload -bool true

  # Install System data files & security updates
  defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -bool true

  # Turn on app auto-update
  defaults write com.apple.commerce AutoUpdate -bool true

  # Allow the App Store to reboot machine on macOS updates
  defaults write com.apple.commerce AutoUpdateRestartRequired -bool true

  success "System updates setup completed"
}

finish_setup() {
  info "Finishing setup..."

  for app in "Address Book" "Calendar" "Contacts" "Dock" "Finder" "Mail" "Safari" "SystemUIServer" "iCal"; do
    killall "${app}" &>/dev/null || true
  done
}