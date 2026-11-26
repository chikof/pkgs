#!@runtimeShell@
# Runs your own Discord Phoenix AppImage with the Sunbird loader preloaded.
# Discord updates the AppImage in place, so it stays the user's own writable file.
set -eu

discord=${SUNBIRD_APPIMAGE:-}
if [ -z "$discord" ]; then
  # Same search as upstream's installer; newest wins.
  discord=$(ls -t "$PWD"/*[Dd]iscord*.AppImage "$HOME"/Applications/*[Dd]iscord*.AppImage "$HOME"/Downloads/*[Dd]iscord*.AppImage "$HOME"/Desktop/*[Dd]iscord*.AppImage 2>/dev/null | head -n 1) || true
fi

if [ ! -f "$discord" ]; then
  if [ -n "${SUNBIRD_APPIMAGE:-}" ]; then
    echo "sunbird: SUNBIRD_APPIMAGE points to a missing file: $SUNBIRD_APPIMAGE" >&2
  else
    echo "sunbird: Discord Phoenix AppImage not found in the current directory, ~/Applications, ~/Downloads or ~/Desktop." >&2
  fi
  echo "sunbird: set SUNBIRD_APPIMAGE=/path/to/discord-desktop.AppImage" >&2
  exit 1
fi

# pygobject finds the tray's GTK typelibs inside appimage-run's environment only through this
export GI_TYPELIB_PATH="/usr/lib/girepository-1.0${GI_TYPELIB_PATH:+:$GI_TYPELIB_PATH}"
export LD_PRELOAD="@loader@${LD_PRELOAD:+:$LD_PRELOAD}"
exec @appimageRun@ "$discord" "$@"
