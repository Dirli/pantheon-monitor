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
    public class Services.DisksManager : GLib.Object {
        private UDisks.Client? udisks_client;
        private GLib.List<GLib.DBusObject> obj_proxies;

        private Gee.HashMap<string, Objects.DiskDrive?> drives_hash;

        public DisksManager () {
            try {
                udisks_client = new UDisks.Client.sync ();
                var dbus_obj_manager = udisks_client.get_object_manager ();
                obj_proxies = dbus_obj_manager.get_objects ();
            } catch (Error e) {
                warning (e.message);
                udisks_client = null;
            }
        }

        public bool init () {
            if (udisks_client == null) {
                return false;
            }

            drives_hash = new Gee.HashMap<string, Objects.DiskDrive?> ();

            init_drives ();
            init_volumes ();

            return true;
        }

        private void init_drives () {
            obj_proxies.foreach ((iter) => {
                var udisks_obj = udisks_client.peek_object (iter.get_object_path ());
                if (udisks_obj != null) {
                    var p_table = udisks_obj.get_partition_table ();
                    if (p_table != null) {
                        var p_type_display = udisks_client.get_partition_table_type_for_display (p_table.type);

                        var block_dev = udisks_obj.get_block ();
                        if (block_dev != null) {
                            var obj_icon = udisks_client.get_object_info (udisks_obj).get_icon ();

                            var drive_dev = udisks_client.get_drive_for_block (block_dev);
                            if (drive_dev != null) {
                                var current_drive = new Objects.DiskDrive ();

                                current_drive.model = drive_dev.model;
                                current_drive.size = drive_dev.size;
                                current_drive.pretty_size = size_to_display (drive_dev.size);
                                current_drive.revision = drive_dev.revision;
                                current_drive.serial = drive_dev.serial;

                                current_drive.id = get_pretty_id (drive_dev.id);

                                current_drive.device = block_dev.device;
                                current_drive.partition = p_type_display != null ? p_type_display : "Unknown";

                                if (obj_icon != null) {
                                    current_drive.drive_icon = obj_icon;
                                }

                                drives_hash[current_drive.id] = current_drive;
                            }
                        }
                    }
                }
            });
        }

        private void init_volumes () {
            obj_proxies.foreach ((iter) => {
                var udisks_obj = udisks_client.peek_object (iter.get_object_path ());

                var ata = udisks_obj.get_drive_ata ();
                if (ata != null) {
                    get_smart (udisks_obj, ata);
                }

                var p_table = udisks_obj.get_partition_table ();
                if (p_table == null) {

                    var block_dev = udisks_obj.get_block ();
                    if (block_dev != null && block_dev.drive != "/") {
                        Structs.MonitorVolume current_volume = {};
                        current_volume.device = block_dev.device;
                        current_volume.label = block_dev.id_label;
                        current_volume.type = block_dev.id_type;
                        current_volume.size = block_dev.size;
                        current_volume.pretty_size = size_to_display (block_dev.size);
                        current_volume.uuid = block_dev.id_uuid;
                        var partition = udisks_obj.get_partition ();
                        if (partition != null) {
                            current_volume.offset = partition.offset;
                        }

                        var block_fs = udisks_obj.get_filesystem ();
                        if (block_fs != null && block_fs.mount_points[0] != null) {
                            current_volume.mount_point = block_fs.mount_points[0];
                            Posix.statvfs buf;
                            Posix.statvfs_exec (block_fs.mount_points[0], out buf);
                            current_volume.free = (uint64) buf.f_bfree * (uint64) buf.f_bsize;
                        // } else {
                        //     current_volume.mount_point = "";
                        }

                        var d = udisks_client.get_drive_for_block (block_dev);
                        if (d != null) {
                            var did = get_pretty_id (d.id);
                            if (drives_hash.has_key (did) && block_dev.device.contains (drives_hash[did].device)) {
                                drives_hash[did].add_volume (current_volume);
                            }
                        }
                    }
                }
            });
        }

        private string get_pretty_id (string id) {
            var did = "";
            if (id != "") {
                var id_arr = id.split("-");
                did = id_arr[id_arr.length - 1];
            }

            return did;
        }

        public void get_smart (UDisks.Object obj, UDisks.DriveAta ata) {
            if (ata.smart_supported) {
                var d = obj.get_drive ();

                if (d == null) {
                    return;
                }

                var did = get_pretty_id (d.id);
                if (!drives_hash.has_key (did)) {
                    return;
                }

                Structs.DriveSmart d_smart = {};

                d_smart.enabled = ata.smart_enabled;
                d_smart.updated = ata.smart_updated;
                d_smart.failing = ata.smart_failing;
                d_smart.power_seconds = ata.smart_power_on_seconds;
                d_smart.selftest_status = ata.smart_selftest_status;

                try {
                    GLib.Variant var_p = null;
                    if (ata.call_smart_get_attributes_sync (new GLib.Variant ("a{sv}"), out var_p)) {
                        GLib.VariantIter v_iter = var_p.iterator ();
                        uchar id;
                        int current, worst, threshold, pretty_unit;
                        string name;
                        uint16 flags;
                        uint64 pretty;
                        GLib.Variant expansion;

                        var list_store = new Gtk.ListStore (6,
                                                            typeof (uchar),
                                                            typeof (string),
                                                            typeof (int),
                                                            typeof (int),
                                                            typeof (int),
                                                            typeof (uint64));

                        while (v_iter.next ("(ysqiiixi@a{sv})",
                                            out id,
                                            out name,
                                            out flags,
                                            out current,
                                            out worst,
                                            out threshold,
                                            out pretty,
                                            out pretty_unit,
                                            out expansion)) {

                            if (id == 231) {
                                d_smart.life_left = (uint) Utils.parse_pretty (pretty, pretty_unit);
                            } else if (id == 12) {
                                d_smart.power_counts = pretty;
                            } else if (id == 241) {
                                d_smart.total_write = Utils.parse_pretty (pretty, pretty_unit);
                            }

                            Gtk.TreeIter iter;
                            list_store.append (out iter);
                            list_store.@set (iter,
                                             0, id,
                                             1, name,
                                             2, current,
                                             3, worst,
                                             4, threshold,
                                             5, pretty, -1);
                        }

                        d_smart.smart_store = list_store;

                        drives_hash[did].add_smart (d_smart, list_store);
                    }
                } catch (Error e) {
                    warning (e.message);
                }
            }
        }

        public Objects.DiskDrive? get_drive (string did) {
            if (drives_hash.has_key (did)) {
                return drives_hash[did];
            }

            return null;
        }

        public Gee.ArrayList<Objects.DiskDrive?> get_drives () {
            var drives_arr = new Gee.ArrayList<Objects.DiskDrive?> ();
            drives_hash.values.foreach ((d) => {
                drives_arr.add (d);
                return true;
            });

            drives_arr.sort (compare_drives);

            return drives_arr;
        }

        public Gee.ArrayList<Structs.MonitorVolume?> get_drive_volumes (string dev_id) {
            var volumes_arr = new Gee.ArrayList<Structs.MonitorVolume?> ();

            if (drives_hash.has_key (dev_id)) {
                drives_hash[dev_id].get_volumes ().foreach ((vol) => {
                    volumes_arr.add (vol);

                    return true;
                });
            }

            volumes_arr.sort (compare_volumes);

            return volumes_arr;
        }

        public Gee.ArrayList<Structs.MonitorVolume?> get_mounted_volumes () {
            var volumes_list = new Gee.ArrayList<Structs.MonitorVolume?> ();

            if (udisks_client != null) {
                obj_proxies.foreach ((iter) => {
                    var udisks_obj = udisks_client.peek_object (iter.get_object_path ());

                    var p_table = udisks_obj.get_partition_table ();
                    if (p_table == null) {

                        var block_dev = udisks_obj.get_block ();
                        if (block_dev != null && block_dev.drive != "/") {
                            var block_fs = udisks_obj.get_filesystem ();
                            if (block_fs != null && block_fs.mount_points[0] != null) {
                                Structs.MonitorVolume current_volume = {};
                                current_volume.device = block_dev.device;
                                current_volume.label = block_dev.id_label;
                                current_volume.type = block_dev.id_type;
                                current_volume.size = block_dev.size;
                                current_volume.uuid = block_dev.id_uuid;

                                var partition = udisks_obj.get_partition ();
                                if (partition != null) {
                                    current_volume.offset = partition.offset;
                                }

                                current_volume.mount_point = block_fs.mount_points[0];
                                Posix.statvfs buf;
                                Posix.statvfs_exec (block_fs.mount_points[0], out buf);
                                current_volume.free = (uint64) buf.f_bfree * (uint64) buf.f_bsize;

                                volumes_list.add (current_volume);
                            // } else {
                            //     current_volume.mount_point = "";
                            }
                        }
                    }
                });

                volumes_list.sort (compare_volumes);
            }

            return volumes_list;
        }

        public string size_to_display (uint64 size_to_fmt) {
            return udisks_client.get_size_for_display (size_to_fmt, false, false);
        }

        private int compare_drives (Objects.DiskDrive? drive1, Objects.DiskDrive? drive2) {
            if (drive1 == null) {
                return (drive2 == null) ? 0 : -1;
            }

            if (drive2 == null) {
                return 1;
            }

            return GLib.strcmp (drive1.device, drive2.device);
        }

        private int compare_volumes (Structs.MonitorVolume? vol1, Structs.MonitorVolume? vol2) {
            if (vol1 == null) {
                return (vol2 == null) ? 0 : -1;
            }

            if (vol2 == null) {
                return 1;
            }

            return GLib.strcmp (vol1.device, vol2.device);
        }
    }
}
