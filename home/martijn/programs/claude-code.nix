{ pkgs, pkgsUnstable, ... }:

{
  programs.claude-code = {
    enable = true;

    # Keep tracking unstable, matching the manual install we're replacing
    # (and how claude-code/codex are already pulled in packages-common.nix).
    package = pkgsUnstable.claude-code;

    # Register the mcp-nixos server. Referencing the store path pulls the
    # package into the closure automatically (no home.packages entry needed).
    # The module wraps `claude` with `--mcp-config`, so this is additive and
    # leaves the existing ~/.claude.json servers untouched.
    mcpServers.nixos = {
      type = "stdio";
      command = "${pkgsUnstable.mcp-nixos}/bin/mcp-nixos";
    };
  };
}
