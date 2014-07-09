module spotifywebhelper;

import std.algorithm;
import std.ascii;
import std.json;
import std.path;
import std.process;
import std.random;
import std.range;
import std.stdio;
import std.string;
import std.net.curl;

import processutils;
import webutils;

const int DEFAULT_PORT = 4370;

class SpotifyWebHelper {

}

class HelperFunctions {
  string getWindowsSpotifyWebHelperPath() {
    if(!environment.get("USERPROFILE")) {
      return null;
    }

    return buildPath(environment.get("USERPROFILE"),
      "AppData\\Roaming\\Spotify\\Data\\SpotifyWebHelper.exe");
  }

  string generateRandomString(int length) {
    return iota(length).map!(_ => letters[uniform(0, $)]).array;
  }

  string generateRandomLocalHostName() {
    return format("%s%s", generateRandomString(10), ".spotilocal.com");
  }

  bool isSpotifyWebHelperRunning() {
    auto processUtils = new ProcessUtils();
    if(processUtils.isProcessRunning("spotifywebhelper.exe")) {
      return true;
    }
    return false;
  }

  void launchSpotifyWebHelperIfNeeded() {
    if(isWindows() && !isSpotifyWebHelperRunning()) {
      string exePath = getWindowsSpotifyWebHelperPath();
      if(exePath != null) {
        spawnProcess(exePath);
      }
    }
  }

  string generateSpotifyUrl(string url) {
    return format("https://%s:%d%s", generateRandomLocalHostName(),
      DEFAULT_PORT, url);
  }

  string getOauthToken() {
    auto json = getJson("http://open.spotify.com/token");
    string token = json["t"].toString();
    return token;
  }

  bool isWindows() {
    return std.system.os == std.system.os.win32 ||
      std.system.os == std.system.os.win64;
  }
}
