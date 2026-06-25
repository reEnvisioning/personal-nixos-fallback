{ config, pkgs, ... }:
let
  commonSettings = {
    "browser.tabs.dragDrop.createGroup.enabled" = false;
    "sidebar.verticalTabs" = true;
    "sidebar.revamp" = true;
    "sidebar.visibility" = "show";

    "widget.use-xdg-desktop-portal.file-picker" = 0;
    "layout.spellcheckDefault" = 0;
    "layout.css.always_underline_links" = true;
    "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
    "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
    "browser.newtabpage.activity-stream.feeds.topsites" = false;
    "browser.newtabpage.activity-stream.feeds.snippets" = false;
    "browser.newtabpage.activity-stream.feeds.websearch" = false;
    "browser.search.suggest.enabled" = false;
    "browser.urlbar.suggest.history" = false;
    "browser.urlbar.suggest.bookmark" = true;
    "browser.urlbar.suggest.openpage" = false;
    "browser.urlbar.suggest.topsites" = false;
    "browser.urlbar.suggest.recentsearches" = false;
    "browser.urlbar.suggest.engines" = false;
    "browser.urlbar.suggest.quickactions" = false;
    "browser.contentblocking.category" = "strict";
    "privacy.trackingprotection.enabled" = true;
    "privacy.trackingprotection.socialtrack.enabled" = true;
    "privacy.trackingprotection.cryptomining.enabled" = true;
    "privacy.trackingprotection.fingerprinting.enabled" = true;
    "privacy.globalprivacycontrol.enabled" = true;
    "browser.privatebrowsing.autostart" = true;
    "privacy.sanitize.sanitizeOnShutdown" = true;
    "privacy.clearOnShutdown.cookies" = true;
    "signon.rememberSignons" = false;
    "extensions.formautofill.creditCards.enabled" = false;
    "extensions.formautofill.addresses.enabled" = false;
    "datareporting.healthreport.uploadEnabled" = false;
    "datareporting.healthreport.service.enabled" = false;
    "datareporting.policy.dataSubmissionEnabled" = false;
    "browser.newtabpage.activity-stream.feeds.telemetry" = false;
    "browser.newtabpage.activity-stream.telemetry" = false;
    "browser.ping-centre.telemetry" = false;
    "browser.crashReports.unsubmittedCheck.enabled" = false;
    "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
    "toolkit.telemetry.unified" = false;
    "toolkit.telemetry.enabled" = false;
    "dom.security.https_only_mode" = true;
    "dom.security.https_only_mode_pbm" = true;
    "network.trr.mode" = 3;
    "network.trr.uri" = "https://dns.quad9.net/dns-query";
    "browser.ai.control.default" = "blocked";
    "browser.ml.enable" = false;
    "extensions.ml.enabled" = false;
  };

  commonSearch = {
    force = true;
    default = "ddg";
    privateDefault = "ddg";
  };
in {
  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";

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

    profiles = {
      default = {
        id = 0;
        isDefault = true;
        search = commonSearch;
        settings = commonSettings;
      };
    };
  };

  home.file."${config.home.homeDirectory}/.config/mozilla/firefox/default/user.js".force = true;
}
