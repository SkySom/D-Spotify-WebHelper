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
  string oauthToken;
  string csrfToken;

  HelperFunctions helper;

  this() {
    helper = new HelperFunctions();
    oauthToken = helper.getOauthToken();
    csrfToken = helper.getCsrfToken();
  }

  this(HelperFunctions helperFunctions) {
    helper = helperFunctions;
    oauthToken = helper.getOauthToken();
    csrfToken = helper.getCsrfToken();
  }
}

class HelperFunctions {
  string host;

  this() {
    host = generateRandomLocalHostName();
  }

  Header[] getCommonHeaders() {
    Header[] headers = new Header[8];
    headers[0] = new Header("Origin", "https://embed.spotify.com");
    headers[1] = new Header("Referer", "https://embed.spotify.com/?uri=spotify:track:spotify:track:51pQ7vY7WXzxskwloaeqyj");
    headers[2] = new Header("Accept", "*/*");
    headers[3] = new Header("Accept-Encoding", "gzip,deflate,sdch");
    headers[4] = new Header("Accept-Language", "en-US,en;q=0.8");
    headers[5] = new Header("User-Agent", "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36");
    headers[6] = new Header("Connection", "Keep-Alive");
    headers[7] = new Header("Host", host);
    return headers;
  }

  string getWindowsSpotifyWebHelperPath() {
    if(!environment.get("USERPROFILE")) {
      return null;
    }

    return buildPath(environment.get("USERPROFILE"),
      "AppData\\Roaming\\Spotify\\Data\\SpotifyWebHelper.exe");
  }

  string generateRandomString(int length) {
    return iota(length).map!(_ => letters[uniform(0, $)]).array.toLower();
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

  string generateSpotifyUrl(string path) {
    return format("https://%s:%d%s", host, DEFAULT_PORT, path);
  }

  string getOauthToken() {
    JSONValue oauthTokenJson = getJson("http://open.spotify.com/token");
    string oauthToken = oauthTokenJson["t"].toString();
    return oauthToken;
  }

  string getCsrfToken() {
    string url = generateSpotifyUrl("/simplecsrf/token.json");

    Param[] params = new Param[2];
    params[0] = new Param("&ref", "http%3A%2F%2Fd5ecgvacntsb3.cloudfront.net%2Fwidgets%2Fmusic-links%2Funit%2Fartist-playbutton%2Findex.html%3Fartist%3DLed%2BZeppelin");
    params[1] = new Param("cors", "");

    JSONValue csrfTokenJson = getJson(url, getCommonHeaders(), params);
    writeln(csrfTokenJson.toPrettyString());
    string csrfToken = csrfTokenJson["token"].toString();
    return csrfToken;
  }

  bool isWindows() {
    return std.system.os == std.system.os.win32 ||
      std.system.os == std.system.os.win64;
  }
}
