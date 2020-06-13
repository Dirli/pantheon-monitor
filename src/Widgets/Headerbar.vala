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
    public class Widgets.Headerbar : Gtk.HeaderBar {
        public Headerbar (MainWindow window) {
            show_close_button = true;
            has_subtitle = false;
            title = "Monitor";

            var menu_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
#if INDICATOR_EXIST
            var preferences_button = new Gtk.ModelButton ();
            preferences_button.text = _("Preferences");
            preferences_button.clicked.connect (() => {
                var preferences = new Dialogs.Preferences ();
                preferences.run ();
            });
            menu_box.add (preferences_button);
#endif
            var about_button = new Gtk.ModelButton ();
            about_button.text = _("About");
            about_button.clicked.connect (() => {
                var about = new Dialogs.About ();
                about.run ();
            });
            menu_box.add (about_button);

            menu_box.show_all ();

            var popover_menu = new Gtk.Popover (null);
            popover_menu.add (menu_box);

            var app_button = new Gtk.MenuButton ();
            app_button.popover = popover_menu;
            app_button.tooltip_text = _("Options");
            app_button.image = new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.BUTTON);

            pack_end (app_button);
        }
    }
}
