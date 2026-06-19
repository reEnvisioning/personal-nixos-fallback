{ theme, uiScale ? 1, perMonitor ? {} }:
builtins.toJSON ({
  uiScale = uiScale;
  themeName = theme.name or "";
  mode = theme.mode or "dark";
  colors = theme.colors or {};
  monitors = perMonitor;
})