/**
 *  Copyright (c)  2009 coltware@gmail.com
 *  http://www.coltware.com 
 *
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 */
package com.coltware.airxzip.crypt;

import com.coltware.airxzip.ZipEntry;
import com.coltware.airxzip.ZipHeader;
import openfl.utils.ByteArray;

interface ICrypto
{

    
    function checkDecrypt(entry                            : Dynamic) : Bool
    ;
    /**
		 *   initialize decrypto
		 */
    function initDecrypt(password                            : Dynamic, header                            : Dynamic) : Void
    ;
    /**
		 *   decrypto
		 */
    function decrypt(data                            : Dynamic) : ByteArray
    ;
    
    /**
		 *   initialize encrypto
		 */
    function initEncrypt(password                            : Dynamic, header                            : Dynamic) : Void
    ;
    
    /**
		 *  encrypto
		 */
    function encrypt(data                            : Dynamic) : ByteArray
    ;
}
