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
    public class Resources.Panel : Gtk.Box {
        private int _compact_size = -1;
        public int compact_size {
            get {
                return _compact_size;
            }
            set {
                net_value.label = "";

                unowned Gtk.StyleContext net_value_style = net_value.get_style_context ();
                if (_compact_size > -1) {
                    net_value_style.remove_class (@"small-$(_compact_size)");
                }

                if (value >= 0) {
                    net_value_style.add_class (@"small-$(value)");
                    net_value.set_width_chars (8);
                } else {
                    net_value.set_width_chars (-1);
                }

                _compact_size = value;
            }
        }
        private Gtk.Image mem_image;
        private Gtk.Label mem_value;
        private Gtk.Image cpu_image;
        private Gtk.Label cpu_value;

        private Gtk.Image net_image;
        private Gtk.Label net_value;
        private string net_image_name = "netspeed-nonactive-symbolic";

        public Panel () {
            Object (orientation: Gtk.Orientation.HORIZONTAL);

            cpu_image = new Gtk.Image.from_icon_name ("proc-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            cpu_value = new Gtk.Label ("-");
            add (cpu_image);
            add (cpu_value);

            mem_image = new Gtk.Image.from_icon_name ("memory-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            mem_value = new Gtk.Label ("-");
            add (mem_image);
            add (mem_value);

            net_image = new Gtk.Image.from_icon_name ("netspeed-nonactive-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            net_image.valign = Gtk.Align.CENTER;

            net_value = new Gtk.Label ("");
            net_value.justify = Gtk.Justification.LEFT;
            net_value.valign = Gtk.Align.CENTER;
            net_value.margin = 0;

            add (net_image);
            add (net_value);
        }

        public void update_cpu (string new_val) {
            cpu_value.label = new_val;
        }

        public void update_mem (string new_val) {
            mem_value.label = new_val;
        }

        public void update_net (string down_val, string up_val) {
            string i_name = down_val != "" && up_val != "" ? "netspeed-active-symbolic" :
                            down_val == "" && up_val != "" ? "netspeed-upload-symbolic" :
                            down_val != "" && up_val == "" ? "netspeed-download-symbolic" :
                            "netspeed-nonactive-symbolic";

            if (i_name != net_image_name) {
                net_image.icon_name = i_name;
                net_image_name = i_name;
            }

            if (compact_size > -1) {
                net_value.label = @"$(up_val != "" ? up_val : "0 B/s")\n$(down_val != "" ? down_val : "0 B/s")";
            } else {
                net_value.label = @"$(down_val != "" ? down_val : "0 B/s") / $(up_val != "" ? up_val : "0 B/s")";
            }
        }

        public void update_ui (int view_state) {
            cpu_value.set_visible ((view_state & (1 << 1)) > 0);
            cpu_image.set_visible ((view_state & (1 << 1)) > 0 ? (view_state & 1) == 1 : false);

            mem_value.set_visible ((view_state & (1 << 2)) > 0);
            mem_image.set_visible ((view_state & (1 << 2)) > 0 ? (view_state & 1) == 1 : false);

            net_value.set_visible ((view_state & (1 << 3)) > 0);
            net_image.set_visible ((view_state & (1 << 3)) > 0 ? (view_state & 1) == 1 : false);
        }
    }
}
