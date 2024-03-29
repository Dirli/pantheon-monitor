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
    public class Widgets.DiskIO : Gtk.Grid {
        private Tools.DrawDiskIO draw_diskio;

        public Gdk.RGBA foreground_color {
            set {
                draw_diskio.f_color = value;
            }
        }

        public DiskIO () {
            Object (orientation: Gtk.Orientation.VERTICAL,
                    row_spacing: 8,
                    column_spacing: 8,
                    hexpand: true,
                    margin_start: 12,
                    margin_end: 12,
                    margin_top: 12,
                    margin_bottom: 12,
                    halign: Gtk.Align.FILL);
        }

        construct {
            var diskio_label = new Gtk.Label (_("Disk read/write"));
            diskio_label.halign = Gtk.Align.START;
            diskio_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

            draw_diskio = new Tools.DrawDiskIO ();

            var view_btns = new Granite.Widgets.ModeButton ();
            view_btns.homogeneous = false;
            view_btns.halign = Gtk.Align.END;

            view_btns.append (new Gtk.Label (_("All")));
            view_btns.append (new Gtk.Label (_("Write")));
            view_btns.append (new Gtk.Label (_("Read")));


            attach (diskio_label, 0, 0);
            attach (view_btns, 1, 0);
            attach (draw_diskio, 0, 1, 2);

            view_btns.selected = 0;
            view_btns.mode_changed.connect (() => {
                draw_diskio.view_io = (Enums.ViewIO) view_btns.selected;
            });
        }

        public void clear_cache () {
            draw_diskio.clear_cache ();
        }

        public void update_values (uint64 read_value, uint64 write_value) {
            draw_diskio.add_values (read_value, write_value);
        }
    }
}
