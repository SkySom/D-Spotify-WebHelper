module dspotifywebhelper.os.osinterface;

interface os {
    string getSpotifyWebHelperPath();
    bool isSpotifyWebHelperRunning();
    void launchSpotifyWebHelper();
}
