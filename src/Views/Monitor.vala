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
        private Widgets.Memory widget_memory;
        private Widgets.Network widget_net;

        private Services.ResourcesManager resource_manager;

        private Gtk.Label uptime_val;

        public Monitor (Gdk.RGBA current_color) {
            orientation = Gtk.Orientation.VERTICAL;
            spacing = 15;
            margin = 15;
            expand = true;

            resource_manager = new Services.ResourcesManager ();

            widget_cpu = new Widgets.Cpu (current_color, resource_manager.quantity_cores);

            add (widget_cpu);

            widget_memory = new Widgets.Memory (resource_manager.memory_total, current_color);

            var ram_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            ram_separator.hexpand = true;

            add (ram_separator);
            add (widget_memory);

            widget_net = new Widgets.Network (current_color);

            var net_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            net_separator.hexpand = true;

            add (net_separator);
            add (widget_net);

            resource_manager.notify["network-speed"].connect (() => {
                widget_net.set_new_max (resource_manager.network_speed);
            });

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

        public void stop_timer () {
            if (t_id > 0) {
                GLib.Source.remove (t_id);
                t_id = 0;
            }
        }

        private bool update () {
            widget_cpu.update_values (Utils.format_frequency (resource_manager.update_freq ()), resource_manager.update_cpus ());

            widget_memory.update_values (resource_manager.update_memory ());
            widget_net.update_values (resource_manager.update_network (true, true));

            uptime_val.label = _("Uptime") + ": " + resource_manager.update_uptime ();

            return true;
    	}
    }
}
