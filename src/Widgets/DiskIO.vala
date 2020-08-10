/*
 * Copyright (c) 2020 Dirli <litandrej85@gmail.com>
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
    public class Widgets.DiskIO : Gtk.Box {
        private Tools.DrawDiskIO draw_diskio;

        public DiskIO () {
            orientation = Gtk.Orientation.VERTICAL;
            margin_start = 12;
            margin_end = 12;
            spacing = 8;
            hexpand = true;
            halign = Gtk.Align.FILL;
            valign = Gtk.Align.CENTER;

            var diskio_label = new Gtk.Label (_("Disk read/write"));
            add (diskio_label);

            draw_diskio = new Tools.DrawDiskIO ();
            draw_diskio.hexpand = true;

            add (draw_diskio);
        }

        public void clear_cache () {
            draw_diskio.clear_cache ();
        }

        public void update_values (uint64 read_value, uint64 write_value) {
            draw_diskio.add_values (read_value, write_value);
        }
    }
}
