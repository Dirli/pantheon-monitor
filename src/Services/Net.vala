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
    public class Services.Net  : GLib.Object {
        public signal void new_max_value (int max_val);
        private int _bytes_in_old;
        private int _bytes_out_old;
        private bool first_get;

        private int _max_speed;
        private int max_speed {
            get {
                return _max_speed;
            }
            set {
                _max_speed = value;
                new_max_value (_max_speed);
            }
        }

        private int[] _percentage_used;
        public int percentage_up {
            get {
                return _percentage_used[0];
            }
        }

        /* public int bytes_in_down {
            get {
                return (int) Math.fabs( _bytes_in_old);
            }
        } */
        /* public int bytes_in_up {
            get {
                return _bytes_out_old;
            }
        } */

        public int percentage_down {
            get {
                return _percentage_used[1];
            }
        }

        public Net () {
            _max_speed = 0;
            first_get = true;
            _bytes_in_old = 0;
            _bytes_out_old = 0;
            _percentage_used = {0, 0};
            update_bytes (true);
        }

        public int[] update_bytes (bool first_step) {
            if (first_get) {
                first_get = false;
                return {0, 0};
            }
            GTop.NetList netlist;
            GTop.NetLoad netload;
            var devices = GTop.get_netlist (out netlist);
            var n_bytes_out = 0;
            var n_bytes_in = 0;
            for (uint j = 0; j < netlist.number; ++j) {
                var device = devices[j];
                if (device != "lo" && device.substring (0, 3) != "tun") {
                    GTop.get_netload (out netload, device);
                    n_bytes_out += (int) netload.bytes_out;
                    n_bytes_in += (int) netload.bytes_in;
                }
            }

            int _bytes_out = (n_bytes_out - _bytes_out_old) / 1;
            int _bytes_in = (n_bytes_in - _bytes_in_old) / 1;
            update_percentage_used (_bytes_out, _bytes_in);
            _bytes_out_old = n_bytes_out;
            _bytes_in_old = n_bytes_in;

            if (!first_step) {
                var tmp_val = int.max (_bytes_out, _bytes_in);
                tmp_val = (int) Math.round ((double) tmp_val / 1048576 + 0.5);
                if (tmp_val > max_speed) {
                    max_speed = tmp_val;
                }
            }

            return {_bytes_out, _bytes_in};
        }

        private void update_percentage_used (int bytes_out, int bytes_in) {
            double bytes_speed = max_speed == 0 ? 5 * 1048576.0 : max_speed * 1048576.0;
            _percentage_used[0] = (int) Math.round((bytes_out / bytes_speed) * 100);
            _percentage_used[1] = (int) Math.round((bytes_in / bytes_speed) * 100);
        }
    }
}
