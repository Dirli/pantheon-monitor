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
        private float last_total;
        private float last_used;

        private int _quantity_cores;
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
            get { update_percentage_used (); return _percentage_used; }
        }
        public int quantity_cores {
            get { return _quantity_cores; }
        }

        public CPU (){
            last_used = 0;
            last_total = 0;
        }

        construct {
            update_quantity_cores ();
        }

        private void update_percentage_used (){
            GTop.Cpu cpu;
            GTop.get_cpu (out cpu);

    		var used = cpu.user + cpu.nice + cpu.sys;                               // get cpu used
    		var difference_used = (float) used - last_used;                         // calculate the difference used
    		var difference_total = (float) cpu.total - last_total;                  // calculate the difference total
    		var pre_percentage = difference_used.abs () / difference_total.abs ();  // calculate the pre percentage

            _percentage_used = (int) Math.round(pre_percentage * 100);

            last_used = (float) used;
            last_total = (float) cpu.total;
        }

        private void update_quantity_cores (){
            _quantity_cores = (int) get_num_processors ();
        }
    }
}
