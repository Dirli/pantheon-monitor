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
    public class Widgets.Popover : Gtk.Grid {
        public signal void open_monitor ();
        public signal void hide_indicator ();

        private Gtk.Label ram_value;
        private Gtk.Label swap_value;
        private Gtk.Label freq_value;
        private Gtk.Label uptime_value;
        private Gtk.Label down_value;
        private Gtk.Label up_value;

        private Gtk.Box volumes_box;

        public Popover () {
            orientation = Gtk.Orientation.HORIZONTAL;
            hexpand = true;
            row_spacing = 8;
            margin_top = 10;

            Gtk.Label freq_label = new Gtk.Label (_("Frequency"));
            freq_label.halign = Gtk.Align.START;
            freq_label.margin_start = 9;
            freq_value = new Gtk.Label ("-");
            freq_value.halign = Gtk.Align.END;
            freq_value.margin_end = 9;

            Gtk.Label ram_label = new Gtk.Label (_("Ram"));
            ram_label.halign = Gtk.Align.START;
            ram_label.margin_start = 9;
            ram_value = new Gtk.Label ("-");
            ram_value.halign = Gtk.Align.END;
            ram_value.margin_end = 9;

            Gtk.Label swap_label = new Gtk.Label (_("Swap"));
            swap_label.halign = Gtk.Align.START;
            swap_label.margin_start = 9;
            swap_value = new Gtk.Label ("-");
            swap_value.halign = Gtk.Align.END;
            swap_value.margin_end = 9;

            Gtk.Label uptime_label = new Gtk.Label (_("Uptime"));
            uptime_label.halign = Gtk.Align.START;
            uptime_label.margin_start = 9;
            uptime_value = new Gtk.Label ("-");
            uptime_value.halign = Gtk.Align.END;
            uptime_value.margin_end = 9;

            var separator = new Wingpanel.Widgets.Separator ();
            separator.hexpand = true;

            attach (freq_label,   0, 0);
            attach (freq_value,   1, 0);
            attach (ram_label,    0, 1);
            attach (ram_value,    1, 1);
            attach (swap_label,   0, 2);
            attach (swap_value,   1, 2);
            attach (uptime_label, 0, 3);
            attach (uptime_value, 1, 3);
            attach (separator,    0, 4, 2, 1);

            init_network ();

            init_footer ();
        }

        private void init_network () {
            Gtk.Label net_label = new Gtk.Label (_("Network"));
            net_label.halign = Gtk.Align.CENTER;

            attach (net_label, 0, 5, 2, 1);

            Gtk.Label down_label = new Gtk.Label (_("Downloaded"));
            down_label.halign = Gtk.Align.START;
            down_label.margin_start = 9;
            down_value = new Gtk.Label ("-");
            down_value.halign = Gtk.Align.END;
            down_value.margin_end = 9;

            attach (down_label, 0, 6);
            attach (down_value, 1, 6);

            Gtk.Label up_label = new Gtk.Label (_("Uploaded"));
            up_label.halign = Gtk.Align.START;
            up_label.margin_start = 9;
            up_value = new Gtk.Label ("-");
            up_value.halign = Gtk.Align.END;
            up_value.margin_end = 9;

            attach (up_label, 0, 7);
            attach (up_value, 1, 7);

            var separator = new Wingpanel.Widgets.Separator ();
            separator.hexpand = true;

            attach (separator, 0, 8, 2, 1);
        }

        public void clear_volumes_box () {
            var exist_widget = get_child_at (0, 9);
            if (exist_widget != null) {
                exist_widget.destroy ();
            }

            volumes_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 8);
            volumes_box.margin_start = volumes_box.margin_end = 15;

            attach (volumes_box, 0, 9, 2, 1);

            if (get_child_at (0, 10) == null) {
                var separator = new Wingpanel.Widgets.Separator ();
                separator.hexpand = true;
                attach (separator, 0, 10, 2, 1);
            }
        }

        public void add_volume (Gtk.Label vol_label, Gtk.ProgressBar vol_bar) {
            volumes_box.add (vol_label);
            volumes_box.add (vol_bar);
        }

        public void init_footer () {
            var hide_button = new Gtk.ModelButton ();
            hide_button.text = _("Hide indicator");
            hide_button.clicked.connect (() => {
                hide_indicator ();
            });

            var app_button = new Gtk.ModelButton ();
            app_button.text = _("Start monitor");
            app_button.clicked.connect (() => {
                open_monitor ();
            });

            attach (hide_button, 0, 11, 2, 1);
            attach (app_button,  0, 12, 2, 1);
        }

        public void update_state (string freq,
                                  string ram,
                                  string swap,
                                  string uptime) {
            freq_value.label = freq;
            ram_value.label = ram;
            swap_value.label = swap;
            uptime_value.label = uptime;
        }

        public void update_total_network (string total_down, string total_up) {
            down_value.label = total_down;
            up_value.label = total_up;
        }
    }
}
