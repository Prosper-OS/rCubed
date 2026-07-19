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

    
    function checkDecrypt(entry : ZipEntry) : Bool
    ;
    /**
		 *   initialize decrypto
		 */
    function initDecrypt(password : ByteArray, header : ZipHeader) : Void
    ;
    /**
		 *   decrypto
		 */
    function decrypt(data : ByteArray) : ByteArray
    ;
    
    /**
		 *   initialize encrypto
		 */
    function initEncrypt(password : ByteArray, header : ZipHeader) : Void
    ;
    
    /**
		 *  encrypto
		 */
    function encrypt(data : ByteArray) : ByteArray
    ;
}
