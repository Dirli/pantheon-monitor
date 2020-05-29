namespace Monitor {
    public class Widgets.Disks: Gtk.Box {
        private Services.Disks disks_service;

        public Disks () {
            Object (orientation: Gtk.Orientation.VERTICAL,
                    spacing: 15);

            disks_service = new Services.Disks ();
            disks_service.get_drive_arr ().foreach ((drive) => {
                Gtk.Box drive_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 15);
                drive_box.get_style_context ().add_class ("block");
                drive_box.expand = false;

                var top = 0;
                Gtk.Grid drive_grid = new Gtk.Grid ();
                drive_grid.row_spacing = drive_grid.column_spacing = 8;

                Gtk.Image d_icon = drive.drive_icon != null
                                   ? new Gtk.Image.from_gicon (drive.drive_icon, Gtk.IconSize.DIALOG)
                                   : new Gtk.Image.from_icon_name ("drive-harddisk", Gtk.IconSize.DIALOG);

                d_icon.halign = d_icon.valign = Gtk.Align.CENTER;
                drive_grid.attach (d_icon, 0, top, 1, 3);

                Gtk.Label drive_model_val = new Gtk.Label (drive.model + " (" + drive.revision + ")");
                drive_model_val.halign = Gtk.Align.START;
                drive_model_val.set_ellipsize (Pango.EllipsizeMode.END);
                drive_grid.attach (drive_model_val, 1, top++, 2, 1);

                add_new_str (ref drive_grid, _("Partitioning:"), drive.partition, top++, 1);
                add_new_str (ref drive_grid, "ID:", drive.id, top++, 1);

                Gtk.Label drive_device_val = new Gtk.Label (drive.device);
                drive_device_val.halign = Gtk.Align.CENTER;
                drive_grid.attach (drive_device_val, 0, 3);

                add_new_str (ref drive_grid, _("Size:"), disks_service.size_to_display (drive.size), top++, 1);

                drive_box.add (drive_grid);

                var volumes_box = new Widgets.VolumesBox ();
                drive_box.add (volumes_box);

                var volumes_list = disks_service.get_drive_volumes (drive.device);
                uint64 volume_offset = 0;

                volumes_list.foreach ((volume) => {
                    if (volume_offset != 0 && volume_offset < volume.offset) {
                        var free_size = volume.offset - volume_offset;
                        var free_vol_width = 500.0 * free_size / drive.size;
                        var free_box = create_volume_iter ((int) free_vol_width,
                                                           create_popover_free ((uint64) free_size, drive.device),
                                                           disks_service.size_to_display (free_size));
                        volumes_box.add (free_box);
                    }

                    volume_offset = volume.offset + volume.size;
                    var vol_width = 500.0 * volume.size / drive.size;

                    int used_percent = 0;
                    if (volume.mount_point != null) {
                        used_percent = 100 - (int) (100.0 * volume.free / volume.size);
                    }

                    var volume_box = create_volume_iter ((int) vol_width,
                                                         create_popover_vol (volume),
                                                         disks_service.size_to_display (volume.size),
                                                         used_percent);

                    volumes_box.add (volume_box);

                    return true;
                });

                if (volumes_list.size > 0) {
                    var last_vol = volumes_list.last ();

                    /* 20 MB or more */
                    var free_end_size = drive.size - (last_vol.size + last_vol.offset);
                    if (free_end_size > 20971520) {
                        var end_vol_width = 500.0 * free_end_size / drive.size;
                        var drive_free_end = create_volume_iter ((int) end_vol_width,
                                                           create_popover_free ((uint64) free_end_size, drive.device),
                                                           disks_service.size_to_display (free_end_size));

                        volumes_box.add (drive_free_end);
                    }
                }

                add (drive_box);

                return true;
            });

            show_all ();
        }

        private void add_new_str (ref Gtk.Grid vol_widget, string label_str, string value_str, int str_top, int str_left = 0) {
            var iter_label = new Gtk.Label (label_str);
            iter_label.halign = Gtk.Align.END;

            var iter_value = new Gtk.Label (value_str);
            iter_value.halign = Gtk.Align.START;
            iter_value.set_ellipsize (Pango.EllipsizeMode.END);

            vol_widget.attach (iter_label, str_left++, str_top);
            vol_widget.attach (iter_value, str_left, str_top);
        }

        private Gtk.Widget create_popover_vol (Structs.MonitorVolume relative_volume) {
            var top = 0;
            Gtk.Grid vol_grid = new Gtk.Grid ();
            vol_grid.margin = 10;
            vol_grid.row_spacing = 10;
            vol_grid.column_spacing = 10;
            vol_grid.get_style_context ().add_class ("block");

            add_new_str (ref vol_grid, _("Device:"), relative_volume.device, top++);

            if (relative_volume.label != "") {
                add_new_str (ref vol_grid, _("Label:"), relative_volume.label, top++);
            }

            add_new_str (ref vol_grid, "UUID:", relative_volume.uuid, top++);
            add_new_str (ref vol_grid, _("Filesystem:"), relative_volume.type, top++);

            var cust_size = "";
            if (relative_volume.mount_point != null) {
                add_new_str (ref vol_grid, _("Mount point:"), relative_volume.mount_point, top++);

                cust_size += disks_service.size_to_display (relative_volume.free);
                cust_size += " / ";
            }
            cust_size += disks_service.size_to_display (relative_volume.size);

            add_new_str (ref vol_grid,
                         relative_volume.mount_point != null ? _("Size (free / total):") : _("Size:"),
                         cust_size,
                         top++);

            return vol_grid;
        }

        private Gtk.Widget create_popover_free (uint64 free_size, string relative_device) {
            var top = 0;
            Gtk.Grid free_grid = new Gtk.Grid ();
            free_grid.margin = 10;
            free_grid.row_spacing = 10;
            free_grid.column_spacing = 10;
            free_grid.get_style_context ().add_class ("block");

            add_new_str (ref free_grid, _("Device:"), relative_device, top++);
            add_new_str (ref free_grid, _("Size:"), disks_service.size_to_display (free_size), top++);
            add_new_str (ref free_grid, _("Contents:"), _("Unallocated Space"), top++);

            return free_grid;
        }

        private Gtk.Widget create_volume_iter (int widget_width, Gtk.Widget popover_grid, string vol_size, int used_percent = 0) {
            var vol_iter_box = new Widgets.VolumeIter (widget_width, popover_grid, vol_size, used_percent);
            return vol_iter_box;
        }
    }
}
