module webutils;

import std.array;
import std.conv;
import std.encoding;
import std.json;
import std.stdio;
import std.net.curl;

JSONValue getJson(string url) {
  auto contentString = get(url);
  auto contentJson = parseJSON(contentString);
  return contentJson;
}

JSONValue getJson(string url, Header[] headers) {
  Param[1] params = new Param("", "");
  return getJson(url, headers, params);
}

JSONValue getJson(string url, Param[] params) {
  Header[1] headers = new Header("", "");
  return getJson(url, headers, params);
}

JSONValue getJson(string url, Header[] headers, Param[] params) {
  auto returned = appender!string();
  auto http = HTTP(url);
  http.method = HTTP.Method.get;
  http.onReceive = (ubyte[] data) {
    foreach(ubyte u; data) {
      returned.put(to!char(u));
    }
    return data.length;
  };
  http.perform();
  JSONValue json = parseJSON(returned.data);
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
