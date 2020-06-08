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
        private Gtk.Label write_value;
        private Gtk.Label read_value;

        private Gtk.Box volumes_box;

        public Popover () {
            orientation = Gtk.Orientation.HORIZONTAL;
            hexpand = true;
            row_spacing = 8;
            margin_top = 10;

            freq_value = add_new_str (_("Frequency"), 0);
            ram_value = add_new_str (_("Memory"), 1);
            swap_value = add_new_str (_("Swap"), 2);
            uptime_value = add_new_str (_("Uptime"), 3);

            attach (new Wingpanel.Widgets.Separator (), 0, 4, 2, 1);

            init_network ();
            init_disks ();
            init_footer ();
        }

        private void init_network () {
            Gtk.Label net_label = new Gtk.Label (_("Network"));
            net_label.halign = Gtk.Align.CENTER;

            attach (net_label, 0, 5, 2, 1);

            down_value = add_new_str (_("Downloaded"), 6);
            up_value = add_new_str (_("Uploaded"), 7);

            attach (new Wingpanel.Widgets.Separator (), 0, 8, 2, 1);
        }


        private void init_disks () {
            Gtk.Label disks_label = new Gtk.Label (_("Disks"));
            disks_label.halign = Gtk.Align.CENTER;

            Gtk.Image write_icon = new Gtk.Image.from_icon_name ("go-down-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            write_icon.margin_start = 12;

            write_value = new Gtk.Label ("-");
            write_value.set_width_chars (8);
            write_value.tooltip_text = _("Write");

            Gtk.Box write_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
            write_box.halign = Gtk.Align.START;
            write_box.add (write_icon);
            write_box.add (write_value);

            Gtk.Image read_icon = new Gtk.Image.from_icon_name ("go-up-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            read_icon.margin_end = 12;

            read_value = new Gtk.Label ("-");
            read_value.set_width_chars (9);
            read_value.tooltip_text = _("Read");

            Gtk.Box read_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
            read_box.halign = Gtk.Align.END;
            read_box.add (read_value);
            read_box.add (read_icon);

            var io_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 5);
            io_box.halign = Gtk.Align.FILL;
            io_box.pack_start (write_box, false, false, 0);
            io_box.pack_end (read_box, false, false, 0);

            attach (disks_label, 0, 9, 2, 1);
            attach (io_box, 0, 10, 2, 1);

            attach (new Wingpanel.Widgets.Separator (), 0, 12, 2, 1);
        }

        public void clear_volumes_box () {
            var exist_widget = get_child_at (0, 11);
            if (exist_widget != null) {
                exist_widget.destroy ();
            }

            volumes_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 8);
            volumes_box.margin_start = volumes_box.margin_end = 15;

            attach (volumes_box, 0, 11, 2, 1);
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

            attach (hide_button, 0, 13, 2, 1);
            attach (app_button,  0, 14, 2, 1);
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

        public void update_io (string read_string, string write_string) {
            read_value.label = read_string;
            write_value.label = write_string;
        }

        public void update_total_network (string total_down, string total_up) {
            down_value.label = total_down;
            up_value.label = total_up;
        }

        private Gtk.Label add_new_str (string title_val, int pos) {
            Gtk.Label str_label = new Gtk.Label (title_val);
            str_label.halign = Gtk.Align.START;
            Gtk.Label str_value = new Gtk.Label ("-");
            str_value.halign = Gtk.Align.END;

            str_label.margin_start = str_value.margin_end = 9;

            attach (str_label, 0, pos);
            attach (str_value, 1, pos);

            return str_value;
        }
    }
}
