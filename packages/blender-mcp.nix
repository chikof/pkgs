{
  lib,
  maintainers,
  writeShellApplication,
  writeText,
  blender,
  mcp-for-blender,
}: let
  # runs inside the GUI after the main loop starts; the addon's TCP server listens on localhost only
  startServer = writeText "blender-mcp-start.py" ''
    import addon_utils
    import bpy

    addon_utils.enable("blender_mcp", default_set=False, persistent=False)

    def start():
        bpy.ops.blendermcp.start_server()

    bpy.app.timers.register(lambda: (start(), None)[1], first_interval=2.0)
  '';
in
  writeShellApplication {
    name = "blender-mcp";
    runtimeInputs = [blender];
    # the addon is not enabled in the user's preferences, so ~/.config/blender stays as Blender itself writes it
    text = ''
      export BLENDER_USER_SCRIPTS=${mcp-for-blender}/share/mcp-for-blender/scripts
      export DISABLE_TELEMETRY=true
      exec blender "$@" --python ${startServer}
    '';
    meta = {
      description = "Blender GUI that loads the mcp-for-blender addon and starts its localhost server";
      license = lib.licenses.mit;
      maintainers = [maintainers.chiko];
      mainProgram = "blender-mcp";
    };
  }
