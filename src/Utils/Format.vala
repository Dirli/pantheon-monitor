/*
 * Copyright (c) 2018 Dirli <litandrej85@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

namespace Monitor.Utils {
    public uint64 parse_pretty (uint64 pretty, int unit) {
        switch (unit) {
            case 2:
                return pretty / 3600000;
            case 4:
                return (uint64) (pretty / 1000.0 - 273.15);
            case 7:
                // FIXME returns a value in gibibytes, but it is not exactly the
                // same as the one returned by smartmontools
                // return (uint64) ((pretty * 65536 * 512 / 1073741824) * 0.93132257461548);
                return (uint64) ((pretty * 65536 * 512) * 0.93132257461548);
            default:
                return pretty;

        }
    }

    // public static string pretty_to_string (uint64 pretty, int unit) {
    //     switch (unit) {
    //         case 2:
    //             return "%d".printf ((int) (pretty / 3600000));
    //         case 3:
    //             return @"$pretty bad sectors";
    //         case 4:
    //             var celcius = pretty / 1000.0 - 273.15;
    //             return "%.0f° C".printf (celcius);
    //         case 1:
    //         default:
    //             return @"$pretty";
    //     }
    // }

    public static string format_bytes (uint64 bytes, bool round = false) {
        string[] sizes = { "B/s", "KB/s", "MB/s", "GB/s", "TB/s" };
        double len = (double) bytes;
        int order = 0;
        string speed = "";

        while (len >= 1024 && order < sizes.length - 1) {
            order++;
            len = len / 1024;
        }

        if (bytes < 0) {
            len = 0;
            order = 0;
        }

        if (round == true) {
            speed = "%.1f %s".printf (len, sizes[order].split ("/")[0]);
        } else {
            if (order < 2) {
                speed = "%.0f %s".printf (len, sizes[order]);
            } else {
                speed = "%.1f %s".printf (len, sizes[order]);
            }
        }

        return speed;
    }

    public static string format_frequency (double val) {
        const string[] units = {
            " MHz",
            " GHz"
        };
        int index = -1;

        while (index + 1 < units.length && (val >= 1000 || index < 0)) {
            val /= 1000;
            ++index;
        }

        if (index < 0) {return "0";}

        if (val < 9.95) {
            return "%.1f %s".printf (val, units[index]);
        } else {
            return "%.0f %s".printf (val, units[index]);
        }
    }
}
