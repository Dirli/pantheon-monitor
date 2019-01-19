/*
 * Copyright (c) 2018 Dirli <litandrej85@gmail.com>
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
    public class Widgets.Monitoring: Gtk.Grid {
        private Widgets.Cpu widget_cpu;
        private Widgets.Memory widget_memory;
        private Widgets.Network widget_down;
        private Widgets.Network widget_up;
        private Services.CPU cpu_serv;
        private Services.Memory memory_serv;
        private Services.Swap swap_serv;
        private Services.Net net_serv;
        /* private Gtk.Label total_net_val; */
        private Gtk.Label uptime_val;
        private Gtk.Label swap_val;

        public Monitoring (Granite.Widgets.ModeButton mode_box) {
            widget_cpu.cores = cpu_serv.quantity_cores;
            update (mode_box);
        }

        construct {
            cpu_serv = new Services.CPU ();
            memory_serv = new Services.Memory ();
            swap_serv = new Services.Swap ();
            net_serv = new Services.Net ();
            widget_cpu = new Widgets.Cpu ();
            widget_memory = new Widgets.Memory (_("Memory"));
            widget_down = new Widgets.Network (_("Download"));
            widget_up = new Widgets.Network (_("Upload"));

            row_spacing = 10;
            margin = 15;
            expand = true;
            widget_cpu.halign = Gtk.Align.CENTER;
            widget_cpu.hexpand = true;

            widget_memory.halign = Gtk.Align.CENTER;
            widget_memory.hexpand = true;

            Gtk.Label common_label = new Gtk.Label (_("Common"));
            common_label.margin_bottom = 15;
            common_label.get_style_context ().add_class ("section");
            Gtk.Label net_label = new Gtk.Label (_("Network"));
            net_label.get_style_context ().add_class ("section");

            Gtk.Grid common_grid = new Gtk.Grid ();

            Gtk.Label uptime_label = new Gtk.Label (_("Uptime") + ": ");
            uptime_val = new Gtk.Label ("-");

            Gtk.Label swap_label = new Gtk.Label (_("Swap") + ": ");
            swap_val = new Gtk.Label ("-");

            uptime_label.halign = swap_label.halign = Gtk.Align.START;
            uptime_val.halign = swap_val.halign = Gtk.Align.START;

            common_grid.attach (swap_label, 0, 0, 1, 1);
            common_grid.attach (swap_val, 1, 0, 1, 1);
            common_grid.attach (uptime_label, 0, 1, 1, 1);
            common_grid.attach (uptime_val, 1, 1, 1, 1);

            attach (widget_cpu, 0, 0, 1, 1);
            attach (widget_memory, 1, 0, 1, 1);
            attach (net_label, 0, 1, 2, 1);
            attach (widget_down, 0, 2, 1, 1);
            attach (widget_up, 1, 2, 1, 1);
            attach (common_label, 0, 3, 2, 1);
            attach (common_grid, 0, 4, 2, 1);

            border_width = 0;
            show_all ();
        }

        private void update (Granite.Widgets.ModeButton mode_box) {
    	    Timeout.add_seconds (1, () => {
                if (mode_box.selected == 1) {
                    widget_cpu.progress = cpu_serv.percentage_used;

                    uptime_val.label = Services.Uptime.get_uptime;

                    widget_memory.used = memory_serv.used;
                    widget_memory.total = memory_serv.total;
                    widget_memory.progress = memory_serv.percentage_used;
                    swap_val.label = "%.1f GiB / %.1f GiB".printf(swap_serv.used, swap_serv.total);

                    int[] net_speed_val = net_serv.update_bytes ();
                    widget_down.net_speed = net_speed_val[1];
                    widget_up.net_speed = net_speed_val[0];
                    widget_down.progress = net_serv.percentage_down;
                    widget_up.progress = net_serv.percentage_up;

                    /* string net_total_up = Utils.format_net_size (net_serv.bytes_in_up);
                    string net_total_down = Utils.format_net_size (net_serv.bytes_in_down);
                    total_net_val.label = @"$net_total_down / $net_total_up"; */

                    return true;
                } else {
                    return false;
                }
           });
    	}
    }
}
