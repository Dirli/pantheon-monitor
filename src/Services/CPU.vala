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

namespace Monitor {
    public class Services.CPU  : GLib.Object {
        private Structs.CpuData common_data;
        private Structs.CpuData[] commons_data;

        public int quantity_cores {
            get;
            construct set;
        }

        private int _percentage_used;

        public double frequency {
            get {
                double maxcur = 0;

                for (uint i = 0; i < _quantity_cores; ++i) {
                    var cur = 1000.0 * read_freq (i, "scaling_cur_freq");

                    if (i == 0) {
                        maxcur = cur;
                    } else {
                        maxcur = double.max (cur, maxcur);
                    }
                }

                return (double) maxcur;
            }
        }

        private double read_freq (uint cpu, string what) {
            string value;

            try {
                FileUtils.get_contents (@"/sys/devices/system/cpu/cpu$cpu/cpufreq/$what", out value);
            } catch (Error e) {
                value = "0";
            }

            return double.parse (value);
        }

        public int percentage_used {
            get {
                update_percentage_used ();
                return _percentage_used;
            }
        }

        public CPU () {
            Object (quantity_cores: (int) get_num_processors ());
        }

        construct {
            common_data = Structs.CpuData () {last_total = 0, last_used = 0};
            commons_data = {};

            int i = 0;
            while (quantity_cores > i++) {
                Structs.CpuData core = {};
                core.last_used = 0;
                core.last_total = 0;

                commons_data += core;
            }
        }

        public int[] get_percentage () {
            int[] return_arr = {};

            GTop.Cpu cpu;
            GTop.get_cpu (out cpu);

            for (int core = 0; core < quantity_cores; core++) {
                var used = cpu.xcpu_user[core] + cpu.xcpu_nice[core] + cpu.xcpu_sys[core];
        		var difference_used = (float) used - commons_data[core].last_used;
        		var difference_total = (float) cpu.xcpu_total[core] - commons_data[core].last_total;
        		var pre_percentage = difference_used.abs () / difference_total.abs ();

                return_arr += (int) Math.round(pre_percentage * 100);

                commons_data[core] = Structs.CpuData () {last_used = (float) used, last_total = (float) cpu.xcpu_total[core]};
            }

            return return_arr;
        }

        private void update_percentage_used () {
            GTop.Cpu cpu;
            GTop.get_cpu (out cpu);

    		var used = cpu.user + cpu.nice + cpu.sys;
    		var difference_used = (float) used - common_data.last_used;
    		var difference_total = (float) cpu.total - common_data.last_total;
    		var pre_percentage = difference_used.abs () / difference_total.abs ();

            _percentage_used = (int) Math.round(pre_percentage * 100);

            common_data = Structs.CpuData () {last_used = (float) used, last_total = (float) cpu.total};
        }
    }
}
