/*
 * Copyright (c) 2020 Dirli <litandrej85@gmail.com>
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
    public class Tools.DrawVolume : Gtk.DrawingArea {
        public int custom_width {get; construct set;}
        public int used_percent {get; construct set;}
        public string volume_size {get; construct set;}

        private Pango.Layout area_title;

        public DrawVolume (int widget_width, string vol_size, int used_percent = 0) {
            Object (valign: Gtk.Align.FILL,
                    custom_width: widget_width,
                    used_percent: used_percent,
                    volume_size: vol_size);
        }

        construct {
            // doesn't display without this action. i don't know why
            get_style_context ().add_class ("volume-wrapper");

            add_events(Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.ENTER_NOTIFY_MASK);

            // create title
            var description_layout = new Pango.FontDescription ();
            description_layout.set_size ((int) (14 * Pango.SCALE));
            description_layout.set_weight (Pango.Weight.NORMAL);

            area_title = used_percent == 0
                         ? create_pango_layout (volume_size)
                         : area_title = create_pango_layout ("%d %%".printf (used_percent));

            area_title.set_font_description (description_layout);
            area_title.set_ellipsize (Pango.EllipsizeMode.START);

            draw.connect (on_draw);
        }

        public bool on_draw (Cairo.Context cr) {
            cr.set_source_rgba (0.24, 0.35, 0.36, 1);
            cr.rectangle (1, 1, custom_width - 2, 60);
            cr.fill ();

            if (used_percent != 0) {
                cr.set_source_rgba (0.35, 0.85, 0.73, 1);
                cr.rectangle (1, 1, used_percent * custom_width / 100 - 2, 60);
                cr.fill ();
            }

            cr.set_source_rgba (1, 1, 1, 1);
            cr.set_line_width (2);
            cr.rectangle (1, 1, custom_width - 2, 60);
            cr.stroke ();

            // title
            int fontw, fonth;

            var y = 60 / 2;
            var x = custom_width / 2;

            area_title.get_pixel_size (out fontw, out fonth);

            cr.move_to (x - (fontw / 2), y - (fonth / 2));

            Pango.cairo_update_layout (cr, area_title);
            Pango.cairo_show_layout (cr, area_title);

            return true;
        }

        public override bool enter_notify_event (Gdk.EventCrossing e)  {
            e.window.set_cursor (new Gdk.Cursor.from_name(Gdk.Display.get_default(), "hand2"));

            return true;
        }

        public override void get_preferred_width (out int minimum_width, out int natural_width) {
            minimum_width = 0;
            natural_width = custom_width;
        }
    }
}
