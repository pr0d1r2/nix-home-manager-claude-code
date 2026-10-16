# cavemem built straight from nix-cavemem's cavemem.nix, like nix-config
# does: nix-cavemem no longer exports packages.default
# (pr0d1r2/nix-cavemem#89), so agentic's dev shell is stuck on an old
# rev with cavemem 0.1.3 / better-sqlite3 11, which aborts on Node 24.19
# (nodejs/node#65446). better-sqlite3 13 (N-API, nix-cavemem e5de763)
# does not.
{ pkgs, nix-cavemem-src }:
import "${nix-cavemem-src}/cavemem.nix" { inherit pkgs; }
