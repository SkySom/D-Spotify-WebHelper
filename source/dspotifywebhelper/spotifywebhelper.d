module dspotifywebhelper.spotifywebhelper;

import std.algorithm;
import std.array;
import std.ascii;
import std.path;
import std.random;
import std.range;
import std.stdio;
import std.string;
import std.net.curl;

import vibe.data.json;

import dspotifywebhelper.processutils;
import dspotifywebhelper.webutils;
import dspotifywebhelper.os.windows;

const int DEFAULT_PORT = 4370;
const string DEFAULT_RETURN_ON = "login,logout,play,pause,error,ap";
const int DEFAULT_RETURN_AFTER = 1;

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

    Json getVersion() {
        string url = helper.generateSpotifyUrl("/service/version.json");
        Param[] params = new Param[1];
        params[0] = new Param("service","remote");

        return getJson(url, helper.getCommonHeaders(), params);
    }

    Json getStatus() {
        Param[] params = new Param[2];
        params[0] = new Param("returnafter", to!string(DEFAULT_RETURN_AFTER));
        params[1] = new Param("returnon", DEFAULT_RETURN_ON);

        return spotifyJsonRequest("/remote/status.json", params);
    }

    void pause(bool pause = true) {
        Param[] params = new Param[1];
        params[0] = new Param("pause", to!string(pause));
        spotifyJsonRequest("/remote/pause.json", params);
    }

    void unpause() {
        pause(false);
    }

    void play(string spotifyUri) {
        Param[] params = new Param[2];
        params[0] = new Param("uri", spotifyUri);
        params[1] = new Param("context", spotifyUri);

        spotifyJsonRequest("/remote/play.json", params);
    }

    Json spotifyJsonRequest(string spotifyRelativeUrl, Param[] params) {
        Param[] additionalParams = new Param[params.length + 2];

        for(int x = 0; x < params.length; x++) {
            additionalParams[x] = new Param(params[x].name, params[x].value);
        }

        additionalParams[params.length] = new Param("oauth", oauthToken);
        additionalParams[params.length + 1] = new Param("csrf", csrfToken);

        string url = helper.generateSpotifyUrl(spotifyRelativeUrl);
        return getJson(url, helper.getCommonHeaders(), additionalParams);
    }
}

class HelperFunctions {
    string host;
    Windows os;
    this() {
        host = generateRandomLocalHostName();
        os = new Windows();
        os.launchSpotifyWebHelper();
    }

    Header[] getCommonHeaders() {
        Header[] headers = new Header[3];
        headers[0] = new Header("Origin", "https://open.spotify.com");
        headers[1] = new Header("connection", "keep-alive");
        headers[2] = new Header("host", "localhost:80");
        return headers;
    }

    string generateRandomString(int length) {
        return iota(length).map!(_ => letters[uniform(0, $)]).array.toLower();
    }

    string generateRandomLocalHostName() {
        return format("%s%s", generateRandomString(10), ".spotilocal.com");
    }

    string generateSpotifyUrl(string path) {
        return format("https://%s:%d%s", host, DEFAULT_PORT, path);
    }

    string getOauthToken() {
        Json oauthTokenJson = getJson("http://open.spotify.com/token");
        string oauthToken = oauthTokenJson["t"].get!string;
        return oauthToken;
    }

    string getCsrfToken() {
        string url = generateSpotifyUrl("/simplecsrf/token.json");
        Json csrfTokenJson = getJson(url, getCommonHeaders());
        string csrfToken = csrfTokenJson["token"].get!string;
        return csrfToken;
    }
}
