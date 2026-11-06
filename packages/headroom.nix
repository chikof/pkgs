{
  lib,
  maintainers,
  fetchPypi,
  buildPythonApplication,
  autoPatchelfHook,
  stdenv,
  # core
  tiktoken,
  pydantic,
  litellm,
  click,
  rich,
  opentelemetry-api,
  ast-grep-cli,
  pyyaml,
  tomlkit,
  truststore,
  hf-xet,
  filelock,
  # proxy extra (`headroom proxy`, `headroom wrap`, MCP server)
  fastapi,
  uvicorn,
  orjson,
  httpx,
  h2,
  openai,
  mcp,
  starlette,
  magika,
  zstandard,
  websockets,
  onnxruntime,
  transformers,
  watchdog,
  sqlite-vec,
}:
# shortcut: x86_64-linux wheel only (Rust _core built by maturin upstream); build from sdist when another platform needs it
buildPythonApplication (finalAttrs: {
  pname = "headroom";
  version = "0.43.1";
  format = "wheel";

  src = fetchPypi {
    pname = "headroom_ai";
    inherit (finalAttrs) version;
    format = "wheel";
    dist = "cp310";
    python = "cp310";
    abi = "abi3";
    platform = "manylinux_2_28_x86_64";
    hash = "sha256-LpzRqaq0L2CwCp98ioXPgoFbUbGYkXnl/dQN3QmRXW4=";
  };

  nativeBuildInputs = [autoPatchelfHook];
  buildInputs = [stdenv.cc.cc.lib];

  # nixpkgs mcp 1.29.0 / filelock 3.32.4; headroom never imports filelock itself, mcp >=1.30 only adds transports
  pythonRelaxDeps = ["mcp" "filelock" "opentelemetry-api" "tomlkit"];

  dependencies = [
    tiktoken
    pydantic
    litellm
    click
    rich
    opentelemetry-api
    ast-grep-cli
    pyyaml
    tomlkit
    truststore
    hf-xet
    filelock
    fastapi
    uvicorn
    orjson
    httpx
    h2
    openai
    mcp
    starlette
    magika
    zstandard
    websockets
    onnxruntime
    transformers
    watchdog
    sqlite-vec
  ];

  pythonImportsCheck = ["headroom" "headroom._core"];

  meta = {
    description = "Context compression proxy for coding agents (tool outputs, logs, files, history)";
    homepage = "https://github.com/headroomlabs-ai/headroom";
    changelog = "https://github.com/headroomlabs-ai/headroom/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [maintainers.chiko];
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    mainProgram = "headroom";
  };
})
