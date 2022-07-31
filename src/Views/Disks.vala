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

        public Disks () {
            Object (orientation: Gtk.Orientation.VERTICAL,
                    spacing: 0);
        }

        construct {
            main_widget = new Gtk.Box (Gtk.Orientation.VERTICAL, 15);

            disks_manager = new Services.DisksManager ();

            if (!disks_manager.init ()) {
                // gotta do something
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
            device_widget.show_smart_page.connect (() => {
                main_widget.@foreach ((w) => {
                    var device = (Widgets.Device) ((Gtk.Container) w).get_children ().nth_data (0);
                    device.clear_revealer ();
                });

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
                        var free_box = new Widgets.VolumeBox (free_part, unalloc_space, drive.id);
                        free_box.show_ex_volume.connect (on_show_ex_volume);
                        widget.add_volume (free_box);
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
                    var volume_box = new Widgets.VolumeBox (volume_part, volume, drive.id);
                    volume_box.show_ex_volume.connect (on_show_ex_volume);
                    widget.add_volume (volume_box);
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
                    var free_end_box = new Widgets.VolumeBox (free_end_part, unalloc_end_space, drive.id);
                    free_end_box.show_ex_volume.connect (on_show_ex_volume);
                    widget.add_volume (free_end_box);
                }
            }

            GLib.Idle.add (() => {
                widget.show_all ();
                return false;
            });
        }

        private void on_show_ex_volume (string did, Structs.MonitorVolume v) {
            main_widget.@foreach ((w) => {
                var device = (Widgets.Device) ((Gtk.Container) w).get_children ().nth_data (0);
                var need_show = device.clear_revealer (v.device);

                if (device.device.id == did && need_show) {
                    device.show_ex_volume (v);
                }

            });
        }

        public override void stop_timer () {
            main_widget.@foreach ((w) => {
                var device = (Widgets.Device) ((Gtk.Container) w).get_children ().nth_data (0);
                device.clear_revealer ();
            });

            smart_widget.clear_cache ();
            widget_stack.set_visible_child_name ("main");

        }
        public override void start_timer () {}
    }
}
