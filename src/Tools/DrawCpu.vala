namespace Monitor {
    public class Tools.DrawCpu : Gtk.DrawingArea {
        private int cores;
        private int grid_width;
        private int bound_width;
        private int bound_height = 110;
        private int field = 5;
        private int column_width = 30;

        private int[] percent = {};

        private Pango.FontDescription description_layout;

        public Gdk.RGBA font_color;

        public DrawCpu (Gdk.RGBA font_color, int cores) {
            this.font_color = font_color;
            this.cores = cores;

            grid_width = cores * column_width;
            bound_width = grid_width + column_width;

            description_layout = new Pango.FontDescription ();
            description_layout.set_size ((int) (8 * Pango.SCALE));
            description_layout.set_weight (Pango.Weight.NORMAL);

            draw.connect (on_draw);
        }

        private bool on_draw (Cairo.Context ctx) {
            // background
            ctx.rectangle (0, 0, bound_width, bound_height);
            ctx.set_source_rgba (1.0, 0.92, 0.80, 1.0);
            ctx.fill();

            ctx.set_source_rgba (0.24, 0.35, 0.36, 1);

            // grid
            ctx.move_to (column_width, field);
            ctx.line_to (column_width, bound_height - field);
            ctx.move_to (column_width, bound_height - field);
            ctx.line_to (bound_width - 5, bound_height - field);

            ctx.stroke ();
            ctx.save ();

            ctx.set_source_rgba (0.24, 0.35, 0.36, 0.5);
            ctx.set_line_width (0.5);

            ctx.move_to (column_width, bound_height - field - 25);
            ctx.line_to (bound_width - 5, bound_height - field - 25);

            ctx.move_to (column_width, bound_height - field - 50);
            ctx.line_to (bound_width - 5, bound_height - field - 50);

            ctx.move_to (column_width, bound_height - field - 75);
            ctx.line_to (bound_width - 5, bound_height - field - 75);

            ctx.move_to (column_width, field);
            ctx.line_to (bound_width - 5, field);

            ctx.stroke ();
            ctx.restore ();

            create_scale_element (ctx, "100", Gtk.Align.START);
            create_scale_element (ctx, "50", Gtk.Align.CENTER);
            create_scale_element (ctx, "0", Gtk.Align.END);

            if (percent.length > 0) {
                ctx.set_source_rgba (0.35, 0.85, 0.73, 1);
                for (int core = 0; core < cores; core++) {
                    ctx.rectangle (35 + column_width * core, bound_height - percent[core] - field, 20, percent[core]);
                    ctx.fill();
                }
            }

            return true;
        }

        private void create_scale_element (Cairo.Context ctx, string layout_text, Gtk.Align align_text) {
            var layout_number = create_pango_layout (layout_text);
            layout_number.set_font_description (description_layout);

            int fontw, fonth;
            layout_number.get_pixel_size (out fontw, out fonth);

            if (Gtk.Align.CENTER == align_text) {
                ctx.move_to (15 - (fontw / 2), (bound_height / 2) - (fonth / 2));
            } else if (Gtk.Align.START == align_text) {
                ctx.move_to (15 - (fontw / 2), 0);
            } else if (Gtk.Align.END == align_text) {
                ctx.move_to (15 - (fontw / 2), bound_height - fonth);
            } else {
                return;
            }

            Pango.cairo_update_layout (ctx, layout_number);
            Pango.cairo_show_layout (ctx, layout_number);
        }

        public void update_used (int[] cores_percent) {
            this.percent = cores_percent;

            queue_draw ();
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
