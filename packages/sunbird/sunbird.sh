#!@runtimeShell@
# Runs your own Discord Phoenix AppImage with the Sunbird loader preloaded.
# Discord updates the AppImage in place, so it stays the user's own writable file.
set -eu

discord=${SUNBIRD_APPIMAGE:-}
if [ -z "$discord" ]; then
  # Same search as upstream's installer; newest wins.
  discord=$(ls -t "$PWD"/*[Dd]iscord*.AppImage "$HOME"/Applications/*[Dd]iscord*.AppImage "$HOME"/Downloads/*[Dd]iscord*.AppImage "$HOME"/Desktop/*[Dd]iscord*.AppImage 2>/dev/null | head -n 1) || true
fi
if [ -z "$discord" ]; then
  # Discord records where it last ran from in its own desktop entry
  discord=$(sed -n 's/^TryExec=//p' "${XDG_DATA_HOME:-$HOME/.local/share}/applications/com.discord.libdiscord.desktop" 2>/dev/null | head -n 1) || true
fi

if [ ! -f "$discord" ]; then
  if [ -n "${SUNBIRD_APPIMAGE:-}" ]; then
    msg="SUNBIRD_APPIMAGE points to a missing file: $SUNBIRD_APPIMAGE"
  else
    msg="Discord Phoenix AppImage not found in the current directory, ~/Applications, ~/Downloads or ~/Desktop. Put it in one of them, or set SUNBIRD_APPIMAGE=/path/to/discord-desktop.AppImage"
  fi
  echo "sunbird: $msg" >&2
  # started from an app menu, stderr goes nowhere
  @notifySend@ --app-name=Sunbird "Sunbird could not start" "$msg" 2>/dev/null || true
  exit 1
fi

# pygobject finds the tray's GTK typelibs inside appimage-run's environment only through this
export GI_TYPELIB_PATH="/usr/lib/girepository-1.0${GI_TYPELIB_PATH:+:$GI_TYPELIB_PATH}"
export LD_PRELOAD="@loader@${LD_PRELOAD:+:$LD_PRELOAD}"
exec @appimageRun@ "$discord" "$@"
