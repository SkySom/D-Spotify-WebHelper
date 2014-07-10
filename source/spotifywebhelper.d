module spotifywebhelper;

import std.stdio;
import std.path;
import std.net.curl;
import std.json;
import std.process;

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
}
