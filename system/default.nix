{ pkgs, nixUsers, trustedUsers ? nixUsers, cpuVendor, gpuVendor, username, pc ? "desktop", ... }:
let
  hw = import ../hardware/hardware.nix { inherit pc cpuVendor gpuVendor; };
  vbox-wrapped = pkgs.virtualbox.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
    postInstall = (old.postInstall or "") + ''
      for bin in $out/bin/VirtualBox $out/bin/VirtualBoxVM $out/bin/VBoxSDL; do
        [[ -f "$bin" ]] && wrapProgram "$bin" --set QT_QPA_PLATFORM "xcb"
      done
    '';
  });
  applyLocalSettings = pkgs.writeShellScript "apply-local-settings" ''
    set -eu
    export LOCAL_SETTINGS="/home/${username}/.config/reEnvisioning/usr/apps/NixOS/local.toml"
    if [ ! -f "$LOCAL_SETTINGS" ]; then
      exit 0
    fi
    exec ${pkgs.python3}/bin/python - <<'PY'
    import os
    import re
    import subprocess
    import sys
    import tomllib

    path = os.environ["LOCAL_SETTINGS"]
    try:
        with open(path, "rb") as file:
            settings = tomllib.load(file)
    except (OSError, tomllib.TOMLDecodeError) as error:
        print(f"invalid local settings: {error}", file=sys.stderr)
        raise SystemExit(1)

    allowed = {"timezone", "keymap", "defaultLocale", "extraLocaleSettings"}
    if not isinstance(settings, dict) or set(settings) - allowed:
        print("invalid local settings keys", file=sys.stderr)
        raise SystemExit(1)

    value_pattern = re.compile(r"^[A-Za-z0-9._+@/-]+$")
    def string_setting(name):
        value = settings.get(name)
        if value is not None and (not isinstance(value, str) or not value or not value_pattern.fullmatch(value)):
            print(f"invalid local setting: {name}", file=sys.stderr)
            raise SystemExit(1)
        return value

    timezone = string_setting("timezone")
    keymap = string_setting("keymap")
    default_locale = string_setting("defaultLocale")
    extra = settings.get("extraLocaleSettings", {})
    locale_keys = {"LC_ADDRESS", "LC_IDENTIFICATION", "LC_MEASUREMENT", "LC_MONETARY", "LC_NAME", "LC_NUMERIC", "LC_PAPER", "LC_TELEPHONE", "LC_TIME"}
    if not isinstance(extra, dict) or set(extra) - locale_keys:
        print("invalid local setting: extraLocaleSettings", file=sys.stderr)
        raise SystemExit(1)
    for key, value in extra.items():
        if not isinstance(key, str) or not isinstance(value, str) or not value or not value_pattern.fullmatch(value):
            print("invalid local setting: extraLocaleSettings", file=sys.stderr)
            raise SystemExit(1)

    if timezone:
        subprocess.run(["${pkgs.systemd}/bin/timedatectl", "set-timezone", timezone], check=True)
    if keymap:
        subprocess.run(["${pkgs.systemd}/bin/localectl", "set-keymap", keymap], check=True)
    locale = {}
    if default_locale:
        locale["LANG"] = default_locale
    locale.update(extra)
    if locale:
        subprocess.run(["${pkgs.systemd}/bin/localectl", "set-locale"] + [f"{key}={value}" for key, value in locale.items()], check=True)
    PY
  '';
in
{
  imports = [
    ../network/networking.nix
    ./local.nix
    ../theme/plymouth.nix
    ./greeter.nix
    ./audio.nix
    ./compositor.nix
    ./polkit.nix
    ./security.nix
    ./maintenance.nix
    ./power.nix
    ./mount.nix
  ] ++ hw.systemImports;

  system.stateVersion = "26.05";

  systemd.services.apply-local-settings = {
    description = "Apply optional personal NixOS settings";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" "dbus.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = applyLocalSettings;
    };
  };

  systemd.paths.apply-local-settings = {
    wantedBy = [ "multi-user.target" ];
    pathConfig = {
      PathChanged = "/home/${username}/.config/reEnvisioning/usr/apps/NixOS/local.toml";
      Unit = "apply-local-settings.service";
    };
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    allowed-users = nixUsers;
    trusted-users = trustedUsers;
    require-sigs = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    openssh
    hyprshot
    brightnessctl
    tmux
  ];

  virtualisation.virtualbox.host = {
    enable = true;
    package = vbox-wrapped;
  };
}
