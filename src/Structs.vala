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
        public string pretty_size;
        public uint64 size;
        public uint64 free;
        public uint64 offset;
    }

    public struct DriveSmart {
        public bool enabled;
        public uint64 updated;
        public bool failing;
        public uint64 power_seconds;
        public uint64 power_counts;
        public uint64 total_write;
        public string selftest_status;
        public string serial;
        public string revision;
        public uint life_left;
        public Gtk.ListStore smart_store;
    }
}
