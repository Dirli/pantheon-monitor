namespace Monitor {
    public class Widgets.VolumesBox : Gtk.Box {
        public signal void changed_box_size (Gtk.Box widget, string did, Gtk.Allocation allocation);

        private int current_width = 0;

        public string device_id {
            get;
            construct set;
        }

        public VolumesBox (string did) {
            Object (orientation: Gtk.Orientation.HORIZONTAL,
                    hexpand: true,
                    spacing: 0,
                    device_id: did);

            get_style_context ().add_class ("volumes");

            size_allocate.connect ((allocation) => {
                if (current_width != allocation.width) {
                    current_width = allocation.width;
                    changed_box_size (this, device_id, allocation);
                }
            });
        }

        public override void get_preferred_height (out int minimum_height, out int natural_height) {
            minimum_height = 62;
            natural_height = 62;
        }
    }
}
