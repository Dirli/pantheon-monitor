namespace Monitor.Structs {
    public struct DrawFields {
        public int top;
        public int bottom;
        public int left;
        public int right;
    }
    public struct NetLoadData {
        public uint64 bytes_in;
        public uint64 bytes_out;
        public int percent_in;
        public int percent_out;
        public uint64 total_in;
        public uint64 total_out;
    }

    public struct NetIface {
        public string name;
        public uint32 address;
        public uint32 subnet;
        public string hwaddress;
        public uint64 bytes_in;
        public uint64 bytes_out;
        public uint64 packets_in;
        public uint64 packets_out;
    }

    public struct MemoryData {
        public uint64 used_memory;
        public uint64? used_swap;
        public int percent_memory;
        public int percent_swap;
    }

    public struct MemoryTotal {
        public uint64 memory;
        public uint64? swap;
    }

    public struct DiskioData {
        public uint64 read;
        public uint64 write;
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
