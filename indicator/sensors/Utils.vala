/*
 * Copyright (c) 2021 Dirli <litandrej85@gmail.com>
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

namespace Monitor.Sensors.Utils {
    private static string parse_temp (string temp_str) {
        if (temp_str == "") {
            return "0° C";
        }

        int temp_int = int.parse (temp_str) / 1000;
        return @"$(temp_int)° C";
    }

    private string get_content (string path) {
        string content;
        try {
            GLib.FileUtils.get_contents (Constants.HWMON_PATH + path, out content);
        } catch (GLib.Error e) {
            return "";
        }

        return content.chomp ();
    }

    private int compare_monitors (HWMonStruct? mon1, HWMonStruct? mon2) {
        if (mon1 == null) {return (mon2 == null) ? 0 : -1;}
        if (mon2 == null) {return 1;}
        if (mon1.name == Constants.AMD_CPU || mon1.name == Constants.INTEL_CPU) {return -1;}
        if (mon2.name == Constants.AMD_CPU || mon2.name == Constants.INTEL_CPU) {return 1;}
        if (mon1.name == Constants.NVIDIA_GPU || mon1.name == "radeon" || mon1.name == "nouveau") {return -1;}
        if (mon2.name == Constants.NVIDIA_GPU || mon2.name == "radeon" || mon2.name == "nouveau") {return 1;}
        if (mon1.name != "drivetemp" && mon1.name != "nvme") {return -1;}
        if (mon2.name != "drivetemp" && mon2.name != "nvme") {return 1;}

        if (mon1.name == "nvme") {return -1;}
        if (mon2.name == "nvme") {return 1;}

        return GLib.strcmp (mon1.label, mon2.label);
    }
}
