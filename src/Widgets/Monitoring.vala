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

        private Gtk.Label total_down_val;
        private Gtk.Label total_up_val;
        private Gtk.Label uptime_val;
        private Gtk.Label swap_val;

        private bool first_step;

        public Monitoring (Granite.Widgets.ModeButton mode_box, Gdk.RGBA current_color) {
            row_spacing = 20;
            margin = 15;
            expand = true;

            first_step = true;

            cpu_serv = new Services.CPU ();
            memory_serv = new Services.Memory ();
            swap_serv = new Services.Swap ();
            net_serv = new Services.Net ();

            widget_cpu = new Widgets.Cpu ("CPU", current_color);
            widget_cpu.hexpand = true;
            widget_cpu.halign = Gtk.Align.CENTER;
            widget_cpu.cores = cpu_serv.quantity_cores;

            widget_memory = new Widgets.Memory ("RAM", current_color);
            widget_memory.hexpand = true;
            widget_memory.halign = Gtk.Align.CENTER;
            widget_down = new Widgets.Network ("▼ (MB)", current_color);
            widget_down.tooltip_text = _("Download");
            widget_up = new Widgets.Network ("▲ (MB)", current_color);
            widget_up.tooltip_text = _("Upload");

            net_serv.new_max_value.connect ((max_val) => {
                widget_down.max_numbers = max_val;
                widget_up.max_numbers = max_val;
            });

            Gtk.Label common_label = new Gtk.Label (_("Common"));
            common_label.get_style_context ().add_class ("section");
            Gtk.Label net_label = new Gtk.Label (_("Network"));
            net_label.get_style_context ().add_class ("section");

            Gtk.Grid common_grid = new Gtk.Grid ();
            common_grid.margin_start = common_grid.margin_end = 10;
            common_grid.row_spacing = 10;
            common_grid.halign = Gtk.Align.START;

            Gtk.Label total_down_label = new Gtk.Label (_("Total download") + ": ");
            total_down_val = new Gtk.Label ("-");

            Gtk.Label total_up_label = new Gtk.Label (_("Total upload") + ": ");
            total_up_val = new Gtk.Label ("-");

            Gtk.Label swap_label = new Gtk.Label (_("Swap") + ": ");
            swap_val = new Gtk.Label ("-");

            Gtk.Label uptime_label = new Gtk.Label (_("Uptime") + ": ");
            uptime_val = new Gtk.Label ("-");

            total_down_label.halign = total_up_label.halign = Gtk.Align.START;
            total_down_val.halign = total_up_val.halign = Gtk.Align.END;

            uptime_label.halign = swap_label.halign = Gtk.Align.START;
            uptime_val.halign = swap_val.halign = Gtk.Align.END;

            common_grid.attach (total_down_label, 0, 0, 1, 1);
            common_grid.attach (total_down_val,   1, 0, 1, 1);
            common_grid.attach (total_up_label,   0, 1, 1, 1);
            common_grid.attach (total_up_val,     1, 1, 1, 1);
            common_grid.attach (swap_label,       0, 2, 1, 1);
            common_grid.attach (swap_val,         1, 2, 1, 1);
            common_grid.attach (uptime_label,     0, 3, 1, 1);
            common_grid.attach (uptime_val,       1, 3, 1, 1);

            attach (widget_cpu,    0, 0, 1, 1);
            attach (widget_memory, 1, 0, 1, 1);
            attach (net_label,     0, 1, 2, 1);
            attach (widget_down,   0, 2, 1, 1);
            attach (widget_up,     1, 2, 1, 1);
            attach (common_label,  0, 3, 2, 1);
            attach (common_grid,   0, 4, 2, 1);

            border_width = 0;
            show_all ();
            update (mode_box);
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

                    Structs.NetLoadData net_data = net_serv.update_bytes (first_step);
                    widget_down.net_speed = net_data.bytes_in;
                    widget_up.net_speed = net_data.bytes_out;
                    widget_down.progress = net_serv.percentage_down;
                    widget_up.progress = net_serv.percentage_up;

                    total_down_val.label = Utils.format_net_speed (net_data.total_in, true);
                    total_up_val.label = Utils.format_net_speed (net_data.total_out, true);

                    if (first_step) {first_step = false;}

                    return true;
                } else {
                    return false;
                }
           });
    	}
    }
}
