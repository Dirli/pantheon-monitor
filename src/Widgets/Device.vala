namespace Monitor {
    public class Widgets.Device : Gtk.Box {
        public signal void changed_box_size (string did, int new_width);
        public signal void show_volumes (string did);
        public signal void show_smart_page ();

        private Gtk.Box volumes_box;
        private int c_width = 0;

        public Objects.DiskDrive device {
            get;
            construct set;
        }

        public Device (Objects.DiskDrive d) {
            Object (orientation: Gtk.Orientation.VERTICAL,
                    spacing: 15,
                    margin: 12,
                    device: d);
        }

        construct {
            Gtk.Grid device_grid = new Gtk.Grid () {
                row_spacing = 8,
                column_spacing = 8,
                halign = Gtk.Align.FILL,
                expand = true
            };

            Gtk.Label drive_model_val = new Gtk.Label (device.model);
            drive_model_val.halign = Gtk.Align.START;
            drive_model_val.set_ellipsize (Pango.EllipsizeMode.END);
            var top = 0;
            device_grid.attach (drive_model_val, 0, top++, 3, 1);

            Gtk.Image d_icon = device.drive_icon != null
                               ? new Gtk.Image.from_gicon (device.drive_icon, Gtk.IconSize.DIALOG)
                               : new Gtk.Image.from_icon_name ("drive-harddisk", Gtk.IconSize.DIALOG);

            d_icon.halign = d_icon.valign = Gtk.Align.CENTER;
            device_grid.attach (d_icon, 0, top, 1, 4);

            add_str (device_grid, _("Device:"), device.device, top++, 1);
            add_str (device_grid, _("Partitioning:"), device.partition, top++, 1);
            add_str (device_grid, "ID:", device.id, top++, 1);
            add_str (device_grid, _("Size:"), device.pretty_size, top++, 1);

            var head_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
                vexpand = false
            };
            head_box.add (device_grid);

            if (device.has_smart) {
                var smart_grid = new Gtk.Grid () {
                    row_spacing = 8,
                    column_spacing = 8,
                    valign = Gtk.Align.CENTER,
                    halign = Gtk.Align.END
                };

                var smart_btn = new Gtk.Button.with_label ("S.M.A.R.T...");
                smart_btn.clicked.connect (() => {
                    show_smart_page ();
                });
                int s_top = 0;
                smart_grid.attach (smart_btn, 0, s_top++, 2);

                var d_smart = device.get_smart ();
                add_str (smart_grid, _("Total hours:"), @"$(d_smart.power_seconds / 3600) h.", s_top++);
                add_str (smart_grid, _("Total power-on:"), @"$(d_smart.power_counts)", s_top++);
                add_str (smart_grid, _("Total write:"), @"$(d_smart.total_write != 0 ? Utils.format_bytes (d_smart.total_write, true) : "--")", s_top++);

                if (d_smart.life_left > 0) {
                    var life_bar = new Gtk.ProgressBar () {
                        valign = Gtk.Align.CENTER,
                        hexpand = true,
                        margin_top = 12
                    };
                    life_bar.set_fraction (d_smart.life_left / 100.0);
                    life_bar.tooltip_text = @"$(d_smart.life_left)%";
                    smart_grid.attach (life_bar, 0, s_top++, 2);
                }


                head_box.add (smart_grid);
            }


            volumes_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                vexpand = false
            };
            volumes_box.size_allocate.connect ((allocation) => {
                if (allocation.width > 0 && c_width != allocation.width) {
                    c_width = allocation.width;
                    volumes_box.@foreach ((widget) => {
                        widget.destroy ();
                    });

                    changed_box_size (device.id, c_width);
                }
            });

            var wrap_box = new Gtk.EventBox ();
            wrap_box.add_events (Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.ENTER_NOTIFY_MASK);
            wrap_box.enter_notify_event.connect ((e) => {
                e.window.set_cursor (new Gdk.Cursor.from_name (Gdk.Display.get_default (), "hand2"));

                return true;
            });
            wrap_box.button_press_event.connect ((e) => {
                if (e.button == Gdk.BUTTON_PRIMARY) {
                    show_volumes (device.id);
                    return true;
                }

                return false;
            });
            wrap_box.add (volumes_box);

            add (head_box);
            add (wrap_box);
        }

        public void add_volume (Widgets.VolumeBox v) {
            volumes_box.add (v);
        }

        private void add_str (Gtk.Grid d_widget, string label_str, string value_str, int str_top, int str_left = 0) {
            var iter_label = new Gtk.Label (label_str);
            iter_label.halign = Gtk.Align.END;

            var iter_value = new Gtk.Label (value_str);
            iter_value.halign = Gtk.Align.START;
            iter_value.set_ellipsize (Pango.EllipsizeMode.END);

            d_widget.attach (iter_label, str_left++, str_top);
            d_widget.attach (iter_value, str_left, str_top);
        }
    }
}
