namespace Monitor {
    public class Widgets.VolumeIter : Gtk.EventBox {
        private int custom_width;
        private int percent_width;
        private Gtk.Popover volume_popover;

        public override bool draw (Cairo.Context cr) {
            cr.set_source_rgb (0.5, 0.5, 0.5);
            cr.rectangle (0, 0, percent_width, 55);
            cr.fill ();

            if (percent_width != custom_width) {
                cr.set_source_rgb (0.7, 0.7, 0.7);
                cr.rectangle (percent_width, 0, custom_width, 55);
                cr.fill ();
            }

            cr.set_source_rgb (1, 1, 1);
            cr.set_line_width (2);
            cr.rectangle (0, 0, custom_width, 55);
            cr.stroke ();

            return base.draw (cr);
        }

        public VolumeIter (int widget_width, Gtk.Widget popover_grid, string vol_size, int used_percent) {
            halign = Gtk.Align.START;
            valign = Gtk.Align.FILL;

            Gtk.Label inner_label;
            if (used_percent == 0) {
                inner_label = new Gtk.Label (vol_size);
            } else {
                inner_label = new Gtk.Label ("%d %%".printf (used_percent));
            }
            inner_label.set_ellipsize (Pango.EllipsizeMode.END);

            volume_popover = new Gtk.Popover (this);
            volume_popover.add (popover_grid);

            custom_width = widget_width;
            percent_width = used_percent == 0 ? widget_width : used_percent * widget_width / 100;
            add_events(Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.ENTER_NOTIFY_MASK);

            add (inner_label);

            queue_draw ();
        }

        public override bool enter_notify_event (Gdk.EventCrossing e)  {
            e.window.set_cursor (new Gdk.Cursor.from_name(Gdk.Display.get_default(), "hand2"));

            return true;
        }

        public override bool button_press_event (Gdk.EventButton e) {
            if (e.button != 1) {
                return true;
            }

            volume_popover.show_all ();

            return true;
        }

        public override void get_preferred_width (out int minimum_width, out int natural_width) {
            minimum_width = custom_width;
            natural_width = custom_width;
        }
    }
}
