namespace Monitor {
    public class Widgets.VolumesBox : Gtk.Box {
        public VolumesBox () {
            Object (orientation: Gtk.Orientation.HORIZONTAL,
                    halign: Gtk.Align.CENTER,
                    spacing: 0);

            get_style_context ().add_class ("volumes");
        }

        public override void get_preferred_width (out int minimum_width, out int natural_width) {
            minimum_width = 500;
            natural_width = 500;
        }

        public override void get_preferred_height (out int minimum_height, out int natural_height) {
            minimum_height = 60;
            natural_height = 60;
        }
    }
}
