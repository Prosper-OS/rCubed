/**
 *  Copyright (c)  2009 coltware@gmail.com
 *  http://www.coltware.com 
 *
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 */
package com.coltware.airxzip;

import openfl.errors.Error;

class ZipError extends Error
{
    public function new(message                            : Dynamic= "", id                            : Dynamic= 0)
    {
        super(message, id);
    }
}
