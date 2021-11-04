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
    public abstract class Tools.DrawBody : Gtk.DrawingArea {
        protected int bound_width;
        protected int bound_height;

        protected int text_size = 0;

        protected Structs.DrawFields fields;

        protected Pango.FontDescription description_layout;

        construct {
            if (text_size > 0) {
                description_layout = new Pango.FontDescription ();
                description_layout.set_size ((int) (text_size * Pango.SCALE));
                description_layout.set_weight (Pango.Weight.NORMAL);
            }
        }

        protected void draw_background (Cairo.Context ctx) {
            ctx.save ();

            ctx.set_source_rgba (0.24, 0.35, 0.36, 1);
            ctx.rectangle (0, 0, bound_width, bound_height);
            ctx.fill();

            ctx.restore ();
        }

        protected void draw_axes (Cairo.Context ctx) {
            ctx.save ();

            ctx.set_source_rgba (1.0, 0.92, 0.80, 1.0);
            ctx.move_to (fields.left, fields.top);
            ctx.line_to (fields.left, bound_height - fields.bottom);
            ctx.line_to (bound_width - fields.right, bound_height - fields.bottom);
            ctx.stroke ();

            ctx.restore ();
        }

        protected void draw_horizontal_grid (Cairo.Context ctx, int grid_size) {
            ctx.save ();

            int inc = grid_size;
            int bottom_grid = bound_height - fields.bottom;
            int right_grid = bound_width - fields.right;

            ctx.set_source_rgba (1.0, 0.92, 0.80, 0.5);
            ctx.set_line_width (0.5);

            while ((bottom_grid - inc) >= fields.top) {
                int y_coord = bottom_grid - inc;
                ctx.move_to (fields.left, y_coord);
                ctx.line_to (right_grid, y_coord);

                inc += grid_size;
            }
            ctx.stroke ();

            ctx.restore ();
        }

        protected void draw_vertical_grid (Cairo.Context ctx, int grid_size) {
            ctx.save ();

            int bottom_grid = bound_height - fields.bottom;
            int right_grid = bound_width - fields.right;
            int inc = right_grid - fields.left;

            ctx.set_source_rgba (1.0, 0.92, 0.80, 0.5);
            ctx.set_line_width (0.5);

            while (inc > 0) {
                int x_coord = inc + fields.left;
                ctx.move_to (x_coord, fields.top);
                ctx.line_to (x_coord, bottom_grid);

                inc -= 20;
            }
            ctx.stroke ();

            ctx.restore ();
        }

        protected void draw_text (Cairo.Context ctx, Pango.Layout text, int x_pos, int y_pos, int custom_w = 0, int custom_h = 0) {
            ctx.save ();
            ctx.set_source_rgba (1.0, 0.92, 0.80, 1.0);

            int fontw, fonth;
            if (custom_h == 0 || custom_w == 0) {
                text.get_pixel_size (out fontw, out fonth);
            } else {
                fontw = custom_w;
                fonth = custom_h;
            }

            ctx.move_to (x_pos - (fontw / 2), y_pos - (fonth / 2));

            Pango.cairo_update_layout (ctx, text);
            Pango.cairo_show_layout (ctx, text);

            ctx.restore ();
        }

        public override void get_preferred_height (out int minimum_height, out int natural_height) {
            minimum_height = bound_height;
            natural_height = bound_height;
        }
    }
}
