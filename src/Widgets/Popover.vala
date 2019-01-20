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
        private Gtk.Label ram_value;
        private Gtk.Label swap_value;
        private Gtk.Label freq_value;
        private Gtk.Label uptime_value;

        public signal void close_popover ();

        public Popover () {
            orientation = Gtk.Orientation.HORIZONTAL;
            hexpand = true;
            row_spacing = 10;
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

            attach (freq_label,   0, 0, 1, 1);
            attach (freq_value,   1, 0, 1, 1);
            attach (ram_label,    0, 1, 1, 1);
            attach (ram_value,    1, 1, 1, 1);
            attach (swap_label,   0, 2, 1, 1);
            attach (swap_value,   1, 2, 1, 1);
            attach (uptime_label, 0, 3, 1, 1);
            attach (uptime_value, 1, 3, 1, 1);
            attach (separator,    0, 4, 2, 1);

            init_footer ();
        }

        public void init_footer () {
            var hide_button = new Gtk.ModelButton ();
            hide_button.text = _("Hide indicator");
            hide_button.clicked.connect (() => {
                Monitor.Services.SettingsManager.get_default ().set_boolean ("indicator", false);
            });

            var app_button = new Gtk.ModelButton ();
            app_button.text = _("Start monitor");
            app_button.clicked.connect (() => {
                close_popover ();
                var app_info = new GLib.DesktopAppInfo("io.elementary.monitor.desktop");

                if (app_info == null) {return;}

                try {
                    app_info.launch(null, null);
                } catch (Error e) {
                    warning ("Unable to launch io.elementary.monitor.desktop: %s", e.message);
                }
            });

            attach (hide_button,  0, 5, 2, 1);
            attach (app_button,   0, 6, 2, 1);
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
    }
}
