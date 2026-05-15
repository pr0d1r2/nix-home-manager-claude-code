{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.claude-code;
in
{
  config = lib.mkIf (cfg.enable && cfg.presets.skeptic) {
    assertions = [
      {
        assertion = !(cfg.presets.doomer && cfg.presets.skeptic);
        message = "doomer and skeptic presets both set spinnerVerbs -- enable only one";
      }
    ];

    programs.claude-code.spinnerVerbs = {
      mode = "replace";
      verbs = [
        "Doubting everything"
        "Fact-checking claims"
        "Questioning assumptions"
        "Raising eyebrows"
        "Remaining unconvinced"
        "Requesting citations"
        "Scrutinizing evidence"
        "Suspecting hallucination"
        "Testing hypotheses"
        "Trust but verifying"
        "Validating sources"
        "Verifying independently"
      ];
    };
  };
}
