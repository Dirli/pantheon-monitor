/*
 * Copyright (c) 2020 Dirli <litandrej85@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

namespace Monitor {
    public class Views.Disks : Views.ViewWrapper {
        private Services.DisksManager disks_manager;

        private Gtk.Box inner_widget;

        public Disks () {
            Object (orientation: Gtk.Orientation.VERTICAL,
                    spacing: 0);
        }

        construct {
            inner_widget = new Gtk.Box (Gtk.Orientation.VERTICAL, 15);
            inner_widget.hexpand = true;

            disks_manager = new Services.DisksManager ();

            if (!disks_manager.init ()) {
                //
            } else {
                disks_manager.get_drives ().foreach (add_drive);
            }

            main_widget.add (inner_widget);
        }

        private bool add_drive (owned Objects.DiskDrive? drive) {
            Gtk.Box drive_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 15);
            drive_box.get_style_context ().add_class ("block");
            drive_box.expand = false;

            Gtk.Grid drive_grid = new Gtk.Grid ();
            drive_grid.row_spacing = drive_grid.column_spacing = 8;
            drive_grid.halign = Gtk.Align.FILL;
            drive_grid.expand = true;

            Gtk.Image d_icon = drive.drive_icon != null
                               ? new Gtk.Image.from_gicon (drive.drive_icon, Gtk.IconSize.DIALOG)
                               : new Gtk.Image.from_icon_name ("drive-harddisk", Gtk.IconSize.DIALOG);

            d_icon.halign = d_icon.valign = Gtk.Align.CENTER;
            drive_grid.attach (d_icon, 0, 0, 1, 3);

            var top = 0;
            Gtk.Label drive_model_val = new Gtk.Label (drive.model + " (" + drive.revision + ")");
            drive_model_val.set_ellipsize (Pango.EllipsizeMode.END);
            drive_grid.attach (drive_model_val, 1, top++, 2, 1);

            add_new_str (ref drive_grid, _("Partitioning:"), drive.partition, top++, 1);
            add_new_str (ref drive_grid, "ID:", drive.id, top++, 1);
            add_new_str (ref drive_grid, _("Size:"), disks_manager.size_to_display (drive.size), top++, 1);

            Gtk.Label drive_device_val = new Gtk.Label (drive.device);
            drive_device_val.halign = Gtk.Align.CENTER;
            drive_grid.attach (drive_device_val, 0, 3);

            var info_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
            info_box.add (drive_grid);

            if (drive.has_smart) {
                var d_smart = drive.get_smart ();
                var smart_box = new Widgets.SmartBox (drive.id, d_smart.life_left, d_smart.failing);
                // smart_box.show_smart.connect ((did) => {
                //
                // });

                info_box.add (smart_box);
            }

            drive_box.add (info_box);

            var volumes_box = new Widgets.VolumesBox (drive.id);
            volumes_box.changed_box_size.connect (on_changed_box_size);
            drive_box.add (volumes_box);

            inner_widget.add (drive_box);

            return true;
        }

        private void on_changed_box_size (Gtk.Box widget, string did, Gtk.Allocation alloc) {
            widget.@foreach ((w) => {
                w.destroy ();
            });

            var drive = disks_manager.get_drive (did);
            if (drive == null) {
                return;
            }

            uint64 volume_offset = 0;
            int allocation_width = alloc.width;
            drive.get_volumes ().foreach ((volume) => {
                if (volume_offset != 0 && volume_offset < volume.offset) {
                    var free_size = volume.offset - volume_offset;
                    int free_part = (int) (alloc.width * ((float) free_size / drive.size));
                    allocation_width -= free_part;
                    free_part = allocation_width > 0 ? free_part : free_part + allocation_width;

                    var free_box = new Tools.DrawVolume (free_part, disks_manager.size_to_display (free_size));
                    free_box .button_press_event.connect ((e) => {
                        if (e.button == Gdk.BUTTON_PRIMARY) {
                             create_popover_free (free_box, (uint64) free_size, drive.device);
                             return true;
                        }

                        return false;
                    });

                    widget.add (free_box);
                }

                volume_offset = volume.offset + volume.size;

                int used_percent = 0;
                if (volume.mount_point != null) {
                    used_percent = 100 - (int) (100.0 * volume.free / volume.size);
                }

                int volume_part = (int) (alloc.width * ((float) volume.size / drive.size));
                allocation_width -= volume_part;
                volume_part = allocation_width > 0 ? volume_part : volume_part + allocation_width;

                var volume_box = new Tools.DrawVolume (volume_part,
                                                       disks_manager.size_to_display (volume.size),
                                                       used_percent);

                volume_box.button_press_event.connect ((e) => {
                    if (e.button == Gdk.BUTTON_PRIMARY) {
                        create_popover_vol (volume_box, volume);
                        return true;
                    }

                    return false;
                });

                widget.add (volume_box);

                if (allocation_width < 0) {
                    return false;
                }

                return true;
            });

            /* 20 MB or more */
            var free_end_size = drive.size - volume_offset;
            if (allocation_width > 0 && free_end_size > 20971520) {
                int free_end_part = (int) (alloc.width * ((float) free_end_size / drive.size));
                allocation_width -= free_end_part;
                free_end_part = allocation_width > 0 ? free_end_part : free_end_part + allocation_width;

                var drive_free_end = new Tools.DrawVolume (free_end_part, disks_manager.size_to_display (free_end_size));
                drive_free_end.button_press_event.connect ((e) => {
                    if (e.button == Gdk.BUTTON_PRIMARY) {
                        create_popover_free (drive_free_end, (uint64) free_end_size, drive.device);
                        return true;
                    }

                    return false;
                });

                widget.add (drive_free_end);
            }

            widget.show_all ();
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

        private void create_popover_vol (Gtk.Widget w, Structs.MonitorVolume relative_volume) {
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

                cust_size += disks_manager.size_to_display (relative_volume.free);
                cust_size += " / ";
            }
            cust_size += disks_manager.size_to_display (relative_volume.size);

            add_new_str (ref vol_grid,
                         relative_volume.mount_point != null ? _("Size (free / total):") : _("Size:"),
                         cust_size,
                         top++);

            var volume_popover = new Gtk.Popover (w);
            volume_popover.add (vol_grid);
            volume_popover.show_all ();
        }

        private void create_popover_free (Gtk.Widget w, uint64 free_size, string relative_device) {
            var top = 0;
            Gtk.Grid free_grid = new Gtk.Grid ();
            free_grid.margin = 10;
            free_grid.row_spacing = 10;
            free_grid.column_spacing = 10;
            free_grid.get_style_context ().add_class ("block");

            add_new_str (ref free_grid, _("Device:"), relative_device, top++);
            add_new_str (ref free_grid, _("Size:"), disks_manager.size_to_display (free_size), top++);
            add_new_str (ref free_grid, _("Contents:"), _("Unallocated Space"), top++);

            var free_popover = new Gtk.Popover (w);
            free_popover.add (free_grid);
            free_popover.show_all ();
        }

        public override void stop_timer () {}
        public override void start_timer () {}
    }
}
