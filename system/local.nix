{ localOverrides ? {}, ... }:
{
  time.timeZone = localOverrides.timezone or "UTC";
  console.keyMap = localOverrides.keymap or "us";

  i18n.defaultLocale = localOverrides.defaultLocale or "en_US.UTF-8";
  i18n.extraLocaleSettings = localOverrides.extraLocaleSettings or { };
}
