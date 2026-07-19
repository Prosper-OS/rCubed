package classes.replay;

import openfl.errors.Error;
import arc.ArcGlobals;
import classes.User;
import com.flashfla.utils.StringUtil;
import openfl.utils.ByteArray;
import game.GameOptions;

/**
 * A Class needed to pack and unpack a binary based R3 replay.
 *
 * The format of the current plays (as of version 1)
 *
 * [int] Total notes.
 *
 * for each note:
 *   [byte] ms time from song note time.
 *      The default judge window allows the number to be within the range of -128 - 127 at all times.
 *      A value of 0x7F is use to signify the note wasn't hit and should act as a miss.
 *
 * [int] Total Boos.
 *
 * for each boo:
 *   [byte] boo frame header.
 *      Consist of 8 bits:
 * 	       - 0: Left
 * 	       - 1: Down
 * 	       - 2: Up
 * 	       - 3: Right
 * 	       - 4: Extended Frame Size - Only set when more then 4 directions are required for this frame header. Such as 6 / 8 key files.
 * 	       - 5: Written Byte  - The time is <= 0x7F
 * 	       - 6: Written Short - The time is <= 0x7FFF
 * 	       - 7: Written Int   - The time is <= 0x7FFFFFFF
 *
 * 	[byte] [optional] direction frame bits
 *      This only exist if the "Extended Frame Size" bit is set in the header.
 *      Consist of 8 bits:
 * 	       - 0: P1 Up Left
 * 	       - 1: P1 Down Right
 * 	       - 2: P2 Left
 * 	       - 3: P2 Down
 * 	       - 4: P2 Up
 * 	       - 5: P2 Right
 * 	       - 6: P2 Up Left
 * 	       - 7: P2 Down Right
 *
 * 	[byte/short/int] boo time.
 * 	    The amount of ms since the last boo frame.
 * 	    The size is based on the bit from the header.
 */
class ReplayPack
{
    // 00000001
    public static var BIT_P1_LEFT : Int = (1 << 0);
    // 00000010
    public static var BIT_P1_DOWN : Int = (1 << 1);
    // 00000100
    public static var BIT_P1_UP : Int = (1 << 2);
    // 00001000
    public static var BIT_P1_RIGHT : Int = (1 << 3);
    // 00000001
    public static var BIT_P1_KEY_5 : Int = (1 << 0);
    // 00000010
    public static var BIT_P1_KEY_6 : Int = (1 << 1);
    
    // 00000100
    public static var BIT_P2_LEFT : Int = (1 << 2);
    // 00001000
    public static var BIT_P2_DOWN : Int = (1 << 3);
    // 00010000
    public static var BIT_P2_UP : Int = (1 << 4);
    // 00100000
    public static var BIT_P2_RIGHT : Int = (1 << 5);
    // 01000000
    public static var BIT_P2_KEY_5 : Int = (1 << 6);
    // 10000000
    public static var BIT_P2_KEY_6 : Int = (1 << 7);
    
    // 00010000
    public static var BIT_FRAME_EXTEND : Int = (1 << 4);
    // 00100000
    public static var BIT_PACK_BYTE : Int = (1 << 5);
    // 01000000
    public static var BIT_PACK_SHORT : Int = (1 << 6);
    // 10000000
    public static var BIT_PACK_INT : Int = (1 << 7);
    
    public static inline var MAGIC : String = "FBRF";
    public static inline var MAJOR_VER : Int = 1;
    public static inline var MINOR_VER : Int = 1;
    
    // value = MAJOR_VER * 1000 + MINOR_VER
    private static inline var SUPPORT_MIN_VER : Int = 1000;
    private static inline var SUPPORT_MAX_VER : Int = 1001;
    
    // because the checksum is assumed to be the last 4 bytes, changes to the format will
    // likely need the magic to change so that older engines won't try to parse a different
    // format as they didn't do support version range checks until 1.4.4
    // changing the magic will cause the replay parser on <1.4.4 to use the older json format
    // which will error out as the string isn't a json string and about the parsing
    
    public static function pack(binNotes : Array<ReplayBinFrame>, binBoos : Array<ReplayBinFrame>) : ByteArray
    // Generate Bin Replay Format
    {
        
        var binReplay : ByteArray = new ByteArray();
        
        // Write Placeholder size
        binReplay.writeUnsignedInt(0);
        
        // Write Note Judements
        binReplay.writeInt(binNotes.length);
        for (nx in 0...binNotes.length)
        {
            if (binNotes[nx] == null || Math.isNaN(binNotes[nx].time))
            {
                binReplay.writeByte(0x7F);
            }
            else
            {
                binReplay.writeByte(binNotes[nx].time);
            }
        }
        
        // Write Boos
        var booCount : Int = 0;
        var booPosition : Int = binReplay.position;
        binBoos.sort(compareTime);
        binReplay.writeInt(0);
        
        var LAST_TIME : Int = 0;
        
        for (nx in 0...binBoos.length)
        {
            var FRAME_HEADER : Int = 0;
            var EXTENDED_HEADER : Int = 0;
            
            var CUR_TIME : Int = binBoos[nx].time;
            var DIR_BIT : Int = getDirectionBit(binBoos[nx].direction);
            var DIR_CHECK : Bool = isExtendedDirection(binBoos[nx].direction);
            
            if (CUR_TIME < 0)
            {
                CUR_TIME = 0;
            }  // Should Never Happen!  
            
            var TIME_DIFF : Int = as3hx.Compat.parseInt(CUR_TIME - LAST_TIME);
            
            // Set Direction Bit
            if (DIR_CHECK)
            {
                FRAME_HEADER = FRAME_HEADER | BIT_FRAME_EXTEND;
                EXTENDED_HEADER = EXTENDED_HEADER | DIR_BIT;
            }
            else
            {
                FRAME_HEADER = FRAME_HEADER | DIR_BIT;
            }
            
            // Find Matching Time Boos, set bit if not set.
            while (nx < binBoos.length - 1)
            {
                if (binBoos[nx + 1].time == CUR_TIME)
                {
                    var TEMP_DIR_BIT : Int = getDirectionBit(binBoos[nx + 1].direction);
                    var TEMP_DIR_CHECK : Bool = isExtendedDirection(binBoos[nx + 1].direction);
                    
                    // Check time and if the frame direction bit isn't set.
                    if (TEMP_DIR_CHECK && (TEMP_DIR_BIT & EXTENDED_HEADER) == 0)
                    {
                        FRAME_HEADER = FRAME_HEADER | BIT_FRAME_EXTEND;
                        EXTENDED_HEADER = EXTENDED_HEADER | TEMP_DIR_BIT;
                    }
                    if (!TEMP_DIR_CHECK && (TEMP_DIR_BIT & FRAME_HEADER) == 0)
                    {
                        FRAME_HEADER = FRAME_HEADER | TEMP_DIR_BIT;
                    }
                    else
                    {
                        break;
                    }
                    nx++;
                }
                else
                {
                    break;
                }
            }
            
            // Set Pack Size
            if (TIME_DIFF > 0)
            {
                if (TIME_DIFF <= 0x7F)
                {
                    FRAME_HEADER = FRAME_HEADER | BIT_PACK_BYTE;
                }
                else if (TIME_DIFF <= 0x7FFF)
                {
                    FRAME_HEADER = FRAME_HEADER | BIT_PACK_SHORT;
                }
                else
                {
                    FRAME_HEADER = FRAME_HEADER | BIT_PACK_INT;
                }
            }
            
            // Write Boo Header
            binReplay.writeByte(FRAME_HEADER);
            if ((FRAME_HEADER & BIT_FRAME_EXTEND) != 0)
            {
                binReplay.writeByte(EXTENDED_HEADER);
            }
            
            // Write Boo Time
            if (TIME_DIFF > 0)
            {
                if (TIME_DIFF <= 0x7F)
                {
                    binReplay.writeByte(TIME_DIFF);
                }
                else if (TIME_DIFF <= 0x7FFF)
                {
                    binReplay.writeShort(TIME_DIFF);
                }
                else
                {
                    binReplay.writeInt(TIME_DIFF);
                }
            }
            LAST_TIME = CUR_TIME;
            booCount++;
        }
        
        // Update Boo Count
        binReplay.position = booPosition;
        binReplay.writeInt(booCount);
        
        // Write Length
        binReplay.position = 0;
        binReplay.writeUnsignedInt(binReplay.length - 4);
        
        return binReplay;
    }
    
    public static function unpack(ba : ByteArray, judgeOffset : Int = 0) : Dynamic
    {
        var note_array : Array<ReplayBinFrame> = [];
        var boo_array : Array<ReplayBinFrame> = [];
        
        try {
if (ba.length < 2)
            {
                return null;
            }
            
            ba.position = 0;
            
            // Get Notes
            var total_notes : Int = ba.readInt();
            as3hx.Compat.setArrayLength(note_array, total_notes);
            for (n in 0...total_notes)
            {
                if (ba[ba.position] == 0x7F)
                {
                    note_array[n] = new ReplayBinFrame(Math.NaN);
                    ba.readByte();
                }
                else
                {
                    note_array[n] = new ReplayBinFrame(ba.readByte() - judgeOffset);
                }
            }
            
            // Get Boos
            var boo_time : Int = 0;
            var total_boos : Int = ba.readInt();
            for (n in 0...total_boos)
            {
                var header : Int = ba.readByte();
                var ext : Int = 0;
                
                // Check Extended Header
                if ((header & BIT_FRAME_EXTEND) != 0)
                {
                    ext = ba.readByte();
                }
                
                // Get Boo Time
                var this_boo : Int = 0;
                if ((header & BIT_PACK_BYTE) != 0)
                {
                    boo_time += ba.readUnsignedByte();
                }
                else if ((header & BIT_PACK_SHORT) != 0)
                {
                    boo_time += ba.readUnsignedShort();
                }
                else if ((header & BIT_PACK_INT) != 0)
                {
                    boo_time += ba.readUnsignedInt();
                }
                
                // Fill Boo Array
                if ((header & BIT_P1_LEFT) != 0)
                {
                    boo_array.push(new ReplayBinFrame(boo_time, "L"));
                }
                if ((header & BIT_P1_DOWN) != 0)
                {
                    boo_array.push(new ReplayBinFrame(boo_time, "D"));
                }
                if ((header & BIT_P1_UP) != 0)
                {
                    boo_array.push(new ReplayBinFrame(boo_time, "U"));
                }
                if ((header & BIT_P1_RIGHT) != 0)
                {
                    boo_array.push(new ReplayBinFrame(boo_time, "R"));
                }
                
                if ((header & BIT_FRAME_EXTEND) != 0) {
if ((ext & BIT_P1_KEY_5) != 0)
                    {
                        boo_array.push(new ReplayBinFrame(boo_time, "X"));
                    }
                    if ((ext & BIT_P1_KEY_6) != 0)
                    {
                        boo_array.push(new ReplayBinFrame(boo_time, "X"));
                    }
                    if ((ext & BIT_P2_LEFT) != 0)
                    {
                        boo_array.push(new ReplayBinFrame(boo_time, "X"));
                    }
                    if ((ext & BIT_P2_DOWN) != 0)
                    {
                        boo_array.push(new ReplayBinFrame(boo_time, "X"));
                    }
                    if ((ext & BIT_P2_UP) != 0)
                    {
                        boo_array.push(new ReplayBinFrame(boo_time, "X"));
                    }
                    if ((ext & BIT_P2_RIGHT) != 0)
                    {
                        boo_array.push(new ReplayBinFrame(boo_time, "X"));
                    }
                    if ((ext & BIT_P2_KEY_5) != 0)
                    {
                        boo_array.push(new ReplayBinFrame(boo_time, "X"));
                    }
                    if ((ext & BIT_P2_KEY_6) != 0)
                    {
                        boo_array.push(new ReplayBinFrame(boo_time, "X"));
                    }
                }
            }
        }
        catch (e : Error)
        {
            return {
                error : true,
                note : note_array,
                boo : boo_array
            };
        }
        
        return {
            note : note_array,
            boo : boo_array
        };
    }
    
    /**
     * Gets the applicible bit based on the direction provided.
     * @param	dir Direction to get bit for.
     * @return The direction bit.
     */
    public static function getDirectionBit(dir : String) : Int
    {
        if (dir == "L")
        {
            return BIT_P1_LEFT;
        }
        if (dir == "D")
        {
            return BIT_P1_DOWN;
        }
        if (dir == "U")
        {
            return BIT_P1_UP;
        }
        if (dir == "R")
        {
            return BIT_P1_RIGHT;
        }
        return 0;
    }
    
    public static function isExtendedDirection(dir : String) : Bool
    {
        return dir != "L" && dir != "D" && dir != "U" && dir != "R";
    }
    
    public static function printBits(num : Int) : String
    {
        return StringUtil.pad(Std.string(num), 8, "0");
    }
    
    public static function checksum(bin : ByteArray, hasCheck : Bool = false) : Int
    {
        var ss : Int = bin.position;
        var cc : Int = 0xc0ffee;
        var aa : Int = 0;
        var ll : Int = Math.floor((bin.length - ((hasCheck) ? 4 : 0)) / 4);
        bin.position = 0;
        while (aa < ll)
        {
            cc = cc ^ bin.readInt();
            aa++;
        }
        bin.position = ss;
        return cc;
    }
    
    public static function writeSiteReplay(binReplayNotes : Array<ReplayBinFrame>, binReplayBoos : Array<ReplayBinFrame>) : ByteArray
    // No replay to make.
    {
        
        if (binReplayNotes.length == 0 && binReplayBoos.length == 0)
        {
            return null;
        }
        
        var binReplay : ByteArray = new ByteArray();
        binReplay.writeUTFBytes(MAGIC);
        binReplay.writeByte(MAJOR_VER);  // Major Version  
        binReplay.writeByte(MINOR_VER);  // Minor Version  
        binReplay.writeByte(0);  // Header Flag  
        binReplay.writeBytes(pack(binReplayNotes, binReplayBoos));  // Replay Pack  
        binReplay.writeUnsignedInt(checksum(binReplay));
        return binReplay;
    }
    
    public static function writeReplay(activeUser : User, options : GameOptions, judgements : String, binReplayNotes : Array<ReplayBinFrame>, binReplayBoos : Array<ReplayBinFrame>) : ByteArray
    // No replay to make.
    {
        
        if (binReplayNotes.length == 0 && binReplayBoos.length == 0)
        {
            return null;
        }
        
        // No Custom Judge Windows, not supported.
        if (options.judgeWindow)
        {
            return null;
        }
        
        // Get Alt engine Settings
        var settings : Dynamic = options.settingsEncode();
        if (options.song.songInfo.engine)
        {
            settings.arc_engine = ArcGlobals.instance.legacyEncode(options.song.songInfo);
        }
        
        var timestamp : Float = Math.floor(Date.now().getTime() / 1000);
        var settingsEncode : String = haxe.Json.stringify(settings);
        var binReplay : ByteArray = new ByteArray();
        binReplay.writeUTFBytes(MAGIC);
        binReplay.writeByte(MAJOR_VER);  // Major Version  
        binReplay.writeByte(MINOR_VER);  // Minor Version  
        binReplay.writeByte(1);  // Header Flag  
        binReplay.writeUnsignedInt(activeUser.siteId);  // Userid  
        binReplay.writeUnsignedInt(options.song.id);  // Song ID  
        binReplay.writeFloat(options.songRate); // Song Rate  ;
        binReplay.writeUnsignedInt(timestamp);
        binReplay.writeUTF(judgements);
        binReplay.writeUTF(settingsEncode);
        binReplay.writeBytes(pack(binReplayNotes, binReplayBoos));  // Replay Pack  
        binReplay.writeUnsignedInt(checksum(binReplay));
        
        if (!verifyReplayWrite(binReplay, activeUser, options, judgements, binReplayNotes, binReplayBoos, settingsEncode, timestamp))
        {
            return null;
        }
        
        return binReplay;
    }
    
    public static function readReplay(ba : ByteArray, ignoreOffset : Bool = false) : ReplayPacked
    {
        var replay : ReplayPacked = new ReplayPacked();
        ba.position = 0;
        var checksumCheck : Int = checksum(ba, true);
        try {
replay.MAGIC = ba.readUTFBytes(4);
            replay.MAJOR_VER = ba.readByte();
            replay.MINOR_VER = ba.readByte();
            
            if (replay.VERSION > SUPPORT_MAX_VER || replay.VERSION < SUPPORT_MIN_VER)
            {
                replay.error = "Unsupported Replay Version";
                ba.position = 0;
                return replay;
            }
            
            var judgeOffset : Int = 0;
            var hasHeader : Bool = ba.readByte() == 1;
            
            // Play Data
            if (hasHeader)
            {
                replay.user_id = ba.readUnsignedInt();
                replay.song_id = ba.readUnsignedInt();
                replay.song_rate = ba.readFloat();
                replay.timestamp = ba.readUnsignedInt();
                replay.raw_judgements = ba.readUTF();
                replay.raw_settings = ba.readUTF();
                replay.judgements = haxe.Json.parse(replay.raw_judgements);
                replay.settings = haxe.Json.parse(replay.raw_settings);
                
                if (!ignoreOffset)
                {
                    judgeOffset = as3hx.Compat.parseInt(replay.settings.judgeOffset * 1000 / 30);
                }
            }
            
            // Replay Data
            var len : Int = ba.readUnsignedInt();
            var packed_replay : ByteArray = new ByteArray();
            ba.readBytes(packed_replay, 0, len);
            var unpacked_replay : Dynamic = unpack(packed_replay, judgeOffset);
            if (unpacked_replay != null)
            {
                replay.rep_notes = Reflect.field(unpacked_replay, "note");
                replay.rep_boos = Reflect.field(unpacked_replay, "boo");
            }
            
            // Checksum
            replay.checksum = ba.readUnsignedInt();
            replay.rechecksum = checksumCheck;
            replay.replay_bin = ba;
            
            replay.update();
        }
        catch (e : Error)
        {
            return null;
        }
        ba.position = 0;
        return replay;
    }
    
    private static function verifyReplayWrite(binReplay : ByteArray, activeUser : User, options : GameOptions, judgements : String, binReplayNotes : Array<ReplayBinFrame>, binReplayBoos : Array<ReplayBinFrame>, settingsEncode : String, timestamp : Float) : Bool
    // Read Replay to Verify Write
    {
        
        var test : ReplayPacked = readReplay(binReplay, true);
        if (test == null)
        {
            trace("test is null, complete fail");
            return false;
        }
        if (test.error != null)
        {
            trace("replay error set", test.error);
            return false;
        }
        if (MAGIC != test.MAGIC)
        {
            trace("MAGIC failed comparison", MAGIC, test.MAGIC);
            return false;
        }
        if (MAJOR_VER != test.MAJOR_VER)
        {
            trace("MAJOR_VER failed comparison", MAJOR_VER, test.MAJOR_VER);
            return false;
        }
        if (MINOR_VER != test.MINOR_VER)
        {
            trace("MINOR_VER failed comparison", MINOR_VER, test.MINOR_VER);
            return false;
        }
        if (activeUser.siteId != test.user_id)
        {
            trace("user_id failed comparison", activeUser.siteId, test.user_id);
            return false;
        }
        if (options.song.id != test.song_id)
        {
            trace("song_id failed comparison", options.song.id, test.song_id);
            return false;
        }
        if (options.songRate.toFixed(3) != test.song_rate.toFixed(3))
        {
            trace("song_rate failed comparison", options.songRate, test.song_rate);
            return false;
        }
        if (timestamp != test.timestamp)
        {
            trace("timestamp failed comparison", timestamp, test.timestamp);
            return false;
        }
        if (judgements != test.raw_judgements)
        {
            trace("raw_judgements failed comparison", judgements, test.raw_judgements);
            return false;
        }
        if (settingsEncode != test.raw_settings)
        {
            trace("raw_settings failed comparison", settingsEncode, test.raw_settings);
            return false;
        }
        
        // Compare Notes
        if (test.rep_notes == null)
        {
            trace("rep_notes is NULL");
            return false;
        }
        if (binReplayNotes.length != test.rep_notes.length)
        {
            trace("rep_notes length doesn't match", binReplayNotes.length, test.rep_notes.length);
            return false;
        }
        var compareFailure : Int = 0;
        for (i in 0...binReplayNotes.length) {
if ((binReplayNotes[i] == null && test.rep_notes[i] != null) || (binReplayNotes[i] != null && test.rep_notes[i] == null))
            {
                trace("rep_notes[" + i + "] & binReplayNotes[" + i + "] have different NULL states.");
                compareFailure++;
            }
            else if (binReplayNotes[i] == null && test.rep_notes[i] == null)
            {
                continue;
            }
            // NaN compare (NaN != NaN)
            else if ((Math.isNaN(binReplayNotes[i].time) && !Math.isNaN(test.rep_notes[i].time)) || (!Math.isNaN(binReplayNotes[i].time) && Math.isNaN(test.rep_notes[i].time)))
            {
                trace("rep_notes[" + i + "].time & binReplayNotes[" + i + "].time have different NaN states.");
                compareFailure++;
            }
            else if (Math.isNaN(binReplayNotes[i].time) && Math.isNaN(test.rep_notes[i].time))
            {
                continue;
            }
            // time compare
            else if (binReplayNotes[i].time != test.rep_notes[i].time)
            {
                trace("rep_notes[" + i + "].time", binReplayNotes[i].time, "!=", test.rep_notes[i].time);
                compareFailure++;
            }
        }
        if (compareFailure > 0)
        {
            trace("rep_notes had", compareFailure, "incorrect matchings");
            return false;
        }
        
        // Compare Boos
        if (test.rep_boos == null)
        {
            trace("rep_boos is NULL");
            return false;
        }
        if (binReplayBoos.length != test.rep_boos.length)
        {
            trace("rep_boos length doesn't match", binReplayBoos.length, test.rep_boos.length);
            return false;
        }
        // TODO: Boos are re-ordered when packed as they can appear in any order but are
        // unpacked in a fixed order, causing false positives.
        /*
           compareFailure = 0;
           for (i = 0; i < binReplayBoos.length; i++)
           {
           if (binReplayBoos[i]["d"] != test.rep_boos[i]["d"])
           {
           trace("rep_boos[" + i + "][d]", binReplayBoos[i]["d"], "!=", test.rep_boos[i]["d"], "(" + binReplayBoos[i]["t"], test.rep_boos[i]["t"] + ")");
           compareFailure++;
           }
           if (binReplayBoos[i]["t"] != test.rep_boos[i]["t"])
           {
           trace("rep_boos[" + i + "][t]", binReplayBoos[i]["t"], "!=", test.rep_boos[i]["t"], "(" + binReplayBoos[i]["d"], test.rep_boos[i]["d"] + ")");
           compareFailure++;
           }
           }
           if (compareFailure > 0)
           {
           trace("rep_boos had", compareFailure, "incorrect matchings");
           return false;
           }
         */
        return true;
    }
    
    private static function compareTime(frame1 : ReplayBinFrame, frame2 : ReplayBinFrame) : Float
    {
        if (frame1.time < frame2.time)
        {
            return -1;
        }
        else if (frame1.time > frame2.time)
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }

    public function new()
    {
    }
}


