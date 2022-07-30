/*
 * Copyright (c) 2020-2022 Dirli <litandrej85@gmail.com>
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

        private Widgets.Smart smart_widget;

        private Gtk.Popover popover;

        public Disks () {
            Object (orientation: Gtk.Orientation.VERTICAL,
                    spacing: 0);
        }

        construct {
            main_widget = new Gtk.Box (Gtk.Orientation.VERTICAL, 15);
            // main_widget.hexpand = true;

            popover = new Gtk.Popover (null);
            popover.closed.connect (() => {
                popover.@foreach ((w) => {
                    w.destroy ();
                });
            });

            disks_manager = new Services.DisksManager ();

            if (!disks_manager.init ()) {
                //
            } else {
                disks_manager.get_drives ().foreach (add_drive);
            }

            init_main_widget ();

            smart_widget = new Widgets.Smart ();
            smart_widget.show_main_page.connect (() => {
                widget_stack.set_visible_child_name ("main");
            });
            widget_stack.add_named (smart_widget, "smart");

            widget_stack.set_visible_child_name ("main");
        }

        private bool add_drive (owned Objects.DiskDrive? drive) {
            var device_widget = new Widgets.Device (drive);
            device_widget.changed_box_size.connect ((did, w) => {
                on_changed_box_size (device_widget, did, w);
            });
            device_widget.show_volumes.connect ((did) => {
                //
            });
            device_widget.show_smart_page.connect (() => {
                smart_widget.show_smart (drive);
                widget_stack.set_visible_child_name ("smart");
            });

            var wrap_box = get_wrap_box ();
            wrap_box.add (device_widget);

            main_widget.add (wrap_box);

            return true;
        }

        private void on_changed_box_size (Widgets.Device widget, string did, int w) {
            var drive = disks_manager.get_drive (did);
            if (drive == null) {
                return;
            }

            uint64 volume_offset = 0;
            int allocation_width = w;
            drive.get_volumes ().foreach ((volume) => {
                if (volume_offset != 0 && volume_offset < volume.offset) {
                    var free_size = volume.offset - volume_offset;
                    int free_part = (int) (w * ((float) free_size / drive.size));
                    allocation_width -= free_part;
                    free_part = allocation_width > 0 ? free_part : free_part + allocation_width;

                    Structs.MonitorVolume unalloc_space = {};
                    unalloc_space.size = free_size;
                    unalloc_space.pretty_size = disks_manager.size_to_display (free_size);

                    if (free_part > 1) {
                        widget.add_volume (new Widgets.VolumeBox (free_part, unalloc_space));
                    }
                }

                volume_offset = volume.offset + volume.size;
                int used_percent = 0;
                if (volume.mount_point != null) {
                    used_percent = 100 - (int) (100.0 * volume.free / volume.size);
                }

                int volume_part = (int) (w * ((float) volume.size / drive.size));
                allocation_width -= volume_part;
                volume_part = allocation_width > 0 ? volume_part : volume_part + allocation_width;

                if (volume_part > 1) {
                    widget.add_volume (new Widgets.VolumeBox (volume_part, volume));
                }

                if (allocation_width < 0) {
                    return false;
                }

                return true;
            });

            /* 20 MB or more */
            var free_end_size = drive.size - volume_offset;
            if (allocation_width > 0 && free_end_size > 20971520) {
                int free_end_part = (int) (w * ((float) free_end_size / drive.size));
                allocation_width -= free_end_part;
                free_end_part = allocation_width > 0 ? free_end_part : free_end_part + allocation_width;

                Structs.MonitorVolume unalloc_end_space = {};
                unalloc_end_space.size = free_end_size;
                unalloc_end_space.pretty_size = disks_manager.size_to_display (free_end_size);

                if (free_end_part > 1) {
                    widget.add_volume (new Widgets.VolumeBox (free_end_part, unalloc_end_space));
                }
            }

            GLib.Idle.add (() => {
                widget.show_all ();
                return false;
            });
        }

        // private void add_new_str (ref Gtk.Grid vol_widget, string label_str, string value_str, int str_top, int str_left = 0) {
        //     var iter_label = new Gtk.Label (label_str);
        //     iter_label.halign = Gtk.Align.END;
        //
        //     var iter_value = new Gtk.Label (value_str);
        //     iter_value.halign = Gtk.Align.START;
        //     iter_value.set_ellipsize (Pango.EllipsizeMode.END);
        //
        //     vol_widget.attach (iter_label, str_left++, str_top);
        //     vol_widget.attach (iter_value, str_left, str_top);
        // }
        //
        // private void open_popover (Gtk.Widget relative_w, Gtk.Widget grid) {
        //     popover.set_relative_to (relative_w);
        //     popover.add (grid);
        //     popover.show_all ();
        // }

        // private Gtk.Grid create_popover_vol (Structs.MonitorVolume relative_volume) {
        //     var top = 0;
        //
        //     Gtk.Grid vol_grid = new Gtk.Grid ();
        //     vol_grid.margin = 10;
        //     vol_grid.row_spacing = 10;
        //     vol_grid.column_spacing = 10;
        //     vol_grid.get_style_context ().add_class ("block");
        //
        //     add_new_str (ref vol_grid, _("Device:"), relative_volume.device, top++);
        //
        //     if (relative_volume.label != "") {
        //         add_new_str (ref vol_grid, _("Label:"), relative_volume.label, top++);
        //     }
        //
        //     add_new_str (ref vol_grid, "UUID:", relative_volume.uuid, top++);
        //     add_new_str (ref vol_grid, _("Filesystem:"), relative_volume.type, top++);
        //
        //     var cust_size = "";
        //     if (relative_volume.mount_point != null) {
        //         add_new_str (ref vol_grid, _("Mount point:"), relative_volume.mount_point, top++);
        //
        //         cust_size += disks_manager.size_to_display (relative_volume.free);
        //         cust_size += " / ";
        //     }
        //     cust_size += disks_manager.size_to_display (relative_volume.size);
        //
        //     add_new_str (ref vol_grid,
        //                  relative_volume.mount_point != null ? _("Size (free / total):") : _("Size:"),
        //                  cust_size,
        //                  top++);
        //
        //
        //     return vol_grid;
        // }

        // private Gtk.Grid create_popover_free (uint64 free_size, string relative_device) {
        //     var top = 0;
        //
        //     Gtk.Grid free_grid = new Gtk.Grid ();
        //     free_grid.margin = 10;
        //     free_grid.row_spacing = 10;
        //     free_grid.column_spacing = 10;
        //     free_grid.get_style_context ().add_class ("block");
        //
        //     add_new_str (ref free_grid, _("Device:"), relative_device, top++);
        //     add_new_str (ref free_grid, _("Size:"), disks_manager.size_to_display (free_size), top++);
        //     add_new_str (ref free_grid, _("Contents:"), _("Unallocated Space"), top++);
        //
        //     return free_grid;
        // }

        public override void stop_timer () {}
        public override void start_timer () {}
    }
}
