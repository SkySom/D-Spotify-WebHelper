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

class SpotifyWebHelper {

}

class HelperFunctions {
  JSONValue getJson(string url) {
    auto contentString = get(url);
    auto contentJson = parseJSON(contentString);
    return contentJson;
  }

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
}
