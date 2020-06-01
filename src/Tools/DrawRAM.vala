namespace Monitor {
    public class Tools.DrawRAM : Gtk.DrawingArea {
        private int bound_width = 0;
        private int bound_height = 30;

        private int used_memory = 0;

        private Pango.FontDescription description_layout;

        public Gdk.RGBA font_color;

        public DrawRAM (Gdk.RGBA font_color) {
            this.font_color = font_color;

            description_layout = new Pango.FontDescription ();
            description_layout.set_size ((int) (14 * Pango.SCALE));
            description_layout.set_weight (Pango.Weight.NORMAL);

            size_allocate.connect ((allocation) => {
                bound_width = allocation.width;
            });
            draw.connect (on_draw);
        }

        private bool on_draw (Cairo.Context ctx) {
            // background
            ctx.rectangle (0, 0, bound_width, bound_height);
            ctx.set_source_rgba (1.0, 0.92, 0.80, 1.0);
            ctx.fill();

            if (used_memory == 0) {
                return true;
            }

            // used rectangle
            ctx.rectangle (0, 0, (bound_width * used_memory) / 100, bound_height);
            ctx.set_source_rgba (0.35, 0.85, 0.73, 1);
            ctx.fill();

            // text
            ctx.set_source_rgba (font_color.red, font_color.green, font_color.blue, 1);

            var used_name = create_pango_layout ("%d%%".printf (used_memory));
            used_name.set_font_description (description_layout);

            int fontw, fonth;

            var y = bound_height / 2;
            var x = ((bound_width * used_memory) / 100) / 2;

            used_name.get_pixel_size (out fontw, out fonth);

            ctx.move_to (x - (fontw / 2), y - (fonth / 2));

            Pango.cairo_update_layout (ctx, used_name);
            Pango.cairo_show_layout (ctx, used_name);

            return true;
        }

        public void update_used (int used_percent) {
            used_memory = used_percent;

            queue_draw ();
        }

        public override void get_preferred_height (out int minimum_height, out int natural_height) {
            minimum_height = bound_height;
            natural_height = bound_height;
        }
    }
}
