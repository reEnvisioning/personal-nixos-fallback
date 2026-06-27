{ pc ? "desktop" }:
let
  cpuinfo = builtins.readFile "/proc/cpuinfo";
  cpu = if builtins.match ".*GenuineIntel.*" cpuinfo != null then "intel"
        else if builtins.match ".*AuthenticAMD.*" cpuinfo != null then "amd"
        else "unknown";
  tryReadVendor = card: let
    path = "/sys/class/drm/${card}/device/vendor";
  in if builtins.pathExists path then builtins.readFile path else "";

  drmEntries = builtins.attrNames (builtins.readDir "/sys/class/drm");
  cardDirs = builtins.filter (n: builtins.match "card[0-9]+" n != null) drmEntries;
  vendors = map tryReadVendor cardDirs;

  hasNvidia = builtins.any (v: builtins.match "0x10de" (toString v) != null) vendors;
  hasAmd    = builtins.any (v: builtins.match "0x1002" (toString v) != null) vendors;

  gpu = if hasNvidia then "nvidia"
        else if hasAmd then "amd"
        else "off";

  monitors = if pc == "usb" then [] else [
    {
      name = "HDMI-A-1";
      mode = "1920x1080@144.000";
      scale = 1.0;
      position = { x = 0; y = 0; };
      transform = "normal";
    }
  ];

  importIf = name: path: if name != "off" then [ path ] else [];
  pcDir = import ./${pc};

  niriOutputEntry = m: ''
    output "${m.name}" {
        mode "${m.mode}"
        scale ${builtins.toString m.scale}
        position x=${builtins.toString m.position.x} y=${builtins.toString m.position.y}
        transform "${m.transform}"
    }
  '';
in {
  inherit pc cpu gpu monitors;

  systemImports = pcDir.modules
    ++ (if pc != "usb" then importIf cpu (if cpu == "amd" then ./amd-cpu.nix else ./intel.nix) else [])
    ++ (if pc != "usb" then importIf gpu (if gpu == "amd" then ./amd-gpu.nix else ./nvidia.nix) else []);

  niriOutputs = builtins.concatStringsSep "\n" (map niriOutputEntry monitors);
}
