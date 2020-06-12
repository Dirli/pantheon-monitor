namespace Monitor {
    public class Services.ProcessManager : GLib.Object {
        private GTop.Cpu? last_cpu;

        private uint64 memory_total;

        private Gee.Map<int, GTop.ProcTime?> pid_cpu_usage;
        private Gee.HashMap<int, Gtk.TreeIter?> process_cache;

        public Gtk.ListStore process_store;

        public ProcessManager () {
            process_store = new Gtk.ListStore (5, typeof (string), typeof (double), typeof (uint64), typeof (int), typeof (string));
            process_cache = new Gee.HashMap<int, Gtk.TreeIter?> ();
            pid_cpu_usage = new Gee.HashMap<int, GTop.ProcTime?> ();

            GTop.Memory memory;
            GTop.get_mem (out memory);

            memory_total = memory.total;
        }

        public void update_processes () {
            var current_list = get_process_list ();

            Gee.Set<int> ids_to_remove = new Gee.HashSet<int> ();
            ids_to_remove.add_all (process_cache.keys);
            ids_to_remove.remove_all (current_list);

            foreach (int id in ids_to_remove) {
                remove_by_id (id);
            }
        }

        public void remove_by_id (int pid) {
            if (process_cache.has_key (pid)) {
                Gtk.TreeIter iter;
                process_cache.unset (pid, out iter);
                process_store.remove (ref iter);
            }
        }

        private Gee.Set<int> get_process_list () {
            GTop.Cpu cpu;
            GTop.get_cpu (out cpu);
            if (last_cpu == null) {
                last_cpu = cpu;
            }

            GTop.ProcList proclist;
            int[] pids = GTop.get_proclist (out proclist, GTop.GLIBTOP_KERN_PROC_ALL, -1);

            double real_time_interval = ((double) cpu.total / cpu.frequency) - ((double) last_cpu.total / last_cpu.frequency);

            last_cpu = cpu;

            Gee.Set<int> list = new Gee.HashSet<int> ();

            for (int i = 0; i < proclist.number; i += 1) {
                int pid = pids[i];

                var cpu_usage = proc_cpu_usage (pid, real_time_interval);
                var mem_usage = proc_mem_usage (pid);

                if (!process_cache.has_key (pid)) {
                    GTop.ProcUid proc_uid;
                    GTop.get_proc_uid (out proc_uid, pid);

                    unowned Posix.Passwd passwd = Posix.getpwuid (proc_uid.uid);
                    string user_name = "";
                    if (passwd != null) {
                        user_name = passwd.pw_name;
                    }

                    GTop.ProcArgs proc_args;
                    var command_line = GTop.get_proc_args (out proc_args, pid, 1024);
                    if (command_line == null) {continue;}

                    command_line = command_line.strip ();

                    if (command_line.length == 0) {continue;}

                    Gtk.TreeIter iter;
                    process_store.insert_with_values (
                        out iter, -1,
                        Enums.Column.NAME, command_line,
                        Enums.Column.PID, pid,
                        Enums.Column.CPU, cpu_usage,
                        Enums.Column.MEMORY, mem_usage,
                        Enums.Column.USER, user_name,
                        -1);

                    process_cache[pid] = iter;
                } else {
                    process_store.@set (
                        process_cache[pid],
                        Enums.Column.CPU, cpu_usage,
                        Enums.Column.MEMORY, mem_usage,
                        -1);
                }

                list.add (pid);
            }

            return list;
        }

        private uint64 proc_mem_usage (int pid) {
            GTop.ProcMem proc_mem;
            GTop.get_proc_mem (out proc_mem, pid);

            Wnck.ResourceUsage resu = Wnck.ResourceUsage.pid_read (Gdk.Display.get_default(), pid);
            return proc_mem.resident - proc_mem.share - resu.total_bytes_estimate;
        }

        private double proc_cpu_usage (int pid, double real_time_interval) {
            GTop.ProcTime proc_time;
            GTop.get_proc_time (out proc_time, pid);
            GTop.ProcTime? last_proc_time = pid_cpu_usage.has_key (pid) ? pid_cpu_usage[pid] : proc_time;

            double cpu_time_spent = get_cpu_usage_time_from_proc_time (proc_time) - get_cpu_usage_time_from_proc_time (last_proc_time);

            pid_cpu_usage[pid] = proc_time;
            return real_time_interval != 0 ? (cpu_time_spent / real_time_interval * 100.0) : 0;
        }

        private double get_cpu_usage_time_from_proc_time (GTop.ProcTime proc_time) {
            return ((double) proc_time.utime + (double) proc_time.stime) / proc_time.frequency;
        }

        public void stop_process (int pid, Posix.Signal signal_type) {
            if (pid > 0) {
                Posix.kill (pid, signal_type);
            }
        }
    }
}
