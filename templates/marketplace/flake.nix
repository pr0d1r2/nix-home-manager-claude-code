{
  description = "Claude Code plugin marketplace - my-marketplace";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nix-home-manager-claude-code = {
      url = "github:pr0d1r2/nix-home-manager-claude-code";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = _: {
    claudeCodeMarketplace = {
      name = "my-marketplace";
      plugins = [
        "plugin-a"
        "plugin-b"
      ];
    };
  };
}
