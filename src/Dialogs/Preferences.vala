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
    public class Dialogs.Preferences : Gtk.Dialog {
        private int top = 0;

        public Preferences () {
            Object (modal: true,
                    deletable: false,
                    resizable: false,
                    destroy_with_parent: true);

            //Create UI
            var layout = new Gtk.Grid ();
            layout.valign = Gtk.Align.START;
            layout.column_spacing = 12;
            layout.row_spacing = 12;
            layout.margin = 12;
            layout.margin_top = 0;

            var schema_sources = GLib.SettingsSchemaSource.get_default ();
            if (schema_sources != null) {
                Gtk.Label indicator_sec = new Gtk.Label (_("Indicator"));
                indicator_sec.get_style_context ().add_class ("preferences");
                indicator_sec.halign = Gtk.Align.START;

                layout.attach (indicator_sec, 0, top++, 1, 1);
                layout.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, top++, 2, 1);

                if (schema_sources.lookup (Constants.PROJECT_NAME + ".resources", true) != null) {
                    build_resources (layout);
                }
            }

            Gtk.Box content = this.get_content_area () as Gtk.Box;
            content.valign = Gtk.Align.START;
            content.border_width = 6;
            content.add (layout);

            //Actions
            add_button (_("Close"), Gtk.ResponseType.CLOSE);
            response.connect ((source, response_id) => {
                switch (response_id) {
                    case Gtk.ResponseType.CLOSE:
                        destroy ();
                        break;
                }
            });
            show_all ();
        }

        private void build_resources (Gtk.Grid layout) {
            var r_settings = new GLib.Settings (Constants.PROJECT_NAME + ".resources");

            Gtk.Switch ind_show = new Gtk.Switch ();
            add_new_str (layout, _("Use System Tray Indicator:"), ind_show, top++);

            Gtk.Switch ind_title_show = new Gtk.Switch ();
            add_new_str (layout, _("Show titles:"), ind_title_show, top++);
            Gtk.Switch ind_cpu_show = new Gtk.Switch ();
            add_new_str (layout, _("Show CPU:"), ind_cpu_show, top++);
            Gtk.Switch ind_ram_show = new Gtk.Switch ();
            add_new_str (layout, _("Show RAM:"), ind_ram_show, top++);

            Gtk.Label network_sec = new Gtk.Label (_("Network indicator"));
            network_sec.get_style_context ().add_class ("preferences");
            network_sec.halign = Gtk.Align.START;
            layout.attach (network_sec, 0, top++);

            Gtk.Switch ind_net_show = new Gtk.Switch ();
            add_new_str (layout, _("Show Network:"), ind_net_show, top++);

            Gtk.Switch ind_compact_show = new Gtk.Switch ();
            add_new_str (layout, _("Show compact Network:"), ind_compact_show, top++);

            var mod_button = new Granite.Widgets.ModeButton ();
            mod_button.hexpand = true;
            mod_button.append (new Gtk.Label ("8px"));
            mod_button.append (new Gtk.Label ("9px"));
            mod_button.append (new Gtk.Label ("10px"));
            mod_button.selected = r_settings.get_int ("compact-size");

            layout.attach (mod_button, 0, top++, 2);

            r_settings.bind ("indicator", ind_show, "active", GLib.SettingsBindFlags.DEFAULT);
            r_settings.bind ("indicator-titles", ind_title_show, "active", GLib.SettingsBindFlags.DEFAULT);
            r_settings.bind ("indicator-cpu", ind_cpu_show, "active", GLib.SettingsBindFlags.DEFAULT);
            r_settings.bind ("indicator-ram", ind_ram_show, "active", GLib.SettingsBindFlags.DEFAULT);
            r_settings.bind ("indicator-net", ind_net_show, "active", GLib.SettingsBindFlags.DEFAULT);
            r_settings.bind ("compact-net", ind_compact_show, "active", GLib.SettingsBindFlags.DEFAULT);

            mod_button.mode_changed.connect (() => {
                r_settings.set_int ("compact-size", mod_button.selected);
            });
        }

        private void add_new_str (Gtk.Grid grid_widget, string label_str, Gtk.Widget value_widget, int str_top, int str_left = 0) {
            var iter_label = new Gtk.Label (label_str);
            iter_label.halign = Gtk.Align.END;

            value_widget.halign = Gtk.Align.START;

            grid_widget.attach (iter_label, str_left++, str_top);
            grid_widget.attach (value_widget, str_left, str_top);
        }
    }
}
