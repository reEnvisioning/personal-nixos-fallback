{ pkgs }:
let
  buildToolsVersion = "36.0.0";
  androidSdk = (pkgs.androidenv.composeAndroidPackages {
    platformVersions = [ "36" ];
    buildToolsVersions = [ buildToolsVersion ];
    includeEmulator = true;
    includeSystemImages = true;
    systemImageTypes = [ "google_apis" ];
    abiVersions = [ "x86_64" ];
    includeCmake = false;
  }).androidsdk;
in
pkgs.mkShell {
  packages = [
    pkgs.android-studio
    pkgs.jdk21
    androidSdk
  ];

  JAVA_HOME = pkgs.jdk21.home;
  ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
  GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/${buildToolsVersion}/aapt2";
}
