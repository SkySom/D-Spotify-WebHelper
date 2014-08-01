module dspotifywebhelper.os.windows;

import std.path;
import std.process;

import dspotifywebhelper.os.osinterface;
import dspotifywebhelper.processutils;

class Windows : os {
    string getSpotifyWebHelperPath() {
        if(!environment.get("USERPROFILE")) {
            return null;
        }

        return buildPath(environment.get("USERPROFILE"),
            "AppData\\Roaming\\Spotify\\Data\\SpotifyWebHelper.exe");
    }

    bool isSpotifyWebHelperRunning() {
        auto processUtils = new ProcessUtils();
        if(processUtils.isProcessRunning("spotifywebhelper.exe")) {
            return true;
        }
        return false;
    }

    void launchSpotifyWebHelper() {
        if(!isSpotifyWebHelperRunning()) {
            string exePath = getSpotifyWebHelperPath();
            if(exePath != null) {
                spawnProcess(exePath);
            }
        }
    }
}
