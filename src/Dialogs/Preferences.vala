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
                if (schema_sources.lookup (Constants.PROJECT_NAME + ".resources", true) != null) {
                    add_section_header (layout, _("Resources"));

                    build_resources (layout);
                }

                if (schema_sources.lookup (Constants.PROJECT_NAME + ".sensors", true) != null) {
                    add_section_header (layout, _("Sensors"));

                    build_sensors (layout);
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

        private void add_section_header (Gtk.Grid layout, string section_name) {
            Gtk.Label resources_sec = new Gtk.Label (section_name);
            resources_sec.get_style_context ().add_class ("preferences");
            resources_sec.halign = Gtk.Align.START;

            layout.attach (resources_sec, 0, top++, 1, 1);
            layout.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, top++, 2, 1);
        }

        private void build_resources (Gtk.Grid layout) {
            var r_settings = new GLib.Settings (Constants.PROJECT_NAME + ".resources");

            Gtk.Switch ind_show = new Gtk.Switch ();
            add_new_str (layout, _("Show resources Indicator:"), ind_show, top++);

            Gtk.Switch ind_title_show = new Gtk.Switch ();
            add_new_str (layout, _("Show icons:"), ind_title_show, top++);
            Gtk.Switch ind_cpu_show = new Gtk.Switch ();
            add_new_str (layout, _("Show CPU:"), ind_cpu_show, top++);
            Gtk.Switch ind_ram_show = new Gtk.Switch ();
            add_new_str (layout, _("Show RAM:"), ind_ram_show, top++);

            Gtk.Label network_lbl = new Gtk.Label (_("Network"));
            network_lbl.halign = Gtk.Align.CENTER;
            layout.attach (network_lbl, 0, top++);

            Gtk.Switch ind_net_show = new Gtk.Switch ();
            add_new_str (layout, _("Show Network:"), ind_net_show, top++);

            var network_mod = new Granite.Widgets.ModeButton ();
            network_mod.hexpand = true;
            network_mod.append (new Gtk.Label (_("Full")));
            network_mod.append (new Gtk.Label (_("Compact")));
            network_mod.selected = r_settings.get_boolean ("compact-net") ? 1 : 0;

            layout.attach (network_mod, 0, top++, 2);

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

            mod_button.mode_changed.connect (() => {
                r_settings.set_int ("compact-size", network_mod.selected);
            });

            network_mod.mode_changed.connect (() => {
                r_settings.set_boolean ("compact-net", network_mod.selected == 0 ? false : true);
            });
        }

        private void build_sensors (Gtk.Grid layout) {
            var s_settings = new GLib.Settings (Constants.PROJECT_NAME + ".sensors");

            Gtk.Switch ind_show = new Gtk.Switch ();
            add_new_str (layout, _("Show sensors Indicator:"), ind_show, top++);

            s_settings.bind ("indicator", ind_show, "active", GLib.SettingsBindFlags.DEFAULT);
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
