
class URLs
{
    public static var protocol(never, set)                              : Dynamic;

    public static var ROOT_URL                              : Dynamic= "www.flashflashrevolution.com";
    
    public static var HTTP_PROTOCOL                              : Dynamic;
    public static var BASE_PATH                              : Dynamic;
    
    // Static Init
    
    
    /**
     * URL builder for base url and appended path.
     * @param path
     * @return Full URL
     */
    public static function resolve(path                              : Dynamic= "") : String
    {
        return BASE_PATH + path;
    }
    
    /**
     * Set the protocol used for url building. Only `http` and `https` are valid.
     * @param val Protocol
     */
    private static function set_protocol(val                              : Dynamic) : String
    // Only http/https are valid.
    {
        
        if (as3hx.Compat.truthy(val != "http" && val != "https"))
        {
            val = "https";
        }
        
        // Set
        HTTP_PROTOCOL = val;
        BASE_PATH = HTTP_PROTOCOL + "://" + ROOT_URL + "/";
        return val;
    }
    
    // Site URLs
    public static var SITE_DATA_URL                              : Dynamic= "game/r3/r3-siteData.v3.php";
    public static var SITE_PLAYLIST_URL                              : Dynamic= "game/r3/r3-playlist.php";
    public static var SITE_LANGUAGE_URL                              : Dynamic= "game/r3/r3-language.php";
    public static var SITE_HISCORES_URL                              : Dynamic= "game/r3/r3-hiscores.php";
    public static var SITE_REPLAYS_URL                              : Dynamic= "game/r3/r3-replays.php";
    public static var LEVEL_STATS_URL                              : Dynamic= "levelstats.php?level=";
    public static var CRASH_LOG_URL                              : Dynamic= "game/r3/r3-crashLog.php";
    
    // Song & Gameplay URLs
    public static var SONG_DATA_URL                              : Dynamic= "game/r3/r3-songLoad.php";
    public static var SONG_START_URL                              : Dynamic= "game/r3/r3-songStart.php";
    public static var SONG_SAVE_URL                              : Dynamic= "game/r3/r3-songSave.php";
    public static var SONG_RATING_URL                              : Dynamic= "game/r3/r3-songRating.php";
    public static var SONG_PURCHASE_URL                              : Dynamic= "game/r3/r3-songPurchase.php";
    public static var ALT_SONG_SAVE_URL                              : Dynamic= "game/r3/r3-songSaveOther.php";
    public static var MULTIPLAYER_SUBMIT_URL                              : Dynamic= "game/ffr-legacy_multiplayer.php";
    
    // User URLs
    public static var USER_REGISTER_URL                              : Dynamic= "vbz/register.php";
    public static var USER_LOGIN_URL                              : Dynamic= "game/r3/r3-siteLogin.php";
    public static var USER_INFO_URL                              : Dynamic= "game/r3/r3-userInfo.php";
    public static var USER_INFO_LITE_URL                              : Dynamic= "game/r3/r3-userSmallInfo.php";
    public static var USER_AVATAR_URL                              : Dynamic= "avatar_imgembedded.php";
    public static var USER_RANKS_URL                              : Dynamic= "game/r3/r3-userRanks.v2.php";
    public static var USER_RANKS_UPDATE_URL                              : Dynamic= "game/r3/r3-userRankUpdate.php";
    public static var USER_FRIENDS_URL                              : Dynamic= "game/r3/r3-userFriends.php";
    public static var USER_SAVE_REPLAY_URL                              : Dynamic= "game/r3/r3-userReplay.php";
    public static var USER_LOAD_REPLAY_URL                              : Dynamic= "game/r3/r3-siteReplay.php";
    public static var USER_SAVE_SETTINGS_URL                              : Dynamic= "game/r3/r3-userSettings.php";
    public static var USER_STATS_URL                              : Dynamic= "game/r3/r3-userStats.php";
    
    // Unused URLs
    public static var SHOP_URL                              : Dynamic= "tools/ffrshop.php";
    public static var NOTESKIN_SWF_URL                              : Dynamic= "game/r3/noteskins/";
    public static var NOTESKIN_URL                              : Dynamic= "game/r3/r3-noteSkins.xml";

    public function new()
    {
    }
    private static var URLs_static_initializer = {
        {
            protocol = "https";
        };
        true;
    }

}

