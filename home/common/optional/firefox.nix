{ ... }:
{
  programs.firefox = {
    enable = true;

    policies = {
      Preferences = {
        "browser.tabs.groups.smart.enabled" = {
          Value = false;
          Status = "locked";
        };
        "browser.tabs.groups.smart.optin" = {
          Value = false;
          Status = "locked";
        };
        "browser.tabs.groups.smart.userEnabled" = {
          Value = false;
          Status = "locked";
        };
      };
    };
  };
}
