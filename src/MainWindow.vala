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
    public class MainWindow : Gtk.Window {
        private Gtk.Grid view;
        private Widgets.Process process_view;
        private Models.GenericModel generic_model;

        public MainWindow (MonitorApp app) {
            set_application (app);
            set_default_size (600, 600);
            window_position = Gtk.WindowPosition.CENTER;

            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/io/elementary/monitor/style/application.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            Widgets.Headerbar headerbar = new Widgets.Headerbar (this);
            set_titlebar (headerbar);

            view = new Gtk.Grid ();
            view.expand = true;
            view.halign = view.valign = Gtk.Align.FILL;

            Widgets.Statusbar statusbar = Widgets.Statusbar.get_default ();
            view.attach (statusbar, 0, 1, 1, 1);

            add (view);
            headerbar.view_box.mode_changed.connect (() => {
                Gtk.Widget? widget = null;

                if (headerbar.view_box.selected == 1) {
                    widget = new Views.Monitor (current_color ());
                    statusbar.hide ();
                } else if (headerbar.view_box.selected == 2) {
                    widget = get_scrolled_window (new Views.Disks ());
                    statusbar.hide ();
                } else {
                    generic_model = new Models.GenericModel ();
                    process_view = new Widgets.Process (generic_model);
                    widget = get_scrolled_window (process_view);
                    statusbar.show ();
                }

                if (widget != null) {
                    var exist_widget = view.get_child_at (0,0);

                    if (exist_widget != null) {
                        if (exist_widget is Views.Monitor) {
                            ((Views.Monitor) exist_widget).stop_timer ();
                        }
                        exist_widget.destroy ();
                    }

                    view.attach (widget, 0, 0, 1, 1);
                }
            });

            headerbar.search_process.connect ((proc_pattern) => {
                unowned Gtk.Widget exist_widget = view.get_child_at (0, 0);
                if (exist_widget != null) {
                    unowned Gtk.Widget w = (exist_widget as Gtk.Container).get_children ().nth_data (0);
                    if (w is Widgets.Process) {
                        (w as Widgets.Process).filter_text = proc_pattern;
                    }
                }
            });

            headerbar.view_box.selected = 0;

            init_statusbar (statusbar);
        }

        private Gdk.RGBA current_color () {
            return get_style_context ().get_color (Gtk.StateFlags.NORMAL);
        }

        private void init_statusbar (Widgets.Statusbar statusbar) {
            var end_process_button = new Gtk.Button.with_label (_("End Process"));
            end_process_button.valign = Gtk.Align.CENTER;
            end_process_button.margin = 10;
            end_process_button.clicked.connect (process_view.end_process);
            // end_process_button.tooltip_text = (_("Ctrl+E"));

            var kill_process_button = new Gtk.Button.with_label (_("Kill process"));
            kill_process_button.valign = Gtk.Align.CENTER;
            kill_process_button.margin = 10;
            kill_process_button.clicked.connect (process_view.kill_process);
            // kill_process_button.tooltip_text = ("Ctrl+E");

            statusbar.pack_start (end_process_button);
            statusbar.pack_start (kill_process_button);
        }

        private Gtk.ScrolledWindow get_scrolled_window (Gtk.Widget widget) {
            Gtk.ScrolledWindow scr_window = new Gtk.ScrolledWindow (null, null);

            scr_window.add (widget);
            scr_window.expand = true;
            scr_window.margin_start = scr_window.margin_end = 15;
            scr_window.margin_top = scr_window.margin_bottom = 10;
            scr_window.show_all ();

            return scr_window;
        }
    }
}
