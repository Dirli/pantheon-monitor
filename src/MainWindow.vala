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
    public class MainWindow : Gtk.Window {
        private string current_view_name = "";

        private Gtk.Stack stack;
        private Gtk.SearchEntry search_entry;
        private Views.Processes processes_view;
        private Granite.Widgets.ModeButton view_box;

        private const ActionEntry[] ACTION_ENTRIES = {
            { Constants.ACTION_END_PROC, action_end_proc },
            { Constants.ACTION_KILL_PROC, action_kill_proc },
            { Constants.ACTION_SEARCH, action_search },
            { Constants.ACTION_VIEW, action_view, "i"  },
            { Constants.ACTION_QUIT, action_quit },
        };

        public MainWindow (MonitorApp app) {
            Object (window_position: Gtk.WindowPosition.CENTER,
                    application: app);

            application.set_accels_for_action (Constants.ACTION_PREFIX + Constants.ACTION_SEARCH, {"<Control>f"});
            application.set_accels_for_action (Constants.ACTION_PREFIX + Constants.ACTION_QUIT, {"<Control>q"});
            application.set_accels_for_action (Constants.ACTION_PREFIX + Constants.ACTION_END_PROC, {"<Control>e"});
            application.set_accels_for_action (Constants.ACTION_PREFIX + Constants.ACTION_KILL_PROC, {"<Control>k"});
            application.set_accels_for_action (Constants.ACTION_PREFIX + Constants.ACTION_VIEW + "(0)", {"<Control>1"});
            application.set_accels_for_action (Constants.ACTION_PREFIX + Constants.ACTION_VIEW + "(1)", {"<Control>2"});
            application.set_accels_for_action (Constants.ACTION_PREFIX + Constants.ACTION_VIEW + "(2)", {"<Control>3"});
        }

        construct {
            var actions = new GLib.SimpleActionGroup ();
            actions.add_action_entries (ACTION_ENTRIES, this);
            insert_action_group ("win", actions);

            set_default_size (700, 850);

            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/io/elementary/monitor/style/application.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            var view = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            view.expand = true;
            view.halign = view.valign = Gtk.Align.FILL;

            stack = new Gtk.Stack ();
            stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

            processes_view = new Views.Processes ();
            var monitor_view = new Views.Monitor ();
            stack.add_named (processes_view, "processes");
            stack.add_named (monitor_view, "monitor");
            stack.add_named (new Views.Disks (), "disks");

            stack.notify["visible-child-name"].connect (on_changed_child);

            build_headerbar ();

            view.add (stack);
            add (view);

            show_all ();

            var granite_settings = Granite.Settings.get_default ();
            var gtk_settings = Gtk.Settings.get_default ();

            gtk_settings.gtk_application_prefer_dark_theme =
                granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        
            monitor_view.update_color ();
            granite_settings.notify["prefers-color-scheme"].connect (() => {
                gtk_settings.gtk_application_prefer_dark_theme =
                    granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;

                monitor_view.update_color ();
            });
        }

        private void on_changed_child () {
            var new_view_name = stack.get_visible_child_name ();
            if (new_view_name == null) {
                return;
            }

            if (current_view_name != "" && new_view_name != current_view_name) {
                var prev_widget = stack.get_child_by_name (current_view_name);
                if (prev_widget != null && prev_widget is Views.ViewWrapper) {
                    ((Views.ViewWrapper) prev_widget).stop_timer ();
                }
            }

            current_view_name = new_view_name;

            var new_widget = stack.get_child_by_name (current_view_name);
            if (new_widget != null && new_widget is Views.ViewWrapper) {
                ((Views.ViewWrapper) new_widget).start_timer ();
            }
        }

        private void action_quit () {
            if (current_view_name != "") {
                var prev_widget = stack.get_child_by_name (current_view_name);
                if (prev_widget != null && prev_widget is Views.ViewWrapper) {
                    ((Views.ViewWrapper) prev_widget).stop_timer ();
                }
            }

            destroy ();
        }

        private void action_end_proc () {
            if (stack.visible_child_name == "processes") {
                processes_view.end_process ();
            }
        }

        private void action_kill_proc () {
            if (stack.visible_child_name == "processes") {
                processes_view.kill_process ();
            }
        }

        private void action_search () {
            search_entry.grab_focus ();
        }

        private void action_view (GLib.SimpleAction action, GLib.Variant? pars) {
            int tid;
            pars.get ("i", out tid);

            view_box.selected = tid;
        }

        private void build_headerbar () {
            var header_bar = new Widgets.Headerbar (this);

            view_box = new Granite.Widgets.ModeButton ();
            view_box.homogeneous = false;
            view_box.valign = Gtk.Align.CENTER;

            search_entry = new Gtk.SearchEntry ();

            view_box.append (create_model_button ("view-list-symbolic", _("Processes")));
            view_box.append (create_model_button ("utilities-system-monitor-symbolic", _("Monitor")));
            view_box.append (create_model_button ("drive-harddisk-symbolic", _("Disks")));

            view_box.mode_changed.connect (() => {
                if (view_box.selected == 0) {
                    search_entry.show ();
                } else {
                    search_entry.hide ();
                }
                stack.set_visible_child_name (view_box.selected == 0 ? "processes" :
                                              view_box.selected == 1 ? "monitor" :
                                              view_box.selected == 2 ? "disks" : "processes");
            });

            search_entry.valign = Gtk.Align.CENTER;
            search_entry.placeholder_text = _("Search Process");
            search_entry.set_tooltip_text (_("Type Process Name or PID"));
            search_entry.search_changed.connect (() => {
                if (stack.visible_child_name != "processes" || search_entry.text_length == 1) {
                    return;
                }

                processes_view.filter_text = search_entry.text;
            });

            header_bar.pack_start (view_box);
            header_bar.pack_end (search_entry);

            set_titlebar (header_bar);

            view_box.selected = 0;
        }

        private Gtk.Image create_model_button (string icon_name, string tooltip_text) {
            Gtk.Image m_button = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.BUTTON);
            m_button.tooltip_text = tooltip_text;
            m_button.margin_start = m_button.margin_end = 5;

            return m_button;
        }

        public override bool delete_event (Gdk.EventAny event) {
            if (current_view_name != "") {
                var prev_widget = stack.get_child_by_name (current_view_name);
                if (prev_widget != null && prev_widget is Views.ViewWrapper) {
                    ((Views.ViewWrapper) prev_widget).stop_timer ();
                }
            }

            return false;
        }
    }
}
