namespace Monitor {
    public class Widgets.VolumeBox : Gtk.EventBox {
        public signal void show_ex_volume (string did, Structs.MonitorVolume v);

        public int custom_width {
            get;
            construct set;
        }

        public Structs.MonitorVolume volume {
            get;
            construct set;
        }

        public string drive_id {
            get;
            construct set;
        }

        public VolumeBox (int w, Structs.MonitorVolume v, string did) {
            Object (halign: Gtk.Align.FILL,
                    hexpand: true,
                    volume: v,
                    drive_id: did,
                    custom_width: w);
        }

        construct {
            add_events (Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.ENTER_NOTIFY_MASK);

            var vol_device = new Gtk.Label (volume.device ?? "Unallocated");
            vol_device.set_ellipsize (Pango.EllipsizeMode.END);

            var vol_size = new Gtk.Label (volume.pretty_size);
            vol_size.set_ellipsize (Pango.EllipsizeMode.END);

            var volume_head = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
            volume_head.add (vol_device);
            volume_head.add (vol_size);

            var volume_levelbar = new Gtk.LevelBar () {
                value = 0.0,
                hexpand = true,
            };
            volume_levelbar.add_offset_value (Gtk.LEVEL_BAR_OFFSET_LOW, 0.8);
            volume_levelbar.add_offset_value (Gtk.LEVEL_BAR_OFFSET_HIGH, 0.95);
            volume_levelbar.add_offset_value (Gtk.LEVEL_BAR_OFFSET_FULL, 1);

            unowned var levelbar_style_context = volume_levelbar.get_style_context ();
            levelbar_style_context.add_class (Gtk.STYLE_CLASS_FLAT);
            levelbar_style_context.add_class ("inverted");


            if (volume.mount_point != null && volume.free > 0) {
                volume_levelbar.set_value (1.0 - (float) volume.free / volume.size);
            }

            var wrap_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);

            wrap_box.add (volume_head);
            wrap_box.add (volume_levelbar);

            add (wrap_box);
        }

        public override bool button_press_event (Gdk.EventButton e)  {
            if (e.button == Gdk.BUTTON_PRIMARY) {
                show_ex_volume (drive_id, volume);
                return true;
            }

            return false;
        }

        public override bool enter_notify_event (Gdk.EventCrossing e)  {
            e.window.set_cursor (new Gdk.Cursor.from_name (Gdk.Display.get_default (), "hand2"));

            return true;
        }

        public override void get_preferred_width (out int minimum_width, out int natural_width) {
            minimum_width = 0;
            natural_width = custom_width;
        }
    }
}
