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

namespace Monitor {
    public class Objects.DiskDrive : GLib.Object {
        public string model;
        public uint64 size;
        public string revision;
        public string serial;
        public string id;
        public string device;
        public string partition;
        public GLib.Icon drive_icon;

        private Gee.ArrayList<Structs.MonitorVolume?> volumes;

        private Gtk.ListStore? smart_store = null;
        private Structs.DriveSmart? smart = null;

        public bool has_smart {
            get {
                return smart != null;
            }
        }

        public DiskDrive () {
            volumes = new Gee.ArrayList <Structs.MonitorVolume?> ();
        }

        public Structs.DriveSmart? get_smart () {
            return smart;
        }

        public Gtk.ListStore? get_smart_store () {
            return smart_store;
        }

        public void add_smart (Structs.DriveSmart s, Gtk.ListStore s_store) {
            smart = s;
            smart_store = s_store;
        }

        public void add_volume (Structs.MonitorVolume vol) {
            volumes.add (vol);
        }

        public Gee.ArrayList<Structs.MonitorVolume?> get_volumes () {
            var volumes_arr = new Gee.ArrayList<Structs.MonitorVolume?> ();

            volumes.foreach ((vol) => {
                volumes_arr.add (vol);

                return true;
            });

            volumes_arr.sort (compare_volumes);

            return volumes_arr;
        }

        private int compare_volumes (Structs.MonitorVolume? vol1, Structs.MonitorVolume? vol2) {
            if (vol1 == null) {
                return (vol2 == null) ? 0 : -1;
            }

            if (vol2 == null) {
                return 1;
            }

            return GLib.strcmp (vol1.device, vol2.device);
        }
    }
}
