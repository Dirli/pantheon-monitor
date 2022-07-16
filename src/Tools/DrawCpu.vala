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

        private Gdk.RGBA[] g_colors = {
            {red: 1.0, green: 0, blue: 0, alpha: 0.8},
            {red: 0, green: 1.0, blue: 0, alpha: 0.8},
            {red: 0, green: 0, blue: 1.0, alpha: 0.8},
            {red: 1.0, green: 1.0, blue: 0, alpha: 0.8},
            {red: 0, green: 0.5, blue: 0.5, alpha: 0.8},
            {red: 0, green: 0.5, blue: 0, alpha: 0.8},
            {red: 1.0, green: 0, blue: 1.0, alpha: 0.8},
            {red: 1.0, green: 0.65, blue: 0, alpha: 0.8},
            {red: 0, green: 1.0, blue: 1.0, alpha: 0.8},
            {red: 0.5, green: 0.5, blue: 0, alpha: 0.8},
            {red: 0.5, green: 0.5, blue: 0.5, alpha: 0.8},
            {red: 0.5, green: 0, blue: 0, alpha: 0.8},
            {red: 0.5, green: 0, blue: 0.5, alpha: 0.8},
            {red: 1.0, green: 0.39, blue: 0.28, alpha: 0.8},
            {red: 0.27, green: 0.65, blue: 0.82, alpha: 0.8},
            {red: 0.75, green: 0.75, blue: 0.75, alpha: 0.8}
        };

        private int column_width = 30;
        private int chart_size = 0;

        private int[] d_percent = {};
        private GLib.Array<GLib.Array> g_percent;

        private Enums.ViewCPU _view_type;
        public Enums.ViewCPU view_type {
            get {
                return _view_type;
            }
            set {
                if (value == Enums.ViewCPU.DIAGRAM) {
                    fields = Structs.DrawFields () {left = 35, bottom = 25, top = 5, right = 5};
                    bound_width = cores * column_width + fields.left + fields.right;
                    size_allocate.disconnect (on_size_allocate);
                    clear_cache ();
                } else {
                    fields = Structs.DrawFields () {left = 60, bottom = 25, top = 5, right = 5};
                    size_allocate.connect (on_size_allocate);
                }

                _view_type = value;
            }
        }

        public DrawCpu (int cores) {
            Object (hexpand: true,
                    cores: cores);
        }

        construct {
            text_size = 8;

            g_percent = new GLib.Array<GLib.Array> ();
            for (int i = 0; i < cores; i++) {
                g_percent.append_val (new GLib.Array<int> ());
            }

            bound_height = 130;

            draw.connect (on_draw);
        }

        private void on_size_allocate (Gtk.Allocation allocation) {
            bound_width = allocation.width;
            chart_size = (bound_width - fields.right - fields.left) / 2;
        }

        private bool on_draw (Cairo.Context ctx) {
            draw_axes (ctx);
            draw_horizontal_grid (ctx, 25);

            var top_text = create_pango_layout ("100");
            top_text.set_font_description (description_layout);
            draw_text (ctx, top_text, fields.left / 2, fields.top);
            var middle_text = create_pango_layout ("50");
            middle_text.set_font_description (description_layout);
            draw_text (ctx, middle_text, fields.left / 2, (bound_height - ( +(fields.bottom - fields.top))) / 2);
            var bottom_text = create_pango_layout ("0");
            bottom_text.set_font_description (description_layout);
            draw_text (ctx, bottom_text, fields.left / 2, bound_height - fields.bottom);

            if (view_type == Enums.ViewCPU.DIAGRAM) {
                draw_diagram (ctx);
            } else {
                draw_graphic (ctx);
            }

            return true;
        }

        private void draw_diagram (Cairo.Context ctx) {
            if (d_percent.length > 0) {
                ctx.save ();

                ctx.set_source_rgba (0.35, 0.85, 0.73, 1);
                for (int core = 0; core < cores; core++) {
                    ctx.rectangle (fields.left + column_width * core + 5, bound_height - d_percent[core] - fields.bottom, 20, d_percent[core]);
                    ctx.fill();
                }

                ctx.restore ();
            }
        }

        private void draw_graphic (Cairo.Context ctx) {
            ctx.save ();

            int iter_count = int.min ((int) g_percent.index (0).length, chart_size);
            if (iter_count < 2) {
                return;
            }

            int inc = chart_size * 2;

            int sec_label = 0;
            while (inc > 0) {
                if (sec_label == 0 || sec_label % 60 == 0) {
                    var v_text = create_pango_layout ("%d m".printf (sec_label / 60));
                    v_text.set_font_description (description_layout);
                    draw_text (ctx, v_text, inc + fields.left, bound_height - 10);
                }

                sec_label += 10;
                inc -= 20;
            }

            int x_point = bound_width - fields.right - iter_count * 2;

            for (int i = 0; i < cores; i++) {
                var cur_color = g_colors[int.min (i, g_colors.length - 1)];
                ctx.set_source_rgba (cur_color.red, cur_color.green, cur_color.blue, cur_color.alpha);

                var _arr = g_percent.index (i);
                draw_points (ctx, (int[]) _arr.data, x_point, iter_count);
            }

            ctx.restore ();
        }

        private void draw_points (Cairo.Context ctx, int[] points, int start_point, int count) {
            int x_point = start_point;
            int bottom_grid = bound_height - fields.bottom;

            ctx.move_to (x_point, bottom_grid - points[0]);

            for (int i = 1; i < count; i++) {
                uint64 next_point = points[i];

                x_point += 2;
                ctx.line_to (x_point, bottom_grid - next_point);
            }

            ctx.stroke ();
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
            if (view_type == Enums.ViewCPU.DIAGRAM) {
                d_percent = cores_percent;
            } else {
                if (cores_percent.length != cores || chart_size == 0) {
                    return;
                }

                int need_reduced = (int) g_percent.index (0).length - chart_size + 1;
                for (int i = 0; i < cores; i++) {
                    GLib.Array<int> _arr = g_percent.index (i);
                    if (need_reduced > 0) {
                        _arr._remove_range (0, need_reduced);
                    }

                    _arr.append_val (cores_percent[i]);
                }
            }

            queue_draw ();
        }

        private void clear_cache () {
            for (int i = 0; i < cores; i++) {
                g_percent.index (i).steal ();
            }
        }

        public override void get_preferred_width (out int minimum_width, out int natural_width) {
            minimum_width = bound_width;
            natural_width = bound_width;
        }
    }
}
