{
  lib,
  maintainers,
  sources,
  buildPythonApplication,
  python,
  setuptools,
  networkx,
  tree-sitter,
  tree-sitter-grammars,
}:
buildPythonApplication (finalAttrs: {
  __structuredAttrs = true;
  pname = "graphify";
  pyproject = true;

  inherit (sources.graphify) src version;

  dontCheckRuntimeDeps = true;

  build-system = [
    setuptools
  ];

  dependencies =
    [
      networkx
      tree-sitter
    ]
    ++ (with tree-sitter-grammars; [
      tree-sitter-c
      tree-sitter-c-sharp
      tree-sitter-cpp
      tree-sitter-elixir
      tree-sitter-go
      tree-sitter-java
      tree-sitter-javascript
      tree-sitter-julia
      tree-sitter-kotlin
      tree-sitter-lua
      tree-sitter-php
      tree-sitter-powershell
      tree-sitter-python
      tree-sitter-ruby
      tree-sitter-rust
      tree-sitter-scala
      tree-sitter-swift
      tree-sitter-typescript
      tree-sitter-verilog
      tree-sitter-zig
    ]);

  # omp has no upstream platform; expose the `agents` skill bundle (uses the Task tool) as a skills dir
  postInstall = ''
    site=$out/${python.sitePackages}/graphify
    skill=$out/share/graphify/skills/graphify
    mkdir -p "$skill"
    cp "$site/skill-agents.md" "$skill/SKILL.md"
    cp -r "$site/skills/agents/references" "$skill/references"
  '';

  meta = {
    description = "AI coding assistant skill. Turn any folder of code, docs, papers, images, or videos into a queryable knowledge graph.";
    homepage = "https://github.com/safishamsi/graphify";
    changelog = "https://github.com/safishamsi/graphify/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [maintainers.chiko];
    mainProgram = "graphify";
  };
})
