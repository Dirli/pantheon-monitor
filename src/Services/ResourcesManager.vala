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
    public class Services.ResourcesManager : GLib.Object {
        private uint64[] network_old_data;
        public int network_speed {
            get;
            private set;
        }

        public int quantity_cores {
            get;
            construct set;
        }

        private Structs.DiskioData sectors_last;

        private Structs.CpuLast cpu_last;
        private Structs.CpuLast[] cpus_last;

        private bool swap_on = false;
        public Structs.MemoryTotal memory_total;

        public ResourcesManager () {
            Object (quantity_cores: (int) get_num_processors ());
        }

        construct {
            network_speed = 0;

            network_old_data = {0, 0};
            update_network (false);

            init_memory ();

            cpu_last = Structs.CpuLast () {
                last_total = 0,
                last_used = 0
            };
            cpus_last = {};

            int i = 0;
            while (quantity_cores > i++) {
                cpus_last += Structs.CpuLast () {last_total = 0, last_used = 0};
            }

            sectors_last = Structs.DiskioData () {
                read = 0,
                write = 0
            };

            update_diskio ();
        }

        private void init_memory () {
            memory_total = {};

            GTop.Memory memory;
            GTop.get_mem (out memory);
            memory_total.memory = memory.total;

            GTop.Swap swap;
            GTop.get_swap (out swap);
            if (swap.total > 0) {
                swap_on = true;
                memory_total.swap = swap.total;
            }
        }

        public Structs.MemoryData update_memory (bool need_swap = true) {
            Structs.MemoryData memory_data = {};

            GTop.Memory memory;
            GTop.get_mem (out memory);
            memory_data.used_memory = memory.user;
            memory_data.percent_memory = (int) Math.round (((float) memory_data.used_memory / memory_total.memory) * 100);

            if (swap_on && need_swap) {
                GTop.Swap swap;
                GTop.get_swap (out swap);
                memory_data.used_swap = swap.used;
                memory_data.percent_swap = (int) Math.round (((float) memory_data.used_swap / memory_total.swap) * 100);
            }

            return memory_data;
        }

        public int update_cpu () {
            GTop.Cpu cpu;
            GTop.get_cpu (out cpu);

            var used = cpu.user + cpu.nice + cpu.sys;
            var pre_percentage = (used - cpu_last.last_used).abs () / (cpu.total - cpu_last.last_total).abs ();

            cpu_last.last_used = (float) used;
            cpu_last.last_total = (float) cpu.total;

            return (int) Math.round (pre_percentage * 100);
        }

        public int[] update_cpus () {
            int[] percents = {};
            GTop.Cpu cpu;
            GTop.get_cpu (out cpu);

            for (int core = 0; core < quantity_cores; core++) {
                var used = cpu.xcpu_user[core] + cpu.xcpu_nice[core] + cpu.xcpu_sys[core];
        		var difference_used = (float) used - cpus_last[core].last_used;
        		var difference_total = (float) cpu.xcpu_total[core] - cpus_last[core].last_total;
        		var pre_percentage = difference_used.abs () / difference_total.abs ();

                percents += (int) Math.round (pre_percentage * 100);

                cpus_last[core].last_used = (float) used;
                cpus_last[core].last_total = (float) cpu.xcpu_total[core];
            }

            return percents;
        }

        public double update_freq () {
            double max_freq = 0;

            for (uint i = 0; i < _quantity_cores; ++i) {
                string cur_value;
                try {
                    GLib.FileUtils.get_contents (@"/sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq", out cur_value);
                } catch (Error e) {
                    cur_value = "0";
                }

                var cur = double.parse (cur_value);
                max_freq = i == 0 ? cur : double.max (cur, max_freq);
            }

            return max_freq;
        }

        public Structs.DiskioData? update_diskio () {
            uint64 sectors_read = 0;
            uint64 sectors_write = 0;

            try {
                string content = null;
                GLib.FileUtils.get_contents ("/proc/diskstats", out content);

                foreach (var line in content.split ("\n")) {
                    if (line == "") {
                        break;
                    }

                    string[] fields = GLib.Regex.split_simple ("[ ]+", line);
                    if ((fields[1] == "8" | fields[1] == "252" | fields[1] == "259") &&
                        GLib.Regex.match_simple ("((sd|vd)[a-z]{1}|nvme[0-9]{1}n[0-9]{1})$", fields[3])) {

                        sectors_read += uint64.parse (fields[6]);
                        sectors_write += uint64.parse (fields[10]);
                    }
                }
            } catch (Error e) {
                return null;
            }

            Structs.DiskioData diskio_diff = {};
            diskio_diff.read = (sectors_read - sectors_last.read) * 512;
            diskio_diff.write = (sectors_write - sectors_last.write) * 512;

            sectors_last.read = sectors_read;
            sectors_last.write = sectors_write;

            return diskio_diff;
        }

        public Structs.NetLoadData update_network (bool check_max, bool need_percent = false) {
            GTop.NetList netlist;
            GTop.NetLoad netload;
            var devices = GTop.get_netlist (out netlist);

            uint64 new_total_in = 0;
            uint64 new_total_out = 0;

            Structs.NetLoadData net_data = {};

            for (uint j = 0; j < netlist.number; ++j) {
                var device = devices[j];
                if (device != "lo" && device.substring (0, 3) != "tun" && !device.has_prefix ("vir")) {
                    GTop.get_netload (out netload, device);
                    new_total_in += netload.bytes_in;
                    new_total_out += netload.bytes_out;
                }
            }

            net_data.total_in = new_total_in;
            net_data.total_out = new_total_out;

            uint64 bytes_out = (new_total_out - network_old_data[0]) / 1;
            uint64 bytes_in = (new_total_in - network_old_data[1]) / 1;

            if (need_percent) {
                var new_percents = update_network_percents (bytes_out, bytes_in);
                net_data.percent_out = new_percents[0];
                net_data.percent_in = new_percents[1];
            }

            network_old_data[0] = new_total_out;
            network_old_data[1] = new_total_in;

            if (check_max) {
                var tmp_val = uint64.max (bytes_out, bytes_in);
                tmp_val = (int) Math.round ((double) tmp_val / 1048576 + 0.5);
                if (tmp_val > network_speed) {
                    network_speed = (int) tmp_val;
                }
            }

            net_data.bytes_in = bytes_in;
            net_data.bytes_out = bytes_out;

            return net_data;
        }

        private int[] update_network_percents (uint64 bytes_out, uint64 bytes_in) {
            double bytes_speed = network_speed <= 0 ? 5 * 1048576.0 : network_speed * 1048576.0;

            int[] percents = {};
            percents += (int) Math.round ((bytes_out / bytes_speed) * 100);
            percents += (int) Math.round ((bytes_in / bytes_speed) * 100);

            return percents;
        }

        public Structs.NetIface[] update_ifaces () {
            Structs.NetIface[] ifaces = {};

            GTop.NetList netlist;
            GTop.NetLoad netload;
            var devices = GTop.get_netlist (out netlist);

            for (uint j = 0; j < netlist.number; ++j) {
                var device = devices[j];
                if (device != "lo" && device.substring (0, 3) != "tun" && !device.has_prefix ("vir")) {
                    Structs.NetIface iface = {};
                    iface.name = device;

                    GTop.get_netload (out netload, device);

                    iface.address = netload.address;

                    string mac_value;
                    try {
                        GLib.FileUtils.get_contents (@"/sys/class/net/$device/address", out mac_value);
                        iface.hwaddress = mac_value != null ? mac_value.strip () : "";
                    } catch (Error e) {
                        warning (e.message);
                    }

                    iface.bytes_in = netload.bytes_in;
                    iface.bytes_out = netload.bytes_out;

                    iface.packets_in = netload.packets_in;
                    iface.packets_out = netload.packets_out;

                    ifaces += iface;
                }
            }

            return ifaces;
        }

        public string update_uptime () {
            GTop.Uptime uptime;
            GTop.get_uptime (out uptime);

            var u_time = uptime.uptime;

            GLib.DateTime unix_uptime = new GLib.DateTime.from_unix_utc ((int) u_time);
            var _uptime = @"$((uint64) u_time / 86400):" + unix_uptime.format ("%H:%M:%S");

            return _uptime;
        }
    }
}
