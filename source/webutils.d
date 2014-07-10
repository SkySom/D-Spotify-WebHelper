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

  auto queryUrl = appender!string();
  queryUrl.put(url);
  // for now this assumes that the program doesn't create two
  // different param objects with "" for both name and value.
  if(params.length > 1 || (params.length == 1 && params[0].name != "" && params[0].value != "")) {
    queryUrl.put("?");
    for(int x = 0; x < params.length; x++) {
      if(params[x].name == "" && params[0].value == "") {
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

  writeln(queryUrl.data);
  auto http = HTTP(queryUrl.data);
  http.method = HTTP.Method.get;

  if(headers.length > 1 || (headers.length == 1 && headers[0].name != "" && headers[0].value != "" )) {
    http.clearRequestHeaders();
    foreach(Header head; headers) {
      if(head.name != "" && head.value != "") {
        http.addRequestHeader(head.name, head.value);
      }
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
