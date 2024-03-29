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

        private Gtk.Grid layout;

        public Preferences () {
            Object (modal: true,
                    deletable: false,
                    resizable: false,
                    title: _("Preferences"),
                    destroy_with_parent: true);
        }

        construct {
            set_default_response (Gtk.ResponseType.CLOSE);

            //Create UI
            layout = new Gtk.Grid ();
            layout.valign = Gtk.Align.START;
            layout.column_spacing = 12;
            layout.row_spacing = 12;
            layout.margin = 12;
            layout.margin_top = 0;

            var schema_sources = GLib.SettingsSchemaSource.get_default ();
            if (schema_sources != null) {
                if (schema_sources.lookup (Constants.PROJECT_NAME + ".resources", true) != null) {
                    add_section_header (_("Resources"));

                    build_resources ();
                }

                if (schema_sources.lookup (Constants.PROJECT_NAME + ".sensors", true) != null) {
                    bool exist_hwmon = false;
                    try {
                        GLib.Dir dir = GLib.Dir.open (Constants.HWMON_PATH, 0);
                        while ((name = dir.read_name ()) != null) {
                            exist_hwmon = true;
                            break;
                        }
                    } catch (GLib.Error e) {
                        warning (e.message);
                    }

                    if (exist_hwmon) {
                        add_section_header (_("Sensors"));

                        build_sensors ();
                    }
                }
            }

            Gtk.Box content = get_content_area () as Gtk.Box;
            content.valign = Gtk.Align.START;
            content.border_width = 6;
            content.add (layout);

            //Actions
            add_button (_("Close"), Gtk.ResponseType.CLOSE);
            response.connect (() => {
                destroy ();
            });
        }

        private void add_section_header (string section_name) {
            Gtk.Label resources_sec = new Gtk.Label (section_name);
            resources_sec.get_style_context ().add_class ("preferences");
            resources_sec.halign = Gtk.Align.START;

            layout.attach (resources_sec, 0, top++, 1, 1);
            layout.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, top++, 2, 1);
        }

        private void build_resources () {
            var r_settings = new GLib.Settings (Constants.PROJECT_NAME + ".resources");
            var view_state = r_settings.get_int ("view-state");

            Gtk.Switch ind_show = new Gtk.Switch ();
            add_new_str (_("Show resources Indicator:"), ind_show, top++);

            Gtk.Switch ind_title_show = new Gtk.Switch ();
            ind_title_show.active = (view_state & 1) > 0;
            add_new_str (_("Show icons:"), ind_title_show, top++);
            Gtk.Switch ind_cpu_show = new Gtk.Switch ();
            ind_cpu_show.active = (view_state & (1 << 1)) > 0;
            add_new_str (_("Show CPU:"), ind_cpu_show, top++);
            Gtk.Switch ind_ram_show = new Gtk.Switch ();
            ind_ram_show.active = (view_state & (1 << 2)) > 0;
            add_new_str (_("Show RAM:"), ind_ram_show, top++);

            Gtk.Label network_lbl = new Gtk.Label (_("Network"));
            network_lbl.halign = Gtk.Align.CENTER;
            layout.attach (network_lbl, 0, top++);

            Gtk.Switch ind_net_show = new Gtk.Switch ();
            ind_net_show.active = (view_state & (1 << 3)) > 0;
            add_new_str (_("Show Network:"), ind_net_show, top++);

            var network_mod = new Granite.Widgets.ModeButton ();
            network_mod.hexpand = true;
            network_mod.append (new Gtk.Label (_("Full")));
            network_mod.append (new Gtk.Label (_("Compact")));
            network_mod.selected = r_settings.get_int ("compact-size") > -1 ? 1 : 0;

            layout.attach (network_mod, 0, top++, 2);

            var mod_button = new Granite.Widgets.ModeButton ();
            mod_button.hexpand = true;
            mod_button.append (new Gtk.Label ("8px"));
            mod_button.append (new Gtk.Label ("9px"));
            mod_button.append (new Gtk.Label ("10px"));

            layout.attach (mod_button, 0, top++, 2);

            r_settings.bind ("indicator", ind_show, "active", GLib.SettingsBindFlags.DEFAULT);

            ind_title_show.notify["active"].connect (() => {
                r_settings.set_int ("view-state", r_settings.get_int ("view-state") ^ 1);
            });
            ind_cpu_show.notify["active"].connect (() => {
                r_settings.set_int ("view-state", r_settings.get_int ("view-state") ^ (1 << 1));
            });
            ind_ram_show.notify["active"].connect (() => {
                r_settings.set_int ("view-state", r_settings.get_int ("view-state") ^ (1 << 2));
            });
            ind_net_show.notify["active"].connect (() => {
                r_settings.set_int ("view-state", r_settings.get_int ("view-state") ^ (1 << 3));
            });

            GLib.Idle.add (() => {
                var compact_size = r_settings.get_int ("compact-size");
                if (compact_size > -1) {
                    mod_button.selected = compact_size;
                } else {
                    mod_button.selected = 1;
                    mod_button.sensitive = false;
                }

                mod_button.mode_changed.connect (() => {
                    r_settings.set_int ("compact-size", mod_button.selected);
                });

                return false;
            });

            network_mod.mode_changed.connect (() => {
                mod_button.sensitive = network_mod.selected == 1;
                r_settings.set_int ("compact-size", network_mod.selected == 0 ? -1 : mod_button.selected);
            });
        }

        private void build_sensors () {
            var s_settings = new GLib.Settings (Constants.PROJECT_NAME + ".sensors");

            Gtk.Switch ind_show = new Gtk.Switch ();
            add_new_str (_("Show sensors Indicator:"), ind_show, top++);

            s_settings.bind ("indicator", ind_show, "active", GLib.SettingsBindFlags.DEFAULT);
        }

        private void add_new_str (string label_str, Gtk.Widget value_widget, int str_top, int str_left = 0) {
            var iter_label = new Gtk.Label (label_str);
            iter_label.halign = Gtk.Align.END;

            value_widget.halign = Gtk.Align.START;

            layout.attach (iter_label, str_left++, str_top);
            layout.attach (value_widget, str_left, str_top);
        }
    }
}
