{ pc ? "computer", cpuVendor ? "unknown", gpuVendor ? "off" }:
let
  cpu = if pc == "usb" then "unknown" else cpuVendor;
  gpu = if pc == "usb" then "off" else gpuVendor;

  monitors = if pc == "usb" then [ ] else [
    {
      name = "HDMI-A-1";
      mode = "1920x1080@144.000";
      scale = 1.0;
      position = { x = 0; y = 0; };
      transform = "normal";
    }
  ];

  importIf = name: path: if name != "off" then [ path ] else [ ];
  pcDir = import ../hosts/${pc};

  niriOutputEntry = m: ''
    output "${m.name}" {
        mode "${m.mode}"
        scale ${builtins.toString m.scale}
        position x=${builtins.toString m.position.x} y=${builtins.toString m.position.y}
        transform "${m.transform}"
    }
  '';
in
{
  inherit pc cpu gpu monitors;

  systemImports = pcDir.modules
    ++ (if pc != "usb" then importIf cpu (if cpu == "amd" then ./amd-cpu.nix else ./intel.nix) else [ ])
    ++ (if pc != "usb" then importIf gpu (if gpu == "amd" then ./amd-gpu.nix else ./nvidia.nix) else [ ]);

  niriOutputs = builtins.concatStringsSep "\n" (map niriOutputEntry monitors);
}
