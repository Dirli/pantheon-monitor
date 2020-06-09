namespace Monitor {
    public class Tools.DrawRAM : Tools.DrawBody {
        private int used_memory = 0;

        public DrawRAM () {
            bound_width = 0;
            bound_height = 30;

            text_size = 14;

            size_allocate.connect ((allocation) => {
                bound_width = allocation.width;
            });
            draw.connect (on_draw);
        }

        private bool on_draw (Cairo.Context ctx) {
            draw_background (ctx);

            if (used_memory == 0) {
                return true;
            }

            // used rectangle
            ctx.rectangle (0, 0, (bound_width * used_memory) / 100, bound_height);
            ctx.set_source_rgba (0.35, 0.85, 0.73, 1);
            ctx.fill();

            // text
            ctx.set_source_rgba (1.0, 0.92, 0.80, 1.0);

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
    }
}
