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
    public class Views.Monitor: Gtk.Box {
        private uint t_id = 0;

        private Widgets.Cpu widget_cpu;
        private Widgets.Network widget_down;
        private Widgets.Network widget_up;
        private Widgets.Memory widget_memory;

        private Services.CPU cpu_serv;
        private Services.Memory memory_serv;
        private Services.Swap swap_serv;
        private Services.Net net_serv;

        private Gtk.Label net_d_val;
        private Gtk.Label net_u_val;
        private Gtk.Label uptime_val;

        private bool first_step;
        private Gdk.RGBA c_color;

        public Monitor (Gdk.RGBA current_color) {
            orientation = Gtk.Orientation.VERTICAL;
            spacing = 15;
            margin = 15;
            expand = true;
            c_color = current_color;

            first_step = true;

            cpu_serv = new Services.CPU ();
            memory_serv = new Services.Memory ();
            swap_serv = new Services.Swap ();
            net_serv = new Services.Net ();

            widget_cpu = new Widgets.Cpu (current_color, cpu_serv.quantity_cores);

            add (widget_cpu);

            widget_memory = new Widgets.Memory (memory_serv.total, swap_serv.total, current_color);

            var ram_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            ram_separator.hexpand = true;

            add (ram_separator);
            add (widget_memory);

            build_net ();

            var bottom_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            bottom_separator.hexpand = true;

            uptime_val = new Gtk.Label ("-");
            uptime_val.halign = Gtk.Align.CENTER;

            add (bottom_separator);
            add (uptime_val);

            border_width = 0;

            show_all ();

            t_id = GLib.Timeout.add_seconds (1, update);
        }

        private void build_net () {
            var net_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
            net_box.hexpand = true;
            net_box.halign = Gtk.Align.CENTER;

            widget_down = new Widgets.Network ("▼ (MB)", c_color);
            widget_down.halign = Gtk.Align.CENTER;
            widget_down.tooltip_text = _("Download");
            widget_up = new Widgets.Network ("▲ (MB)", c_color);
            widget_up.halign = Gtk.Align.CENTER;
            widget_up.tooltip_text = _("Upload");

            net_serv.new_max_value.connect ((max_val) => {
                widget_down.max_numbers = max_val;
                widget_up.max_numbers = max_val;
            });

            Gtk.Label net_label = new Gtk.Label (_("Network"));
            net_label.halign = Gtk.Align.CENTER;
            net_label.get_style_context ().add_class ("section");

            Gtk.Label net_d_label = new Gtk.Label (_("Downloaded") + ": ");
            net_d_val = new Gtk.Label ("-");

            Gtk.Label net_u_label = new Gtk.Label (_("Uploaded") + ": ");
            net_u_val = new Gtk.Label ("-");

            net_d_label.halign = net_u_label.halign = Gtk.Align.START;
            net_d_val.halign = net_u_val.halign = Gtk.Align.END;

            Gtk.Grid info_grid = new Gtk.Grid ();
            info_grid.margin_start = info_grid.margin_end = 10;
            info_grid.row_spacing = 8;
            info_grid.halign = Gtk.Align.START;
            info_grid.attach (net_label,   0, 0, 2, 1);
            info_grid.attach (net_u_label, 0, 1);
            info_grid.attach (net_u_val,   1, 1);
            info_grid.attach (net_d_label, 0, 2);
            info_grid.attach (net_d_val,   1, 2);

            net_box.add (widget_down);
            net_box.add (info_grid);
            net_box.add (widget_up);

            var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            separator.hexpand = true;

            add (separator);
            add (net_box);
        }

        public void stop_timer () {
            if (t_id > 0) {
                GLib.Source.remove (t_id);
                t_id = 0;
            }
        }

        private bool update () {
            widget_cpu.update_values (Utils.format_frequency (cpu_serv.frequency), cpu_serv.get_percentage ());

            uptime_val.label = _("Uptime") + ": " + Services.Uptime.get_uptime;

            widget_memory.update_values (memory_serv.percentage_used,
                                         memory_serv.used,
                                         swap_serv.percentage_used,
                                         swap_serv.used);

            // network section
            Structs.NetLoadData net_data = net_serv.update_bytes (first_step);
            widget_down.net_speed = net_data.bytes_in;
            widget_up.net_speed = net_data.bytes_out;
            widget_down.progress = net_serv.percentage_down;
            widget_up.progress = net_serv.percentage_up;

            net_d_val.label = Utils.format_net_speed (net_data.total_in, true);
            net_u_val.label = Utils.format_net_speed (net_data.total_out, true);

            if (first_step) {first_step = false;}

            return true;
    	}
    }
}
