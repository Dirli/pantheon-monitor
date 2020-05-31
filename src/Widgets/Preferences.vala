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
    public class Widgets.Preferences : Gtk.Dialog {
        public Preferences (Monitor.MainWindow window, Granite.Widgets.ModeButton view_box) {
            resizable = false;
            deletable = false;
            transient_for = window;
            modal = true;

            /* Gtk.Label general_sec = new Gtk.Label (_("General"));
            general_sec.get_style_context ().add_class ("preferences");
            general_sec.halign = Gtk.Align.START; */

            /* Gtk.Label interface_sec = new Gtk.Label (_("Interface"));
            interface_sec.get_style_context ().add_class ("preferences");
            interface_sec.halign = Gtk.Align.START; */

            //Create UI
            var layout = new Gtk.Grid ();
            layout.valign = Gtk.Align.START;
            layout.column_spacing = 12;
            layout.row_spacing = 12;
            layout.margin = 12;
            layout.margin_top = 0;

            /* layout.attach (general_sec,  0, top, 2, 1);
            ++top;
            layout.attach (interface_sec,  0, top, 2, 1);
            ++top; */

            //Select indicator
#if INDICATOR_EXIST
            GLib.Settings settings = Services.SettingsManager.get_default ();
            int top = 0;

            Gtk.Label indicator_sec = new Gtk.Label (_("Indicator"));
            indicator_sec.get_style_context ().add_class ("preferences");
            indicator_sec.halign = Gtk.Align.START;
            layout.attach (indicator_sec, 0, top++, 1, 1);

            Gtk.Switch ind_show = new Gtk.Switch ();
            add_new_str (ref layout, _("Use System Tray Indicator:"), ind_show, top++);

            Gtk.Switch ind_title_show = new Gtk.Switch ();
            add_new_str (ref layout, _("Show titles:"), ind_title_show, top++);

            Gtk.Switch ind_cpu_show = new Gtk.Switch ();
            add_new_str (ref layout, _("Show CPU:"), ind_cpu_show, top++);

            Gtk.Switch ind_ram_show = new Gtk.Switch ();
            add_new_str (ref layout, _("Show RAM:"), ind_ram_show, top++);

            var separator1 = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            separator1.hexpand = true;

            layout.attach (separator1, 0, top++, 2, 1);

            Gtk.Label network_sec = new Gtk.Label (_("Network indicator"));
            network_sec.get_style_context ().add_class ("preferences");
            network_sec.halign = Gtk.Align.START;
            layout.attach (network_sec, 0, top++, 1, 1);

            Gtk.Switch ind_net_show = new Gtk.Switch ();
            add_new_str (ref layout, _("Show Network:"), ind_net_show, top++);

            Gtk.Switch ind_compact_show = new Gtk.Switch ();
            add_new_str (ref layout, _("Show compact Network:"), ind_compact_show, top++);

            var mod_button = new Granite.Widgets.ModeButton ();
            mod_button.hexpand = true;
            mod_button.append (new Gtk.Label ("8px"));
            mod_button.append (new Gtk.Label ("9px"));
            mod_button.append (new Gtk.Label ("10px"));
            mod_button.selected = settings.get_int ("compact-size");

            layout.attach (mod_button, 0, top++, 2, 1);

            var separator2 = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            separator2.hexpand = true;

            layout.attach (separator2, 0, top++, 2, 1);

            settings.bind("indicator", ind_show, "active", GLib.SettingsBindFlags.DEFAULT);
            settings.bind("indicator-titles", ind_title_show, "active", GLib.SettingsBindFlags.DEFAULT);
            settings.bind("indicator-cpu", ind_cpu_show, "active", GLib.SettingsBindFlags.DEFAULT);
            settings.bind("indicator-ram", ind_ram_show, "active", GLib.SettingsBindFlags.DEFAULT);
            settings.bind("indicator-net", ind_net_show, "active", GLib.SettingsBindFlags.DEFAULT);
            settings.bind("compact-net", ind_compact_show, "active", GLib.SettingsBindFlags.DEFAULT);

            mod_button.mode_changed.connect (() => {
                settings.set_int ("compact-size", mod_button.selected);
            });
#endif

            Gtk.Box content = this.get_content_area () as Gtk.Box;
            content.valign = Gtk.Align.START;
            content.border_width = 6;
            content.add (layout);

            //Actions
            add_button (_("Close"), Gtk.ResponseType.CLOSE);
            response.connect ((source, response_id) => {
                switch (response_id) {
                    case Gtk.ResponseType.CLOSE:
                        view_box.selected = 0;
                        destroy ();
                        break;
                }
            });
            show_all ();
        }

        private void add_new_str (ref Gtk.Grid grid_widget, string label_str, Gtk.Widget value_widget, int str_top, int str_left = 0) {
            var iter_label = new Gtk.Label (label_str);
            iter_label.halign = Gtk.Align.END;

            value_widget.halign = Gtk.Align.START;

            grid_widget.attach (iter_label, str_left++, str_top);
            grid_widget.attach (value_widget, str_left, str_top);
        }
    }
}
