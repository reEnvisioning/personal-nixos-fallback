{ config, pkgs, ... }: {
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

    profiles.default = {
      id = 0;
      isDefault = true;

      search = {
        force = true;
        default = "ddg";
        privateDefault = "ddg";
      };

      settings = {
        "browser.tabs.dragDrop.createGroup.enabled" = false;
        "sidebar.verticalTabs" = true;
        "sidebar.revamp" = true;
        "sidebar.visibility" = "show";

        # === File picker (use built-in GTK dialog instead of portal) ===
        "widget.use-xdg-desktop-portal.file-picker" = 0;

        # === General > Language and Appearance ===
        "layout.spellcheckDefault" = 0;
        "layout.css.always_underline_links" = true;

        # === General > Browsing ===
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;

        # === Home ===
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.feeds.snippets" = false;
        "browser.newtabpage.activity-stream.feeds.websearch" = false;

        # === Search ===
        "browser.search.suggest.enabled" = false;

        # === Search > Address Bar ===
        "browser.urlbar.suggest.history" = false;
        "browser.urlbar.suggest.bookmark" = true;
        "browser.urlbar.suggest.openpage" = false;
        "browser.urlbar.suggest.topsites" = false;
        "browser.urlbar.suggest.recentsearches" = false;
        "browser.urlbar.suggest.engines" = false;
        "browser.urlbar.suggest.quickactions" = false;

        # === Privacy > Tracking Protection ===
        "browser.contentblocking.category" = "strict";
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtrack.enabled" = true;
        "privacy.trackingprotection.cryptomining.enabled" = true;
        "privacy.trackingprotection.fingerprinting.enabled" = true;
        "privacy.globalprivacycontrol.enabled" = true;

        # === Privacy > History ===
        "browser.privatebrowsing.autostart" = true;
        "privacy.sanitize.sanitizeOnShutdown" = true;
        "privacy.clearOnShutdown.cookies" = true;

        # === Privacy > Passwords & Autofill ===
        "signon.rememberSignons" = false;
        "extensions.formautofill.creditCards.enabled" = false;
        "extensions.formautofill.addresses.enabled" = false;

        # === Privacy > Data Collection ===
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

        # === Privacy > HTTPS-Only ===
        "dom.security.https_only_mode" = true;
        "dom.security.https_only_mode_pbm" = true;

        # === Privacy > DNS over HTTPS ===
        "network.trr.mode" = 3;
        "network.trr.uri" = "https://dns.quad9.net/dns-query";

        # === AI Controls ===
        "browser.ai.control.default" = "blocked";
        "browser.ml.enable" = false;
        "extensions.ml.enabled" = false;
      };
    };
  };

  home.file."${config.xdg.configHome}/mozilla/firefox/profiles.ini".force = true;
  home.file."${config.xdg.configHome}/mozilla/firefox/default/user.js".force = true;
}
