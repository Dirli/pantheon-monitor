namespace Monitor {
    public class Tools.DrawSmart : Gtk.DrawingArea {
        public uint life_percent {get; construct set;}
        public bool fail_smart {get; construct set;}

        public int custom_width {get; construct set;}
        public int custom_height {get; construct set;}

        private Pango.Layout area_title;

        public DrawSmart (uint life, bool fail, Gtk.Allocation alloc) {
            Object (halign: Gtk.Align.FILL,
                    valign: Gtk.Align.FILL,
                    vexpand: true,
                    life_percent: life,
                    fail_smart: fail,
                    custom_width: alloc.width,
                    custom_height: alloc.height);
        }

        construct {
            // create title
            var description_layout = new Pango.FontDescription ();
            description_layout.set_size ((int) (11 * Pango.SCALE));
            description_layout.set_weight (Pango.Weight.NORMAL);

            area_title = life_percent > 0
                         ? create_pango_layout (@"$(life_percent)%")
                         : create_pango_layout (fail_smart ? "Fail" : "Ok");

            area_title.set_font_description (description_layout);
            area_title.set_ellipsize (Pango.EllipsizeMode.START);

            draw.connect (on_draw);
        }

        public bool on_draw (Cairo.Context cr) {
            if (fail_smart) {
                cr.set_source_rgba (1, 0.07, 0.57, 1);
            } else {
                cr.set_source_rgba (0.35, 0.85, 0.73, 1);
            }

            cr.rectangle (1, 1, custom_width, custom_height);
            cr.fill ();

            if (life_percent > 0 && life_percent < 100) {
                cr.set_source_rgba (0.24, 0.35, 0.36, 1);
                cr.rectangle (life_percent * custom_width / 100, 1, custom_width, custom_height);
                cr.fill ();
            }

            cr.set_source_rgba (1, 1, 1, 1);

            // title
            var x = custom_width / 2;
            var y = custom_height / 2;

            int fontw, fonth;
            area_title.get_pixel_size (out fontw, out fonth);

            cr.move_to (x - (fontw / 2), y - (fonth / 2));

            Pango.cairo_update_layout (cr, area_title);
            Pango.cairo_show_layout (cr, area_title);

            return true;
        }

        public override void get_preferred_height (out int minimum_height, out int natural_height) {
            minimum_height = 0;
            natural_height = custom_height;
        }

        public override void get_preferred_width (out int minimum_width, out int natural_width) {
            minimum_width = 0;
            natural_width = custom_width;
        }
    }
}
