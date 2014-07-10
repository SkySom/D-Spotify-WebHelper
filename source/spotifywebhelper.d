module spotifywebhelper;

import std.net.curl;
import std.json;

class SpotifyWebHelper {
  JSONValue getJson(string url) {
    auto contentString = get(url);
    auto contentJson = parseJSON(contentString);
    return contentJson;
  }
}
