namespace Monitor {
    public class Widgets.SmartBox : Gtk.Grid {
        public signal void show_smart (string did);

        private int current_height = 0;

        private Gtk.Box life_area_wrapper;

        public Structs.DriveSmart smart { get; construct set; }

        public SmartBox (string device_id, Structs.DriveSmart s) {
            Object (orientation: Gtk.Orientation.VERTICAL,
                    column_spacing: 8,
                    row_spacing: 8,
                    vexpand: true,
                    valign: Gtk.Align.FILL,
                    smart: s);
        }

        construct {
            var hours_label = new Gtk.Label (_("Total hours:"));
            hours_label.halign = Gtk.Align.END;
            var hours_val = new Gtk.Label (@"$(smart.power_seconds / 3600) h.");
            hours_val.halign = Gtk.Align.START;

            var counts_label = new Gtk.Label (_("Total power-on:"));
            counts_label.halign = Gtk.Align.END;
            var counts_val = new Gtk.Label (@"$(smart.power_counts)");
            counts_val.halign = Gtk.Align.START;

            var write_label = new Gtk.Label (_("Total write:"));
            write_label.halign = Gtk.Align.END;
            var write_val = new Gtk.Label (@"$(smart.total_write != 0 ? Utils.format_bytes (smart.total_write, true) : "--")");
            write_val.halign = Gtk.Align.START;

            life_area_wrapper = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            life_area_wrapper.vexpand = true;
            life_area_wrapper.valign = Gtk.Align.FILL;
            life_area_wrapper.size_allocate.connect (on_size_allocate);

            attach (hours_label, 0, 0);
            attach (hours_val, 1, 0);
            attach (counts_label, 0, 1);
            attach (counts_val, 1, 1);
            attach (write_label, 0, 2);
            attach (write_val, 1, 2);
            attach (life_area_wrapper, 0, 3, 2);
        }

        private void on_size_allocate (Gtk.Allocation area_alloc) {
            if (area_alloc.height > 0 && area_alloc.height != current_height) {
                current_height = area_alloc.height;
                life_area_wrapper.size_allocate.disconnect (on_size_allocate);

                GLib.Idle.add (() => {
                    var draw_smart = new Tools.DrawSmart (smart.life_left, smart.failing, area_alloc);

                    life_area_wrapper.add (draw_smart);
                    draw_smart.show ();

                    return false;
                });
            }
        }
    }
}
