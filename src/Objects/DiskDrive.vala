namespace Monitor {
    public class Objects.DiskDrive : GLib.Object {
        public string model;
        public uint64 size;
        public string revision;
        public string id;
        public string device;
        public string partition;
        public GLib.Icon drive_icon;

        private Gee.ArrayList<Structs.MonitorVolume?> volumes;

        private Structs.DriveSmart? smart = null;
        public bool has_smart {
            get {
                return smart != null;
            }
        }

        public DiskDrive () {
            volumes = new Gee.ArrayList <Structs.MonitorVolume?> ();
        }

        public Structs.DriveSmart? get_smart () {
            return smart;
        }

        public void add_smart (Structs.DriveSmart s) {
            smart = s;
        }

        public void add_volume (Structs.MonitorVolume vol) {
            volumes.add (vol);
        }

        public Gee.ArrayList<Structs.MonitorVolume?> get_volumes () {
            var volumes_arr = new Gee.ArrayList<Structs.MonitorVolume?> ();

            volumes.foreach ((vol) => {

                volumes_arr.add (vol);

                return true;
            });

            volumes_arr.sort (compare_volumes);

            return volumes_arr;
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
