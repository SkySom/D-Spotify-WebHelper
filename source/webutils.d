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
  // for now this assumes that the program doesn't create two
  // different param objects with "" for both name and value.
  if(params.length > 1 || (params.length == 1 && params[0].name == "" && params[0].value == "")) {
    auto queryUrl = appender!string();
    queryUrl.put(url);
    queryUrl.put("?");
    foreach(Param para; params) {
      queryUrl.put(para.name);
      queryUrl.put("=");
      queryUrl.put(para.value);
    }
  }

  auto http = HTTP(url);
  http.method = HTTP.Method.get;

  foreach(Header head; headers) {
    if(head.name != "" && head.value != "") {
      http.addRequestHeader(head.name, head.value);
    }
  }

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
