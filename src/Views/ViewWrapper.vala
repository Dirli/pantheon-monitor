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

        public Gtk.ScrolledWindow s_window;
        protected Gtk.Stack widget_stack;
        protected Gtk.Container main_widget;

        construct {
            s_window = new Gtk.ScrolledWindow (null, null);

            s_window.expand = true;
            s_window.margin_start = s_window.margin_end = 15;
            s_window.margin_top = s_window.margin_bottom = 10;

            widget_stack = new Gtk.Stack ();
            widget_stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
            s_window.add (widget_stack);

            add (s_window);
        }

        protected bool init_main_widget () {
            if (main_widget == null) {
                return false;
            }

            widget_stack.add_named (main_widget, "main");

            return true;
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
