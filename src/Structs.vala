namespace Monitor.Structs {
    public struct NetLoadData {
        public int bytes_in;
        public int bytes_out;
        public int percent_in;
        public int percent_out;
        public uint64 total_in;
        public uint64 total_out;
    }

    public struct MemoryData {
        public float used_memory;
        public float used_swap;
        public int percent_memory;
        public int percent_swap;
    }

    public struct MemoryTotal {
        public float memory;
        public float swap;
    }

    public struct CpuLast {
        public float last_used;
        public float last_total;
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
