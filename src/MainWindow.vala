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

    private const string SECTION_SIZE = """
        .section {
            font-size: 130%;
        }
        .mode_button_split {
            border-left-width: 1px;
        }
        .preferences {
            font-size: 110%;
            font-weight: 600;
        }
        .block {
            border: 0.5px solid;
            border-radius: 0.5em;
            padding: 0.5em;
            font-weight: bold;
        }
        .volumes {
            border-radius: 0.3em;
            opacity: 0.9;
            font-weight: bold;
            background-color: Khaki;
            padding-bottom: 5px;
            padding-top: 5px;
        }
    """;

    public class MainWindow : Gtk.Window {
        private Gtk.Grid view;
        private Widgets.Process process_view;
        private Models.GenericModel generic_model;

        public MainWindow (MonitorApp app) {
            set_application (app);
            set_default_size (600, 600);
            resizable = false;
            window_position = Gtk.WindowPosition.CENTER;

            try {
                var provider = new Gtk.CssProvider ();
                provider.load_from_data (SECTION_SIZE);
                Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            } catch (Error e) {
                warning (e.message);
            }

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
                    widget = new Widgets.Monitoring (headerbar.view_box, current_color ());
                    statusbar.set_sensitive (false);
                } else if (headerbar.view_box.selected == 2) {
                    widget = get_scrolled_window (new Widgets.Disks ());
                    statusbar.set_sensitive (false);
                } else {
                    generic_model = new Models.GenericModel ();
                    process_view = new Widgets.Process (generic_model);
                    widget = get_scrolled_window (process_view);
                    statusbar.set_sensitive (true);
                    statusbar.set_sensitive (true);
                }
                if (widget != null) {
                    var exist_widget = view.get_child_at (0,0);

                    if (exist_widget != null) {
                        exist_widget.destroy ();
                    }

                    view.attach (widget, 0, 0, 1, 1);
                }
            });

            headerbar.view_box.selected = 0;
            init_statusbar (statusbar);
        }

        private Gdk.RGBA current_color () {
            return get_style_context ().get_color (Gtk.StateFlags.NORMAL);
        }

        private void init_statusbar (Widgets.Statusbar statusbar) {
            var kill_process_button = new Gtk.Button.with_label (_("End process"));
            kill_process_button.valign = Gtk.Align.CENTER;
            kill_process_button.margin = 10;
            kill_process_button.clicked.connect (process_view.kill_process);
            /* kill_process_button.tooltip_text = ("Ctrl+E"); */

            statusbar.pack_start (kill_process_button);

            Widgets.Search search = new Widgets.Search (process_view, generic_model);
            search.valign = Gtk.Align.CENTER;
            statusbar.pack_end (search);
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
