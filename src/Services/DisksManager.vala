namespace Monitor {
    public class Services.DisksManager : GLib.Object {
        private UDisks.Client? udisks_client;
        private GLib.List<GLib.DBusObject> obj_proxies;

        private Gee.HashMap<string, Structs.MonitorDrive?> drives_hash;
        private Gee.HashMap<string, Structs.MonitorVolume?> volumes_hash;
        private Gee.HashMap<string, Gee.HashSet<string>> drive_volumes;

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

            drives_hash = new Gee.HashMap<string, Structs.MonitorDrive?> ();
            volumes_hash = new Gee.HashMap<string, Structs.MonitorVolume?> ();
            drive_volumes = new Gee.HashMap<string, Gee.HashSet<string>> ();

            init_drives ();
            init_volumes ();

            return true;
        }

        private void init_drives () {
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
                            Structs.MonitorDrive current_drive = {};

                            current_drive.model = drive_dev.model;
                            current_drive.size = drive_dev.size;
                            current_drive.revision = drive_dev.revision;

                            if (drive_dev.id == "") {
                                current_drive.id = "";
                            } else {
                                var dev_id = drive_dev.id.split("-");
                                current_drive.id = dev_id[dev_id.length - 1];
                            }
                            current_drive.device = block_dev.device;
                            current_drive.partition = p_type_display != null ? p_type_display : "Unknown";

                            if (obj_icon != null) {
                                current_drive.drive_icon = obj_icon;
                            }

                            drives_hash[current_drive.id] = current_drive;

                            drive_volumes[current_drive.id] = new Gee.HashSet<string> ();
                        }
                    }
                }
            });
        }

        private void init_volumes () {
            obj_proxies.foreach ((iter) => {
                var udisks_obj = udisks_client.peek_object (iter.get_object_path ());

                var p_table = udisks_obj.get_partition_table ();
                if (p_table == null) {

                    var block_dev = udisks_obj.get_block ();
                    if (block_dev != null && block_dev.drive != "/") {
                        drives_hash.values.foreach ((d) => {
                            if (drive_volumes.has_key (d.id) && block_dev.device.contains (d.device)) {
                                drive_volumes[d.id].add (block_dev.id_uuid);
                            }

                            return true;
                        });

                        Structs.MonitorVolume current_volume = {};
                        current_volume.device = block_dev.device;
                        current_volume.label = block_dev.id_label;
                        current_volume.type = block_dev.id_type;
                        current_volume.size = block_dev.size;
                        current_volume.uuid = block_dev.id_uuid;
                        current_volume.offset = udisks_obj.get_partition ().offset;

                        var block_fs = udisks_obj.get_filesystem ();
                        if (block_fs != null && block_fs.mount_points[0] != null) {
                            current_volume.mount_point = block_fs.mount_points[0];
                            Posix.statvfs buf;
                            Posix.statvfs_exec (block_fs.mount_points[0], out buf);
                            current_volume.free = (uint64) buf.f_bfree * (uint64) buf.f_bsize;
                        // } else {
                        //     current_volume.mount_point = "";
                        }

                        volumes_hash[current_volume.uuid] = current_volume;
                    }
                }
            });
        }

        public Structs.MonitorDrive? get_drive (string did) {
            if (drives_hash.has_key (did)) {
                return drives_hash[did];
            }

            return null;
        }

        public Gee.ArrayList<Structs.MonitorDrive?> get_drives () {
            var drives_arr = new Gee.ArrayList<Structs.MonitorDrive?> ();
            drives_hash.values.foreach ((d) => {
                drives_arr.add (d);
                return true;
            });

            drives_arr.sort (compare_drives);

            return drives_arr;
        }

        public Gee.ArrayList<Structs.MonitorVolume?> get_drive_volumes (string dev_id) {
            var volumes_arr = new Gee.ArrayList<Structs.MonitorVolume?> ();

            if (drive_volumes.has_key (dev_id)) {
                drive_volumes[dev_id].foreach ((volume_id) => {
                    if (volumes_hash.has_key (volume_id)) {
                        volumes_arr.add (volumes_hash[volume_id]);
                    }

                    return true;
                });
            }

            volumes_arr.sort (compare_volumes);

            return volumes_arr;
        }

        public Gee.ArrayList<Structs.MonitorVolume?> get_mounted_volumes () {
            var volumes_list = new Gee.ArrayList<Structs.MonitorVolume?> ();

            volumes_hash.values.foreach ((vol) => {
                if (vol.mount_point != null) {
                    volumes_list.add (vol);
                }
                return true;
            });

            volumes_list.sort (compare_volumes);

            return volumes_list;
        }

        public string size_to_display (uint64 size_to_fmt) {
            return udisks_client.get_size_for_display (size_to_fmt, false, false);
        }

        private int compare_drives (Structs.MonitorDrive? drive1, Structs.MonitorDrive? drive2) {
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
