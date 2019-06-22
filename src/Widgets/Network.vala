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
    public class Widgets.Network : Services.Circle {
        public int net_speed { get; set; default = 0;}

        public Network (string net_name, Gdk.RGBA current_color) {
            // _net_speed = 0;
            layout_name = create_pango_layout (net_name);
            layout_name.set_font_description (description_name);
            t_color = current_color;
        }

        public override string get_signature () {
            return Utils.format_net_speed ((uint64) net_speed);
        }

        protected override void draw_numbers (Cairo.Context cr, double center_x, double center_y, float radius){
            cr.save ();
            cr.set_line_width (line_width / 2);
            cr.set_line_cap (Cairo.LineCap.ROUND);
            cr.set_line_join (Cairo.LineJoin.ROUND);

            float x, y;
            float numbers_iter = (float) max_numbers / 10;

            for (int i = 0; i <= 10; i++) {
                var position = numbers_iter * i;
                var porcentage = (float) position / max_numbers;
                var preprogress = 225 - 270 * porcentage;
                var arc_progress = 0f;
                if (preprogress < 0) {
                    arc_progress = 360 - preprogress.abs();
                } else {
                    arc_progress = preprogress;
                }

                util.get_point_circuference (radius - line_width * 2.75f, arc_progress, (float) center_x, (float) center_y, out x, out y);

                if (t_color != null) {
                    cr.set_source_rgba (t_color.red, t_color.green, t_color.blue, 1);
                } else {
                    cr.set_source_rgba (util.get_rgb_gtk (205), util.get_rgb_gtk (208), util.get_rgb_gtk (213), 1);
                }

                /* core tag */
                var description = new Pango.FontDescription();
                description.set_size ((int)(7 * Pango.SCALE));
                description.set_weight (Pango.Weight.NORMAL);

                var layout = create_pango_layout ("%.1f".printf (position));
                layout.set_font_description (description);

                int fontw, fonth;
                layout.get_pixel_size (out fontw, out fonth);
                cr.move_to (x - fontw / 2, y - fonth / 2);

                Pango.cairo_update_layout (cr, layout);
                Pango.cairo_show_layout (cr, layout);
            }
            cr.restore ();
        }
    }
}
