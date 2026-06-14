let
  # PC profile directory (e.g., "desktop", "laptop") — required
  pc = "desktop";

  # CPU: "intel", "amd", or "off" for no CPU-specific config
  cpu = "intel";

  # GPU: "nvidia", "amd", or "off" for no GPU-specific config
  gpu = "nvidia";

  # Monitors: list of {name, mode, scale, position, transform} or [] for auto-detect
  monitors = [
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

  systemImports = pcDir.modules ++ importIf cpu (if cpu == "amd" then ./amd-cpu.nix else ./intel.nix) ++ importIf gpu (if gpu == "amd" then ./amd-gpu.nix else ./nvidia.nix);

  niriOutputs = builtins.concatStringsSep "\n" (map niriOutputEntry monitors);
}
