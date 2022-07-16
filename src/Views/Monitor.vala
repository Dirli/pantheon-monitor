/*
 * Copyright (c) 2018-2020 Dirli <litandrej85@gmail.com>
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
    public class Views.Monitor : Views.ViewWrapper {
        private uint t_id = 0;

        private Widgets.Cpu widget_cpu;
        private Widgets.Memory widget_memory;
        private Widgets.Network widget_net;
        private Widgets.DiskIO widget_diskio;

        private Services.ResourcesManager resource_manager;

        private Gtk.Popover extended_window;
        private Gtk.Label uptime_val;

        public Gdk.RGBA current_color {
            get;
            construct set;
        }

        public Monitor (Gdk.RGBA current_color) {
            Object (orientation: Gtk.Orientation.VERTICAL,
                    current_color: current_color);
        }

        construct {
            var inner_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 15);
            inner_box.valign = Gtk.Align.CENTER;
            inner_box.margin = 15;
            inner_box.spacing = 15;
            inner_box.expand = true;

            resource_manager = new Services.ResourcesManager ();
            extended_window = new Gtk.Popover (null);

            widget_cpu = new Widgets.Cpu (current_color, resource_manager.quantity_cores);

            inner_box.add (widget_cpu);

            inner_box.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

            widget_memory = new Widgets.Memory (resource_manager.memory_total);
            inner_box.add (widget_memory);

            inner_box.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

            widget_diskio = new Widgets.DiskIO (current_color);
            inner_box.add (widget_diskio);

            inner_box.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

            widget_net = new Widgets.Network (current_color);
            widget_net.show_popover.connect ((w) => {
                var popover_grid = new Widgets.NetworkPopover (resource_manager.update_ifaces ());

                open_popover (w, popover_grid);
            });
            inner_box.add (widget_net);

            resource_manager.notify["network-speed"].connect (() => {
                widget_net.set_new_max (resource_manager.network_speed);
            });

            uptime_val = new Gtk.Label ("-");
            uptime_val.halign = Gtk.Align.CENTER;

            inner_box.add (uptime_val);

            border_width = 0;

            main_widget.add (inner_box);
        }

        public override void start_timer () {
            if (t_id == 0) {
                resource_manager.reset_func ();

                t_id = GLib.Timeout.add_seconds (1, update);
            }
        }

        public override void stop_timer () {
            if (t_id > 0) {
                GLib.Source.remove (t_id);
                t_id = 0;
            }

            widget_diskio.clear_cache ();
        }

        private bool update () {
            widget_cpu.update_values (Utils.format_frequency (resource_manager.update_freq ()), resource_manager.update_cpus ());

            widget_memory.update_values (resource_manager.update_memory ());
            widget_net.update_values (resource_manager.update_network (true, true));

            uptime_val.label = _("Uptime") + ": " + resource_manager.update_uptime ();

            var dio = resource_manager.update_diskio ();
            if (dio != null) {
                widget_diskio.update_values (dio.read, dio.write);
            }

            return true;
    	}

        public void open_popover (Gtk.Widget relative, Gtk.Widget grid) {
            extended_window.foreach ((inner_widget) => {
                inner_widget.destroy ();
            });

            extended_window.add (grid);
            extended_window.set_relative_to (relative);
            extended_window.popup ();
        }
    }
}
