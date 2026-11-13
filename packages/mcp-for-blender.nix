{
  lib,
  maintainers,
  fetchPypi,
  fetchFromGitHub,
  buildPythonApplication,
  python,
  setuptools,
  mcp,
  httpx,
  httpx-sse,
  pydantic,
  pydantic-settings,
  pyjwt,
  python-multipart,
  sse-starlette,
  starlette,
  typing-extensions,
  typing-inspection,
  uvicorn,
  anyio,
  jsonschema,
}:
# nixpkgs mcp is 2.x (no mcp.server.fastmcp); the server pins mcp<2, so build the 1.x SDK it was tested with
let
  mcp1 = mcp.overridePythonAttrs (old: rec {
    version = "1.30.0";
    src = fetchFromGitHub {
      owner = "modelcontextprotocol";
      repo = "python-sdk";
      tag = "v${version}";
      hash = "sha256-EkmTqsK+vBJcURuwFkhtNJMFgtzgw/7Cd+Fpav4P/ko=";
    };
    dependencies =
      [
        anyio
        httpx
        httpx-sse
        jsonschema
        pydantic
        pydantic-settings
        pyjwt
        python-multipart
        sse-starlette
        starlette
        typing-extensions
        typing-inspection
        uvicorn
      ]
      ++ pyjwt.optional-dependencies.crypto;
    doCheck = false;
    pythonImportsCheck = ["mcp" "mcp.server.fastmcp"];
  });
in
  buildPythonApplication (finalAttrs: {
    pname = "mcp-for-blender";
    version = "2.2.9";
    pyproject = true;

    src = fetchPypi {
      pname = "mcp_for_blender";
      inherit (finalAttrs) version;
      hash = "sha256-MFr1xXQmhfqB4u/L2KhzbLUAwdfJNGHLc/A6gmH86XU=";
    };

    build-system = [setuptools];

    dependencies = [
      mcp1
      httpx
    ];

    # `setup`, `update` and `install-addon` write client configs and addons into mutable locations; never run them.
    # Blender finds the addon read-only via BLENDER_USER_SCRIPTS=$out/share/mcp-for-blender/scripts.
    # BLENDERMCP_ADDONS_DIR makes the server's (read-only) addon freshness check look at that same copy.
    postInstall = ''
      install -Dm444 $out/${python.sitePackages}/blender_mcp/bundled/addon.py \
        $out/share/mcp-for-blender/scripts/addons/blender_mcp.py
    '';

    makeWrapperArgs = [
      "--set-default"
      "BLENDERMCP_ADDONS_DIR"
      "${placeholder "out"}/share/mcp-for-blender/scripts/addons"
    ];

    pythonImportsCheck = ["blender_mcp"];

    meta = {
      description = "MCP server that lets coding agents drive Blender through a bundled addon";
      homepage = "https://github.com/ahujasid/blender-mcp";
      changelog = "https://github.com/ahujasid/blender-mcp/releases/tag/v${finalAttrs.version}";
      license = lib.licenses.mit;
      maintainers = [maintainers.chiko];
      mainProgram = "mcp-for-blender";
    };
  })
