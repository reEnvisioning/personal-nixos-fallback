{
  time.timeZone = null;
  # nixpkgs 26.05 emits an invalid tmpfiles rule for imperative console settings.
  console.enable = false;

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = { };
  i18n.extraLocales = "all";
  i18n.imperativeLocale = true;
}
