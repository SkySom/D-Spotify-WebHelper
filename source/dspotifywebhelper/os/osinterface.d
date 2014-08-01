module os.osinterface;

interface os {
    string getSpotifyWebHelperPath();
    bool isSpotifyWebHelperRunning();
    void launchSpotifyWebHelperIfNeeded();
}
