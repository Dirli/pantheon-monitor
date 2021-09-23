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
    public class Sensors.Popover : Gtk.Grid {
        private int top = 0;

        private Gee.HashMap<string, Gtk.Label> sensors_hash;

        public Popover () {
            Object (margin: 10,
                    halign: Gtk.Align.FILL,
                    orientation: Gtk.Orientation.HORIZONTAL,
                    hexpand: true,
                    row_spacing: 5);
        }

        construct {
            sensors_hash = new Gee.HashMap<string, Gtk.Label> ();
        }

        public void add_hwmon_label (string monitor_label) {
            Gtk.Label hwm_label = new Gtk.Label (monitor_label);
            hwm_label.expand = true;
            hwm_label.ellipsize = Pango.EllipsizeMode.END;
            hwm_label.margin_start = hwm_label.margin_end = 5;
            hwm_label.margin_top = 5;
            hwm_label.get_style_context ().add_class ("h3");

            attach (hwm_label, 0, top++, 2, 1);
        }

        public bool add_sensor (SensorStruct sens) {
            Gtk.Label sens_iter_label = new Gtk.Label (sens.label);
            sens_iter_label.halign = Gtk.Align.START;
            sens_iter_label.margin_start = 20;

            if (sens.tooltip != null && sens.tooltip != "") {
                sens_iter_label.tooltip_text = "max " + Utils.parse_temp (sens.tooltip);
            }

            Gtk.Label sens_iter_val = new Gtk.Label ("-");
            sens_iter_val.halign = Gtk.Align.END;
            sens_iter_val.margin_end = 20;

            attach (sens_iter_label, 0, top, 1, 1);
            attach (sens_iter_val, 1, top++, 1, 1);

            sensors_hash[sens.key] = sens_iter_val;

            return true;
        }

        public void update_label (string key, string temp_str) {
            if (sensors_hash.has_key (key)) {
                sensors_hash[key].label = Utils.parse_temp (temp_str);
            }
        }

    }
}
