{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.claude-code;
in
{
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        programs.claude-code.commands = lib.mkDefault {
          "cover-rb".source = ../files/commands/cover-rb.md;
          "cover-sh".source = ../files/commands/cover-sh.md;
          "extract-justfile-scripts".source = ../files/commands/extract-justfile-scripts.md;
          "extract-justfile-scripts-ruby".source = ../files/commands/extract-justfile-scripts-ruby.md;
          "humor" = {
            source = ../files/commands/humor;
            recursive = true;
          };
          "humor/sarcasm".source = ../files/commands/humor/sarcasm.md;
          "humor/terminator".source = ../files/commands/humor/terminator.md;
        };
      }

      (lib.mkIf cfg.presets.autoCommit {
        programs.claude-code.hookScripts = {
          "auto-commit.sh".source = ../files/hooks/auto-commit.sh;
          "auto-commit-project.sh".source = ../files/hooks/auto-commit-project.sh;
        };
      })

      (lib.mkIf cfg.presets.coverage {
        programs.claude-code.hookScripts = {
          "coverage-check.sh".source = ../files/hooks/coverage-check.sh;
        };
      })

      (lib.mkIf cfg.presets.justfile {
        programs.claude-code.hookScripts = {
          "justfile-extract.sh".source = ../files/hooks/justfile-extract.sh;
        };
      })

      (lib.mkIf cfg.presets.sessionId {
        programs.claude-code.hookScripts = {
          "session-id.sh".source = ../files/hooks/session-id.sh;
        };
      })

      (lib.mkIf cfg.presets.statusline {
        programs.claude-code.hookScripts = {
          "statusline.sh".source = ../files/hooks/statusline.sh;
        };
      })

      (lib.mkIf cfg.presets.gh {
        programs.claude-code.hookScripts = {
          "gh-statusline.sh".source = ../files/hooks/gh-statusline.sh;
        };
      })

      (lib.mkIf cfg.presets.gitStatus {
        programs.claude-code.hookScripts = {
          "git-status-statusline.sh".source = ../files/hooks/git-status-statusline.sh;
        };
      })

      (lib.mkIf cfg.presets.rtk {
        programs.claude-code.hookScripts = {
          "rtk-rewrite.sh".source = ../files/hooks/rtk-rewrite.sh;
          "rtk-statusline.sh".source = ../files/hooks/rtk-statusline.sh;
        };
      })

      (lib.mkIf cfg.presets.caveman {
        programs.claude-code.hookScripts = {
          "caveman-activate.sh".source = ../files/hooks/caveman-activate.sh;
          "caveman-mode-tracker.sh".source = ../files/hooks/caveman-mode-tracker.sh;
          "caveman-statusline.sh".source = ../files/hooks/caveman-statusline.sh;
          "cavemem-statusline.sh".source = ../files/hooks/cavemem-statusline.sh;
          "cavekit-statusline.sh".source = ../files/hooks/cavekit-statusline.sh;
        };
      })

      (lib.mkIf cfg.presets.semble {
        programs.claude-code.hookScripts = {
          "semble-statusline.sh".source = ../files/hooks/semble-statusline.sh;
        };
      })

      (lib.mkIf cfg.presets.astfold {
        programs.claude-code.hookScripts = {
          "astfold-statusline.sh".source = ../files/hooks/astfold-statusline.sh;
        };
      })
    ]
  );
}
