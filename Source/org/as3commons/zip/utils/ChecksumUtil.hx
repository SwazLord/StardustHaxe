/*
* Copyright 2007-2012 the original author or authors.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*      http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
package org.as3commons.zip.utils;

import flash.utils.ByteArray;

/**
	 * @author Claus Wahlers
	 * @author Max Herkender
	 */
@:final class ChecksumUtil
{
    /**
		 * @private
		 */
    private static var crcTable : Array<Dynamic> = makeCRCTable();
    
    /**
		 * @private
		 */
    private static function makeCRCTable() : Array<Dynamic>
    {
        var table : Array<Dynamic> = [];
        var i : Int;
        var j : Int;
        var c : Int;
        for (i in 0...256)
        {
            c = i;
            for (j in 0...8)
            {
                if ((c & 1) != 0)
                {
                    c = 0xEDB88320 ^ as3hx.Compat.parseInt(c >>> 1);
                }
                else
                {
                    c >>>= 1;
                }
            }
            table.push(c);
        }
        return table;
    }
    
    /**
		 * Calculates a CRC-32 checksum over a ByteArray
		 *
		 * @see http://www.w3.org/TR/PNG/#D-CRCAppendix
		 *
		 * @param data
		 * @param len
		 * @param start
		 * @return CRC-32 checksum
		 */
    public static function CRC32(data : ByteArray, start : Int = 0, len : Int = 0) : Int
    {
        if (start >= data.length)
        {
            start = data.length;
        }
        if (len == 0)
        {
            len = as3hx.Compat.parseInt(data.length - start);
        }
        if (len + start > data.length)
        {
            len = as3hx.Compat.parseInt(data.length - start);
        }
        var i : Int;
        var c : Int = 0xffffffff;
        for (i in start...len)
        {
            c = as3hx.Compat.parseInt(crcTable[as3hx.Compat.parseInt(c ^ data[i]) & 0xff]) ^ as3hx.Compat.parseInt(c >>> 8);
        }
        return as3hx.Compat.parseInt(c ^ 0xffffffff);
    }
    
    /**
		 * Calculates an Adler-32 checksum over a ByteArray
		 *
		 * @see http://en.wikipedia.org/wiki/Adler-32#Example_implementation
		 *
		 * @param data
		 * @param len
		 * @param start
		 * @return Adler-32 checksum
		 */
    public static function Adler32(data : ByteArray, start : Int = 0, len : Int = 0) : Int
    {
        if (start >= data.length)
        {
            start = data.length;
        }
        if (len == 0)
        {
            len = as3hx.Compat.parseInt(data.length - start);
        }
        if (len + start > data.length)
        {
            len = as3hx.Compat.parseInt(data.length - start);
        }
        var i : Int = start;
        var a : Int = 1;
        var b : Int = 0;
        while (i < (start + len))
        {
            a = as3hx.Compat.parseInt((a + data[i]) % 65521);
            b = as3hx.Compat.parseInt((a + b) % 65521);
            i++;
        }
        return as3hx.Compat.parseInt((b << 16) | a);
    }

    public function new()
    {
    }
}

