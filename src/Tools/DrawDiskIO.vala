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
    public class Tools.DrawDiskIO : Tools.DrawBody {
        private bool draw_graphic = false;

        private uint64 max_scale = 0;
        private uint64 _max_point = 0;
        public uint64 max_point {
            get {
                return _max_point;
            }
            private set {
                if (value == 0) {
                    value = 1;
                }

                if (max_point != value) {
                    _max_point = value;
                    scale_titles = round_max (value);
                }
            }
        }

        private string[] scale_titles;

        private uint64 last_read = 0;
        private uint64 last_write = 0;

        public Enums.ViewIO view_io = Enums.ViewIO.ALL;

        private uint64[] read_points;
        private uint64[] write_points;

        public DrawDiskIO () {
            fields = Structs.DrawFields () {left = 60, bottom = 35, top = 5, right = 5};
            read_points = {};
            write_points = {};

            text_size = 8;

            bound_width = 0;
            bound_height = 140;

            size_allocate.connect ((allocation) => {
                bound_width = allocation.width;
                draw_graphic = false;
            });
            draw.connect (on_draw);
        }

        public void add_values (uint64 read_value, uint64 write_value) {
            if (max_point < uint64.max (read_value, write_value)) {
                max_point = uint64.max (read_value, write_value);
            }

            read_points += read_value;
            write_points += write_value;

            last_read = read_value;
            last_write = write_value;

            draw_graphic = true;

            queue_draw ();
        }

        private bool on_draw (Cairo.Context ctx) {
            int right_grid = bound_width - fields.right;

            ctx.set_source_rgba (1.0, 0.92, 0.80, 1.0);

            draw_axes (ctx);
            draw_horizontal_grid (ctx, 20);
            draw_vertical_grid (ctx, 20);

            int y_title = fields.top;
            if (scale_titles.length == 3) {
                foreach (string title in scale_titles) {
                    var h_text = create_pango_layout (title);
                    h_text.set_font_description (description_layout);
                    draw_text (ctx, h_text, fields.left / 2, y_title);
                    y_title += 40;
                }
            }

            int inc = right_grid - fields.left;

            int sec_label = 0;
            while (inc > 0) {
                if (sec_label == 0 || sec_label % 60 == 0) {
                    var v_text = create_pango_layout ("%d m".printf (sec_label / 60));
                    v_text.set_font_description (description_layout);
                    draw_text (ctx, v_text, inc + fields.left, bound_height - 25);
                }

                sec_label += 10;
                inc -= 20;
            }

            draw_legend (ctx);

            // graphic
            if (draw_graphic) {
                draw_graphic = false;

                int sec_total = (right_grid - fields.left) / 2;
                var points_length = read_points.length;

                int iter_count = int.min (points_length, sec_total);
                if (iter_count < 2) {return true;}

                if (points_length > sec_total) {
                    read_points = read_points[points_length - sec_total : points_length];
                    write_points = write_points[points_length - sec_total : points_length];
                }

                int x_point = right_grid - iter_count * 2;

                uint64 new_max_read = 0;
                if (view_io != Enums.ViewIO.WRITE) {
                    ctx.set_source_rgba (0, 1.0, 0, 1);
                    new_max_read = draw_points (ctx, read_points, x_point, iter_count);
                }

                uint64 new_max_write = 0;
                if (view_io != Enums.ViewIO.READ) {
                    ctx.set_source_rgba (1.0, 0, 0, 1);
                    new_max_write = draw_points (ctx, write_points, x_point, iter_count);
                }

                max_point = uint64.max (new_max_read, new_max_write);
            }

            return true;
        }

        private uint64 draw_points (Cairo.Context ctx, uint64[] points, int start_point, int count) {
            uint64 max = 0;
            int x_point = start_point;

            int bottom_grid = bound_height - fields.bottom;

            ctx.move_to (x_point, bottom_grid - (int) (points[0] * 100.0 / max_scale));

            for (int i = 1; i < count; i++) {
                uint64 next_point = points[i];
                if (next_point > max) {
                    max = next_point;
                }

                x_point += 2;
                ctx.line_to (x_point, bottom_grid - (int) (next_point * 100.0 / max_scale));
            }

            ctx.stroke ();

            return max;
        }

        private void draw_legend (Cairo.Context ctx) {
            ctx.save ();

            int r_fontw, w_fontw, fonth;
            var write_text = create_pango_layout (_("Write") + " (999 KB/s) ");
            write_text.set_font_description (description_layout);
            write_text.get_pixel_size (out w_fontw, out fonth);

            write_text.set_text (_("Write") + @" ($(Utils.format_bytes (last_write))) ", -1);

            ctx.set_source_rgba (1.0, 0, 0, 1);
            ctx.rectangle (fields.left, bound_height - 15, 10, 10);
            ctx.fill();

            draw_text (ctx, write_text, fields.left + w_fontw / 2 + 15, bound_height - 10, w_fontw, fonth);

            var read_text = create_pango_layout (_("Read") + @" ($(Utils.format_bytes (last_read))) ");
            read_text.set_font_description (description_layout);
            read_text.get_pixel_size (out r_fontw, out fonth);

            ctx.set_source_rgba (0, 1.0, 0, 1);
            ctx.rectangle (fields.left + 20 + w_fontw, bound_height - 15, 10, 10);
            ctx.fill();

            draw_text (ctx, read_text, fields.left + w_fontw + 35 + r_fontw / 2, bound_height - 10);

            ctx.restore ();
        }

        private string[] round_max (uint64 max_val) {
            string[] scale_elems = {};
            string[] sizes = { "B", "KB", "MB", "GB", "TB" };
            double len = (double) max_val;
            int order = 0;

            while (len >= 1024 && order < sizes.length - 1) {
                order++;
                len = len / 1024;
            }

            uint64 tmp_scale = (uint64) (GLib.Math.round (len / 5.0 + 0.5) * 5);

            scale_elems += @"$(tmp_scale) $(sizes[order])";
            scale_elems += @"$(tmp_scale * 3 / 5) $(sizes[order])";
            scale_elems += @"$(tmp_scale / 5) $(sizes[order])";

            while (order-- > 0) {
                tmp_scale *= 1024;
            }

            max_scale = tmp_scale;

            return scale_elems;
        }

        public void clear_cache () {
            max_scale = 0;
            _max_point = 0;

            scale_titles = {};

            write_points = {};
            read_points = {};
        }

        public override void get_preferred_width (out int minimum_width, out int natural_width) {
            minimum_width = bound_width;
            natural_width = bound_width;
        }
    }
}
