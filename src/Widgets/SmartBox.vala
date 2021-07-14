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
    public class Widgets.SmartBox : Gtk.Grid {
        public signal void show_smart ();

        private int current_height = 0;

        private Gtk.Box life_area_wrapper;

        public Structs.DriveSmart smart { get; construct set; }

        public SmartBox (Structs.DriveSmart s) {
            Object (orientation: Gtk.Orientation.VERTICAL,
                    column_spacing: 8,
                    row_spacing: 8,
                    vexpand: true,
                    valign: Gtk.Align.FILL,
                    smart: s);
        }

        construct {
            var box_label = new Gtk.Label ("S.M.A.R.T.:");

            var info_btn = new Gtk.Button.from_icon_name ("help-info-symbolic", Gtk.IconSize.BUTTON);
            info_btn.tooltip_text = _("Show smart");
            info_btn.can_focus = false;
            info_btn.clicked.connect (() => {
                show_smart ();
            });

            var btns_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
            btns_box.add (info_btn);

            var hours_label = new Gtk.Label (_("Total hours:"));
            hours_label.halign = Gtk.Align.END;
            var hours_val = new Gtk.Label (@"$(smart.power_seconds / 3600) h.");
            hours_val.halign = Gtk.Align.START;

            var counts_label = new Gtk.Label (_("Total power-on:"));
            counts_label.halign = Gtk.Align.END;
            var counts_val = new Gtk.Label (@"$(smart.power_counts)");
            counts_val.halign = Gtk.Align.START;

            var write_label = new Gtk.Label (_("Total write:"));
            write_label.halign = Gtk.Align.END;
            var write_val = new Gtk.Label (@"$(smart.total_write != 0 ? Utils.format_bytes (smart.total_write, true) : "--")");
            write_val.halign = Gtk.Align.START;

            life_area_wrapper = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            life_area_wrapper.vexpand = true;
            life_area_wrapper.valign = Gtk.Align.FILL;
            life_area_wrapper.size_allocate.connect (on_size_allocate);

            var top = 0;
            attach (box_label, 0, top++, 2);
            attach (hours_label, 0, top);
            attach (hours_val, 1, top++);
            attach (counts_label, 0, top);
            attach (counts_val, 1, top++);
            attach (write_label, 0, top);
            attach (write_val, 1, top++);
            attach (life_area_wrapper, 0, top, 2);
            attach (btns_box, 2, 0, 1, top);
        }

        private void on_size_allocate (Gtk.Allocation area_alloc) {
            if (area_alloc.height > 0 && area_alloc.height != current_height) {
                current_height = area_alloc.height;
                life_area_wrapper.size_allocate.disconnect (on_size_allocate);

                GLib.Idle.add (() => {
                    var draw_smart = new Tools.DrawSmart (smart.life_left, smart.failing, area_alloc);

                    life_area_wrapper.add (draw_smart);
                    draw_smart.show ();

                    return false;
                });
            }
        }
    }
}
