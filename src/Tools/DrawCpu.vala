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
    public class Tools.DrawCpu : Tools.DrawBody {
        public int cores {
            get;
            construct set;
        }

        private int column_width = 30;

        private int[] percent = {};

        public DrawCpu (int cores) {
            Object (cores: cores);
        }

        construct {
            fields = Structs.DrawFields () {left = 35, bottom = 5, top = 5, right = 5};

            text_size = 8;

            bound_width = cores * column_width + fields.left + fields.right;
            bound_height = 110;

            draw.connect (on_draw);
        }

        private bool on_draw (Cairo.Context ctx) {
            draw_background (ctx);

            draw_axes (ctx);
            draw_horizontal_grid (ctx, 25);

            var top_text = create_pango_layout ("100");
            top_text.set_font_description (description_layout);
            draw_text (ctx, top_text, fields.left / 2, text_size + fields.top);
            var middle_text = create_pango_layout ("50");
            middle_text.set_font_description (description_layout);
            draw_text (ctx, middle_text, fields.left / 2, (bound_height - ( +(fields.bottom - fields.top))) / 2);
            var bottom_text = create_pango_layout ("0");
            bottom_text.set_font_description (description_layout);
            draw_text (ctx, bottom_text, fields.left / 2, bound_height - fields.bottom - text_size);

            if (percent.length > 0) {
                ctx.set_source_rgba (0.35, 0.85, 0.73, 1);
                for (int core = 0; core < cores; core++) {
                    ctx.rectangle (fields.left + column_width * core + 5, bound_height - percent[core] - fields.bottom, 20, percent[core]);
                    ctx.fill();
                }
            }

            return true;
        }

        // private void create_scale_element (Cairo.Context ctx, string layout_text, Gtk.Align align_text) {
        //     var layout_number = create_pango_layout (layout_text);
        //     layout_number.set_font_description (description_layout);
        //
        //     int fontw, fonth;
        //     layout_number.get_pixel_size (out fontw, out fonth);
        //
        //     if (Gtk.Align.CENTER == align_text) {
        //         ctx.move_to (15 - (fontw / 2), (bound_height / 2) - (fonth / 2));
        //     } else if (Gtk.Align.START == align_text) {
        //         ctx.move_to (15 - (fontw / 2), fields.top);
        //     } else if (Gtk.Align.END == align_text) {
        //         ctx.move_to (15 - (fontw / 2), bound_height - fields.bottom - fonth);
        //     } else {
        //         return;
        //     }
        //
        //     Pango.cairo_update_layout (ctx, layout_number);
        //     Pango.cairo_show_layout (ctx, layout_number);
        // }

        public void update_used (int[] cores_percent) {
            this.percent = cores_percent;

            queue_draw ();
        }

        public override void get_preferred_width (out int minimum_width, out int natural_width) {
            minimum_width = bound_width;
            natural_width = bound_width;
        }
    }
}
