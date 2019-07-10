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
        construct {
            show_close_button = true;
            has_subtitle = false;
            title = "Monitor";
        }

        public Granite.Widgets.ModeButton view_box;

        public Headerbar (MainWindow window) {
            view_box = new Granite.Widgets.ModeButton ();
            view_box.homogeneous = false;
            view_box.valign = Gtk.Align.CENTER;
            pack_start (view_box);

            Gtk.Image proc_button = new Gtk.Image.from_icon_name ("view-list-symbolic", Gtk.IconSize.BUTTON);
            proc_button.tooltip_text = _("Processes");
            proc_button.margin_start = proc_button.margin_end = 5;
            view_box.append (proc_button);

            Gtk.Image mon_button = new Gtk.Image.from_icon_name ("utilities-system-monitor-symbolic", Gtk.IconSize.BUTTON);
            mon_button.tooltip_text = _("Monitor");
            mon_button.margin_start = mon_button.margin_end = 5;
            view_box.append (mon_button);

            Gtk.Image disk_button = new Gtk.Image.from_icon_name ("drive-harddisk-symbolic", Gtk.IconSize.BUTTON);
            disk_button.tooltip_text = _("Disks");
            disk_button.margin_start = disk_button.margin_end = 5;
            view_box.append (disk_button);

            Gtk.Menu menu = new Gtk.Menu ();
            var pref_item = new Gtk.MenuItem.with_label (_("Preferences"));
            var about_item = new Gtk.MenuItem.with_label (_("About"));
            menu.add (pref_item);
            menu.add (about_item);
            pref_item.activate.connect (() => {
                var preferences = new Widgets.Preferences (window, view_box);
                preferences.run ();
            });
            about_item.activate.connect (() => {
                var about = new Widgets.About ();
                about.show ();
            });

            var app_button = new Gtk.MenuButton ();
            app_button.popup = menu;
            app_button.tooltip_text = _("Options");
            app_button.image = new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.BUTTON);
            menu.show_all ();
            pack_end (app_button);
        }
    }
}
