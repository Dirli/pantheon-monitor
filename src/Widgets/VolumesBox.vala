/*
 * Copyright (c) 2018-2020 Dirli <litandrej85@gmail.com>
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
    public class Widgets.VolumesBox : Gtk.Box {
        public signal void changed_box_size (Gtk.Box widget, string did, Gtk.Allocation allocation);

        private int current_width = 0;

        public string device_id {
            get;
            construct set;
        }

        public VolumesBox (string did) {
            Object (orientation: Gtk.Orientation.HORIZONTAL,
                    hexpand: true,
                    spacing: 0,
                    device_id: did);

            get_style_context ().add_class ("volumes");

            size_allocate.connect ((allocation) => {
                if (current_width != allocation.width) {
                    current_width = allocation.width;
                    changed_box_size (this, device_id, allocation);
                }
            });
        }

        public override void get_preferred_height (out int minimum_height, out int natural_height) {
            minimum_height = 62;
            natural_height = 62;
        }
    }
}
