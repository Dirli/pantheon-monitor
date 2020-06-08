namespace Monitor {
    public class Tools.DrawDiskIO : Gtk.DrawingArea {
        private bool draw_graphic = false;

        private uint64 max_scale = 0;
        private uint64 _max_point = 0;
        public uint64 max_point {
            get {
                return _max_point;
            }
            set {
                if (value > 0 && max_point != value) {
                    _max_point = value;
                    scale_titles = round_max (value);
                }
            }
        }

        private int bound_width = 0;
        private int bound_height = 140;

        private int left_field = 60;
        private int field = 5;
        private int bottom_field = 35;

        private string[] scale_titles;

        private uint64[] read_points;
        private uint64[] write_points;

        private Pango.FontDescription description_layout;

        public DrawDiskIO () {
            read_points = {};
            write_points = {};

            description_layout = new Pango.FontDescription ();
            description_layout.set_size ((int) (8 * Pango.SCALE));
            description_layout.set_weight (Pango.Weight.NORMAL);

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

            draw_graphic = true;

            queue_draw ();
        }

        private bool on_draw (Cairo.Context ctx) {
            // background
            ctx.rectangle (0, 0, bound_width, bound_height);
            ctx.set_source_rgba (0.24, 0.35, 0.36, 1);
            ctx.fill();

            int bottom_grid = bound_height - bottom_field;
            int right_grid = bound_width - field;

            // grid
            ctx.set_source_rgba (1.0, 0.92, 0.80, 1.0);
            ctx.move_to (left_field, field);
            ctx.line_to (left_field, bottom_grid);
            ctx.line_to (right_grid, bottom_grid);

            ctx.stroke ();
            ctx.save ();
            int y_title = field;
            if (scale_titles.length == 3) {
                foreach (string title in scale_titles) {
                    create_scale_element (ctx, title, y_title);
                    y_title += 40;
                }
            }

            ctx.set_line_width (0.5);
            // horizontal grid
            int dec = 20;
            while ((bottom_grid - dec) >= field) {
                int y_coord = bottom_grid - dec;
                ctx.move_to (left_field, y_coord);
                ctx.line_to (right_grid, y_coord);

                dec += 20;
            }

            ctx.stroke ();

            // verical grid
            int inc = right_grid - left_field;

            int sec_label = 0;
            while (inc > 0) {
                int x_coord = inc + left_field;
                ctx.move_to (x_coord, field);
                ctx.line_to (x_coord, bottom_grid);

                if (sec_label == 0 || sec_label % 60 == 0) {
                    var time_layout = create_pango_layout ("%d m".printf (sec_label / 60));
                    time_layout.set_font_description (description_layout);

                    int fontw, fonth;
                    time_layout.get_pixel_size (out fontw, out fonth);

                    ctx.move_to (x_coord - (fontw / 2), bound_height - 25 - (fonth / 2));
                    Pango.cairo_update_layout (ctx, time_layout);
                    Pango.cairo_show_layout (ctx, time_layout);
                }

                sec_label += 10;
                inc -= 20;
            }

            ctx.stroke ();
            ctx.restore ();

            // legend
            ctx.set_source_rgba (1.0, 0, 0, 1);
            ctx.rectangle (left_field, bound_height - 15, 10, 10);
            ctx.fill();

            ctx.set_source_rgba (1.0, 0.92, 0.80, 1.0);
            var write_layout = create_pango_layout (_("Write"));
            write_layout.set_font_description (description_layout);

            int fontw, fonth;
            write_layout.get_pixel_size (out fontw, out fonth);

            ctx.move_to (left_field + 15, bound_height - 10 - (fonth / 2));
            Pango.cairo_update_layout (ctx, write_layout);
            Pango.cairo_show_layout (ctx, write_layout);

            ctx.set_source_rgba (0, 1.0, 0, 1);
            ctx.rectangle (left_field + 20 + fontw, bound_height - 15, 10, 10);
            ctx.fill();

            ctx.set_source_rgba (1.0, 0.92, 0.80, 1.0);
            var read_layout = create_pango_layout (_("Read"));
            read_layout.set_font_description (description_layout);

            read_layout.get_pixel_size (out fontw, out fonth);

            ctx.move_to (left_field + 35 + fontw, bound_height - 10 - (fonth / 2));
            Pango.cairo_update_layout (ctx, read_layout);
            Pango.cairo_show_layout (ctx, read_layout);

            // graphic
            if (draw_graphic) {
                draw_graphic = false;

                int sec_total = (right_grid - left_field) / 2;
                var points_length = read_points.length;

                int iter_count = int.min (points_length, sec_total);
                if (iter_count < 2) {return true;}

                if (points_length > sec_total) {
                    read_points = read_points[points_length - sec_total : points_length];
                    write_points = write_points[points_length - sec_total : points_length];
                }

                int x_point = right_grid - iter_count * 2;
                uint64 new_max = 0;

                ctx.move_to (x_point, bottom_grid - (int) (read_points[0] * 100.0 / max_scale));
                ctx.set_source_rgba (0, 1.0, 0, 1);

                for (int i = 1; i < iter_count; i++) {
                    uint64 next_point = read_points[i];
                    if (next_point > new_max) {
                        new_max = next_point;
                    }

                    x_point += 2;
                    ctx.line_to (x_point, bottom_grid - (int) (next_point * 100.0 / max_scale));
                }
                ctx.stroke ();

                x_point = right_grid - iter_count * 2;
                ctx.move_to (x_point, bottom_grid - (int) (write_points[0] * 100.0 / max_scale));
                ctx.set_source_rgba (1.0, 0, 0, 1);

                for (int i = 1; i < iter_count; i++) {
                    uint64 next_point = write_points[i];
                    if (next_point > new_max) {
                        new_max = next_point;
                    }

                    x_point += 2;
                    ctx.line_to (x_point, bottom_grid - (int) (next_point * 100.0 / max_scale));
                }
                ctx.stroke ();

                if (new_max > 0) {
                    max_point = new_max;
                }
            }

            return true;
        }

        private void create_scale_element (Cairo.Context ctx, string layout_text, int y_pos) {
            var text = create_pango_layout (layout_text);
            text.set_font_description (description_layout);

            int fontw, fonth;
            text.get_pixel_size (out fontw, out fonth);

            ctx.move_to (left_field / 2 - (fontw / 2), y_pos - (fonth / 2));

            Pango.cairo_update_layout (ctx, text);
            Pango.cairo_show_layout (ctx, text);
        }

        private string[] round_max (uint64 max_val) {
            string[] scale_elems = {};

            string[] sizes = { "B", "KB", "MB", "GB", "TB" };
            double len = (double) max_val;
            int order = 0;

            while (len >= 1024 && order < sizes.length - 1) {
                order++;
                len = len/1024;
            }


            uint64 tmp_scale = (uint64) (GLib.Math.round (len / 5.0) * 5);

            scale_elems += "%llu %s".printf (tmp_scale, sizes[order]);
            scale_elems += "%llu %s".printf (tmp_scale * 3 / 5, sizes[order]);
            scale_elems += "%llu %s".printf (tmp_scale / 5, sizes[order]);

            while (order-- > 0) {
                tmp_scale *= 1024;
            }

            max_scale = tmp_scale;

            return scale_elems;
        }

        public override void get_preferred_height (out int minimum_height, out int natural_height) {
            minimum_height = bound_height;
            natural_height = bound_height;
        }

        public override void get_preferred_width (out int minimum_width, out int natural_width) {
            minimum_width = bound_width;
            natural_width = bound_width;
        }
    }
}
