module processutils;

import std.process;
import std.stdio;
import std.string;

class ProcessUtils {
  string[] getRunningProcesses() {
    auto windowsPS = executeShell("wmic process GET caption");
    if(windowsPS.status != 0)
      return null;

    string[] windowsPSOutput = splitLines(windowsPS.output);

    return windowsPSOutput;
  }

  bool isProcessRunning(string name) {
    string[] processes = getRunningProcesses();
    foreach(string process; processes) {
      if(icmp(process, name)) {
        return true;
      }
      writeln(process);
    }
    return false;
  }
}
