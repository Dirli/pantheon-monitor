namespace Monitor {
    public class Widgets.VolumeBox : Gtk.Box {
        public int custom_width {
            get;
            construct set;
        }

        public Structs.MonitorVolume volume {
            get;
            construct set;
        }

        private Gtk.ProgressBar progress_bar;

        public VolumeBox (int w, Structs.MonitorVolume v) {
            Object (halign: Gtk.Align.FILL,
                    orientation: Gtk.Orientation.VERTICAL,
                    hexpand: true,
                    spacing: 6,
                    volume: v,
                    custom_width: w);
        }

        construct {
            var vol_device = new Gtk.Label (volume.device ?? "Unallocated");
            vol_device.set_ellipsize (Pango.EllipsizeMode.END);

            var vol_size = new Gtk.Label (volume.pretty_size);
            vol_size.set_ellipsize (Pango.EllipsizeMode.END);

            var volume_head = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
            volume_head.add (vol_device);
            volume_head.add (vol_size);

            progress_bar = new Gtk.ProgressBar ();
            if (volume.mount_point != null && volume.free > 0) {
                progress_bar.set_fraction (1.0 - (float) volume.free / volume.size);
            }

            add (volume_head);
            add (progress_bar);
        }

        public override void get_preferred_width (out int minimum_width, out int natural_width) {
            minimum_width = 0;
            natural_width = custom_width;
        }
    }
}
