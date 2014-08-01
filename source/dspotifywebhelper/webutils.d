module dspotifywebhelper.webutils;

import std.array;
import std.conv;
import std.encoding;
import std.stdio;
import std.net.curl;

import vibe.http.client;
import vibe.data.json;


Json getJson(string url, Header[] headers = new Header[0], Param[] params = new Param[0]) {
    auto queryUrl = appender!string();
    queryUrl.put(url);

    // for now this assumes that the program doesn't create two
    // different param objects with "" for both name and value.
    if(params.length > 0) {
        queryUrl.put("?");
        for(int x = 0; x < params.length; x++) {
            if(params[x].name == "" && params[x].value == "") {
                //...Need a better way to write this so if it is both "", then no. It was grabbing it if either were.
            }
            else {
                queryUrl.put(params[x].name);
                queryUrl.put("=");
                queryUrl.put(params[x].value);
                if(x+1 < params.length) {
                    queryUrl.put("&");
                }
            }
        }
    }

    Json json;
    try {
        requestHTTP(queryUrl.data,
            (scope req){
                if(headers.length > 0) {
                    foreach(Header head; headers) {
                        if(head.name != "" && head.value != "") {
                            req.headers[head.name] = head.value;
                        }
                    }
                }
            },
            (scope res){
                json = res.readJson();
            }
        );
    } catch(Exception exception) {
        writeln(exception.toString());
    }

    return json;
}

class Header {
    string name;
    string value;

    this(string nameValue, string valueValue) {
        name = nameValue;
        value = valueValue;
    }
}

class Param {
    string name;
    string value;

    this(string nameValue, string valueValue) {
        name = nameValue;
        value = valueValue;
    }
}
