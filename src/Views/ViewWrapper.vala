/*
 * Copyright (c) 2020-2022 Dirli <litandrej85@gmail.com>
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
    public abstract class Views.ViewWrapper : Gtk.Box {
        public abstract void start_timer ();
        public abstract void stop_timer ();

        public Gtk.ScrolledWindow main_widget;

        construct {
            main_widget = new Gtk.ScrolledWindow (null, null);

            main_widget.expand = true;
            main_widget.margin_start = main_widget.margin_end = 15;
            main_widget.margin_top = main_widget.margin_bottom = 10;

            add (main_widget);
        }

        protected Gtk.Box get_wrap_box () {
            var wrap_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                // hexpand = true,
                halign = Gtk.Align.FILL
            };
            unowned Gtk.StyleContext box_style_context = wrap_box.get_style_context ();
            box_style_context.add_class (Granite.STYLE_CLASS_CARD);
            box_style_context.add_class (Granite.STYLE_CLASS_ROUNDED);

            return wrap_box;
        }

    }
}
