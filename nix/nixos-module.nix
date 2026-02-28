{
  config,
  lib,
  ...
}:
let
  cfg = config.services.nocturnal-shell;
in
{
  options.services.nocturnal-shell = {
    enable = lib.mkEnableOption "Nocturnal shell systemd service";

    package = lib.mkOption {
      type = lib.types.package;
      description = "The nocturnal-shell package to use";
    };

    target = lib.mkOption {
      type = lib.types.str;
      default = "graphical-session.target";
      example = "hyprland-session.target";
      description = "The systemd target for the nocturnal-shell service.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.nocturnal-shell = {
      description = "Nocturnal Shell - Wayland desktop shell";
      documentation = [ "https://docs.nocturnal.dev" ];
      after = [ cfg.target ];
      partOf = [ cfg.target ];
      wantedBy = [ cfg.target ];
      restartTriggers = [ cfg.package ];

      environment = {
        PATH = lib.mkForce null;
      };

      serviceConfig = {
        ExecStart = lib.getExe cfg.package;
        Restart = "on-failure";
      };
    };

    environment.systemPackages = [ cfg.package ];
  };
}
