{
  description = "Claude Code plugin - my-plugin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nix-home-manager-claude-code = {
      url = "github:pr0d1r2/nix-home-manager-claude-code";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = _: {
    claudeCodePlugin = {
      name = "my-plugin";
      version = "0.1.0";
      src = ./.;
    };
  };
}
