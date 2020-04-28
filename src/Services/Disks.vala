/*
 * Copyright (c) 2019 Dirli <litandrej85@gmail.com>
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
    public class Services.Disks : GLib.Object {
        private UDisks.Client? udisks_client;
        private GLib.List<GLib.DBusObject> obj_proxies;

        public Disks () {
            try {
                udisks_client = new UDisks.Client.sync ();
                var dbus_obj_manager = udisks_client.get_object_manager ();
                obj_proxies = dbus_obj_manager.get_objects ();
            } catch (Error e) {
                warning (e.message);
                udisks_client = null;
            }
        }

        public Gee.ArrayList<MonitorDrive?> get_drive_arr () {
            Gee.ArrayList<MonitorDrive?> drives_arr = new Gee.ArrayList<MonitorDrive?> ();
            if (udisks_client != null) {
                obj_proxies.foreach ((iter) => {
                    var udisks_obj = udisks_client.peek_object (iter.get_object_path ());

                    var p_table = udisks_obj.get_partition_table ();
                    if (p_table != null) {
                        var p_type_display = udisks_client.get_partition_table_type_for_display (p_table.type);

                        var block_dev = udisks_obj.get_block ();
                        if (block_dev != null) {
                            var obj_icon = udisks_client.get_object_info (udisks_obj).get_icon ();

                            var drive_dev = udisks_client.get_drive_for_block (block_dev);
                            if (drive_dev != null) {
                                MonitorDrive current_drive = {};

                                current_drive.model = drive_dev.model;
                                current_drive.size = drive_dev.size;
                                current_drive.revision = drive_dev.revision;

                                var dev_id = drive_dev.id.split("-");
                                current_drive.id = dev_id[dev_id.length - 1];
                                current_drive.device = block_dev.device;
                                current_drive.partition = p_type_display != null ? p_type_display : "Unknown";

                                if (obj_icon != null) {
                                    current_drive.drive_icon = obj_icon;
                                }

                                drives_arr.add (current_drive);
                            }
                        }
                    }
                });

                drives_arr.sort (compare_drives);
            }

            return drives_arr;
        }

        public string size_to_display (uint64 size_to_fmt) {
            return udisks_client.get_size_for_display (size_to_fmt, false, false);
        }

        private int compare_drives (MonitorDrive? drive1, MonitorDrive? drive2) {
            if (drive1 == null) {
                return (drive2 == null) ? 0 : -1;
            }

            if (drive2 == null) {
                return 1;
            }

            return GLib.strcmp (drive1.device, drive2.device);
        }

        private int compare_volumes (MonitorVolume? vol1, MonitorVolume? vol2) {
            if (vol1 == null) {
                return (vol2 == null) ? 0 : -1;
            }

            if (vol2 == null) {
                return 1;
            }

            return GLib.strcmp (vol1.device, vol2.device);
        }

        public Gee.ArrayList<MonitorVolume?> get_mounted_volumes () {
            Gee.ArrayList<MonitorVolume?> volumes_list = new Gee.ArrayList<MonitorVolume?> ();

            if (udisks_client != null) {
                obj_proxies.foreach ((iter) => {
                    var udisks_obj = udisks_client.peek_object (iter.get_object_path ());

                    var block_dev = udisks_obj.get_block ();
                    var block_fs = udisks_obj.get_filesystem ();
                    if (block_dev != null && block_dev.drive != "/" && block_fs != null && block_fs.mount_points[0] != null) {
                        MonitorVolume current_volume = {};

                        current_volume.device = block_dev.device;
                        current_volume.label = block_dev.id_label;
                        current_volume.size = block_dev.size;

                        Posix.statvfs buf;
                        Posix.statvfs_exec (block_fs.mount_points[0], out buf);
                        current_volume.free = (uint64) buf.f_bfree * (uint64) buf.f_bsize;

                        volumes_list.add (current_volume);
                    }
                });

                volumes_list.sort (compare_volumes);
            }

            return volumes_list;
        }

        public Gee.ArrayList<MonitorVolume?> get_drive_volumes (string dev_name) {
            Gee.ArrayList<MonitorVolume?> volumes_list = new Gee.ArrayList<MonitorVolume?> ();

            if (udisks_client != null) {
                obj_proxies.foreach ((iter) => {
                    var udisks_obj = udisks_client.peek_object (iter.get_object_path ());

                    var p_table = udisks_obj.get_partition_table ();
                    if (p_table == null) {

                        var block_dev = udisks_obj.get_block ();
                        if (block_dev != null && block_dev.drive != "/" && block_dev.device.contains (dev_name)) {
                            MonitorVolume current_volume = {};

                            var part_obj = udisks_obj.get_partition ();

                            current_volume.device = block_dev.device;
                            current_volume.label = block_dev.id_label;
                            current_volume.type = block_dev.id_type;
                            current_volume.size = block_dev.size;
                            current_volume.uuid = block_dev.id_uuid;
                            current_volume.offset = part_obj.offset;

                            var block_fs = udisks_obj.get_filesystem ();
                            if (block_fs != null && block_fs.mount_points[0] != null) {
                                current_volume.mount_point = block_fs.mount_points[0];
                                Posix.statvfs buf;
                                Posix.statvfs_exec (block_fs.mount_points[0], out buf);
                                current_volume.free = (uint64) buf.f_bfree * (uint64) buf.f_bsize;
                            }
                            volumes_list.add (current_volume);
                        }
                    }
                });

                volumes_list.sort (compare_volumes);
            }

            return volumes_list;
        }
    }

    public struct MonitorVolume {
        public string device;
        public string label;
        public string type;
        public string uuid;
        public string mount_point;
        public uint64 size;
        public uint64 free;
        public uint64 offset;
    }

    public struct MonitorDrive {
        public string model;
        public uint64 size;
        public string revision;
        public string id;
        public string device;
        public string partition;
        public GLib.Icon drive_icon;
    }
}
