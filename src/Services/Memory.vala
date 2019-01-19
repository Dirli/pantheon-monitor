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
    public class Services.Memory  : GLib.Object {
        private int _percentage_used;
        private float _total;
        private float _used;
        public int percentage_used {
            get {
                update_percentage_used ();
                return _percentage_used;
            }
        }
        public float total {
            get {
                return _total;
            }
        }
        public float used {
            get {
                update_used ();
                return _used;
            }
        }

        public Memory (){
            this._percentage_used = 0;
            this._used = 0;
            update_total ();
            /* this._total = 0; */
        }

        private void update_percentage_used (){
            _percentage_used = (int) Math.round((used / total) * 100);
        }

        private void update_total (){
            GTop.Memory memory;
            GTop.get_mem (out memory);
            _total = (((float) memory.total / 1024) /1024) / 1024;
        }

        private void update_used (){
            GTop.Memory memory;
            GTop.get_mem (out memory);
            _used = (((float) memory.user / 1024) /1024) / 1024;
        }
    }
}
