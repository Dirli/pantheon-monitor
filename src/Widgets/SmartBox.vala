namespace Monitor {
    public class Widgets.SmartBox : Gtk.Box {
        public signal void show_smart (string did);
        private int current_height = 0;

        public SmartBox (string device_id, uint left, bool fail) {
            Object (orientation: Gtk.Orientation.VERTICAL,
                    halign: Gtk.Align.FILL,
                    tooltip_text: "S.M.A.R.T.",
                    spacing: 0);

            size_allocate.connect ((allocation) => {
                if (current_height != allocation.height) {
                    current_height = allocation.height;

                    @foreach ((w) => {
                        w.destroy ();
                    });

                    var smart_area = new Tools.DrawSmart (allocation.height, left, fail);
                    // smart_area.button_press_event.connect ((e) => {
                    //     if (e.button == Gdk.BUTTON_PRIMARY) {
                    //         show_smart (device_id);
                    //
                    //         return true;
                    //     }
                    //
                    //     return false;
                    // });

                    add (smart_area);

                    show_all ();
                }
            });
        }

        public override void get_preferred_width (out int minimum_width, out int natural_width) {
            minimum_width = 62;
            natural_width = 62;
        }
    }
}
