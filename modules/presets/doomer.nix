{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.claude-code;
in
{
  config = lib.mkIf (cfg.enable && cfg.presets.doomer) {
    assertions = [
      {
        assertion = !(cfg.presets.doomer && cfg.presets.skeptic);
        message = "doomer and skeptic presets both set spinnerVerbs -- enable only one";
      }
    ];

    programs.claude-code.spinnerVerbs = {
      mode = "replace";
      verbs = [
        "Accepting fate"
        "Calculating entropy"
        "Contemplating void"
        "Counting down"
        "Defragmenting hope"
        "Embracing chaos"
        "Entropy increasing"
        "Existential processing"
        "Fading gracefully"
        "Heat death approaching"
        "Losing coherence"
        "Nihilism loading"
        "Oblivion pending"
        "Questioning existence"
        "Reality dissolving"
        "Surrendering control"
        "Unraveling threads"
        "Void expanding"
      ];
    };
  };
}
