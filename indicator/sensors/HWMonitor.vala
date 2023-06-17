/*
 * Copyright (c) 2018-2021 Dirli <litandrej85@gmail.com>
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

namespace Monitor {
    public class Sensors.HWMonitor : GLib.Object {
        public signal void fetch_sensor (string key, string val);

        private Gee.HashMap<string, string> sens_hash;
        private string default_monitor = "";

        public HWMonitor () {
            sens_hash = new Gee.HashMap<string, string> ();

            if (GLib.FileUtils.test (Constants.HWMON_PATH, GLib.FileTest.IS_DIR)) {
                init_hwmons ();
            }
        }

        private void init_hwmons () {
            bool has_video = false;
            find_hw_monitors ().foreach ((hwm) => {
                var hwm_name = Utils.get_content (@"$hwm/name");
                var sensors_str = find_hwm_sensors (Constants.HWMON_PATH + hwm);

                if (sensors_str != "") {
                    if (hwm_name.chomp () == Constants.INTEL_CPU || hwm_name.chomp () == Constants.AMD_CPU) {
                        default_monitor = hwm;
                    }

                    sens_hash[hwm] = sensors_str;
                }


                if (hwm_name.chomp () == "radeon" || hwm_name.chomp () == "nouveau") {
                    has_video = true;
                }

                return true;
            });

            if (!has_video) {
                if (GLib.FileUtils.test ("/usr/bin/nvidia-settings", GLib.FileTest.IS_EXECUTABLE)) {
                    sens_hash[Constants.NVIDIA_GPU] = "temp";
                }
            }
        }

        private Gee.HashSet<string> find_hw_monitors () {
            string? name = null;
            Gee.HashSet<string> hwm_set = new Gee.HashSet<string> ();
            try {
                GLib.Dir dir = GLib.Dir.open (Constants.HWMON_PATH, 0);
                while ((name = dir.read_name ()) != null) {
                    hwm_set.add (name);
                }

            } catch (GLib.Error e) {
                warning (e.message);
            }

            return hwm_set;
        }

        private string find_hwm_sensors (string hwm_path) {
            string name = "";

            var sens_arr = new Gee.ArrayList<string> ();

            try {
                GLib.Regex regex = new GLib.Regex ("^temp[0-9]_input");
                GLib.Dir dir = GLib.Dir.open (hwm_path, 0);
                while ((name = dir.read_name ()) != null) {
                    if (regex.match (name)) {
                        sens_arr.add (name.split ("_")[0]);
                    }
                }
            } catch (GLib.Error e) {
                warning (e.message);
            }

            string sens_string = "";
            if (sens_arr.size > 1) {
                sens_arr.sort (Utils.compare_sensors);

                sens_string = string.joinv (",", sens_arr.to_array ());
            } else if (sens_arr.size == 1) {
                sens_string = sens_arr[0];
            }

            return sens_string;
        }

        public Gee.ArrayList<HWMonStruct?> get_hwmonitors () {
            var hwmons_arr = new Gee.ArrayList<HWMonStruct?> ();

            sens_hash.@foreach ((entry) => {
                if (entry.key == Constants.NVIDIA_GPU) {
                    HWMonStruct nvidia_struct = {};
                    nvidia_struct.name = entry.key;
                    nvidia_struct.label = entry.key;
                    nvidia_struct.path = entry.key;

                    hwmons_arr.add (nvidia_struct);
                    return true;
                }

                var monitor_name = Utils.get_content (@"$(entry.key)/name");

                HWMonStruct hwmon_struct = {};
                hwmon_struct.name = monitor_name;
                hwmon_struct.label = monitor_name;
                hwmon_struct.path = entry.key;

                if (monitor_name == "drivetemp") {
                    if (GLib.FileUtils.test (Constants.HWMON_PATH + @"$(entry.key)/device/model", GLib.FileTest.IS_REGULAR)) {
                        var new_label = Utils.get_content (@"$(entry.key)/device/model").chomp ();
                        if (new_label != "") {
                            hwmon_struct.label = new_label;
                        }
                    }
                }

                hwmons_arr.add (hwmon_struct);

                return true;
            });

            hwmons_arr.sort (Utils.compare_monitors);

            return hwmons_arr;
        }

        public Gee.ArrayList<SensorStruct?> get_hwmon_sensors (string path) {
            var sensors_arr = new Gee.ArrayList<SensorStruct?> ();

            if (!sens_hash.has_key (path)) {
                return sensors_arr;
            }

            if (path == Constants.NVIDIA_GPU) {
                SensorStruct nvidia_sensor = {};
                nvidia_sensor.label = "temp";
                nvidia_sensor.key = Constants.NVIDIA_GPU;

                sensors_arr.add (nvidia_sensor);
            } else {
                foreach (string sensor in sens_hash[path].split (",")) {
                    SensorStruct sens_struct = {};

                    var sensor_label = Utils.get_content (@"$(path)/$(sensor)_label");
                    if (sensor_label == "") {
                        sensor_label = sensor;
                    }

                    sens_struct.label = sensor_label;

                    var sensor_tooltip = Utils.get_content (@"$(path)/$(sensor)_max");
                    if (sensor_tooltip != "") {
                        sens_struct.tooltip = sensor_tooltip;
                    }

                    sens_struct.key = @"$(path):$(sensor)";

                    sensors_arr.add (sens_struct);
                }
            }

            return sensors_arr;
        }

        public bool update_sensors (bool extended) {
            if (!extended) {
                if (default_monitor == "") {
                    return false;
                }

                int temp_val, temp_max = 0;
                string temp_cur;
                string sens_str = sens_hash[default_monitor];

                foreach (string sensor in sens_str.split(",")) {
                    temp_cur = Utils.get_content (@"$(default_monitor)/$(sensor)_input");
                    temp_val = int.parse (temp_cur) / 1000;
                    if (temp_val > temp_max) {
                        temp_max = temp_val;
                    }
                }

                fetch_sensor ("", @"$(temp_max)");
            } else {
                if (sens_hash.size == 0) {
                    return false;
                }

                foreach (var entry in sens_hash.entries) {
                    if (entry.key == Constants.NVIDIA_GPU) {
                        try {
                            string ls_stdout;
                            GLib.Process.spawn_command_line_sync ("nvidia-settings -q [gpu:0]/gpucoretemp -t", out ls_stdout, null, null);

                            fetch_sensor (Constants.NVIDIA_GPU, @"$(int.parse (ls_stdout) * 1000)");
                        } catch (SpawnError e) {
                            warning (e.message);
                        }
                    } else {
                        foreach (string sensor in entry.value.split(",")) {
                            fetch_sensor (@"$(entry.key):$(sensor)", Utils.get_content (@"$(entry.key)/$(sensor)_input"));
                        }
                    }
                }
            }

            return true;
        }
    }
}
