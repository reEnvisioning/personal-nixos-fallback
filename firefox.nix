{ config, pkgs, ... }: {
  programs.firefox = {
    enable = true;

    profiles.default = {
      id = 0;
      isDefault = true;

      settings = {
        # === General > Tabs > Interaction ===
        "browser.tabs.groups.smart.enabled" = false;
        "browser.tabs.groups.smart.optin" = false;
        "browser.tabs.groups.smart.userEnabled" = false;
        "browser.tabs.dragDrop.createGroup.enabled" = false;
        "sidebar.verticalTabs" = true;
        "sidebar.revamp" = true;
        "sidebar.visibility" = "show";

        # === General > Language and Appearance ===
        "layout.spellcheckDefault" = 0;
        "layout.css.always_underline_links" = true;

        # === General > Browsing ===
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;

        # === Home ===
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.feeds.snippets" = false;

        # === Search ===
        "browser.search.defaultenginename" = "DuckDuckGo";
        "browser.search.suggest.enabled" = false;

        # === Search > Address Bar ===
        "browser.urlbar.suggest.history" = false;
        "browser.urlbar.suggest.bookmark" = false;
        "browser.urlbar.suggest.openpage" = false;
        "browser.urlbar.suggest.topsites" = false;
        "browser.urlbar.suggest.recentsearches" = false;
        "browser.urlbar.suggest.engines" = false;
        "browser.urlbar.suggest.quickactions" = false;

        # === Privacy > Tracking Protection ===
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
        "datareporting.policy.dataSubmissionEnabled" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.ping-centre.telemetry" = false;
        "browser.crashReports.unsubmittedCheck.enabled" = false;
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

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
}
