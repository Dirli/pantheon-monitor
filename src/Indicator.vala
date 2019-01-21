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
    public class Indicator : Wingpanel.Indicator {
        private GLib.Settings settings;

        private Widgets.Popover popover_wid = null;
        private Widgets.Panel panel_wid;

        private Services.CPU? cpu_serv;
        private Services.Memory? memory_serv;
        private Services.Swap? swap_serv;

        private bool extended;
        private uint timeout_id;

        public Indicator () {
            Object (code_name : "monitor-indicator",
            display_name : _("Monitor Indicator"),
            description: _("Monitors and displays the temperature on the Wingpanel"));
            extended = false;

            settings = Services.SettingsManager.get_default ();
            visible = settings.get_boolean ("indicator");

            cpu_serv = new Services.CPU ();
            memory_serv = new Services.Memory ();
            swap_serv = new Services.Swap ();

            settings.changed["indicator"].connect (on_indicator_change);
            settings.changed["indicator-titles"].connect (on_update_ui);
            settings.changed["indicator-ram"].connect (on_update_ui);
            settings.changed["indicator-cpu"].connect (on_update_ui);
        }

        protected void on_update_ui () {
            panel_wid.update_ui (
                settings.get_boolean ("indicator-cpu"),
                settings.get_boolean ("indicator-ram"),
                settings.get_boolean ("indicator-titles")
            );
        }

        private unowned bool update() {
            if (extended) {
                if (popover_wid != null) {
                    popover_wid.update_state (
                        Utils.format_frequency (cpu_serv.frequency),
                        "%.1f GiB / %.1f GiB".printf(memory_serv.used, memory_serv.total),
                        "%.1f GiB / %.1f GiB".printf(swap_serv.used, swap_serv.total),
                        Services.Uptime.get_uptime
                    );
                }
            } else {
                if (settings.get_boolean ("indicator-cpu")) {
                    panel_wid.update_cpu ("%d%%".printf (cpu_serv.percentage_used));
                }
                if (settings.get_boolean ("indicator-ram")) {
                    panel_wid.update_mem ("%d%%".printf (memory_serv.percentage_used));
                }
            }
            return true;
        }

        protected void on_indicator_change () {
            if (settings.get_boolean ("indicator")) {
                visible = true;
                start_watcher ();
            } else {
                visible = false;
                stop_watcher ();
            }
        }

        public override Gtk.Widget get_display_widget () {
            if (panel_wid == null) {
                panel_wid = new Widgets.Panel ();
                if (visible) {
                    start_watcher ();
                    Timeout.add_seconds (1, () => {
                        on_update_ui ();
                        return false;
                    });
                }
            }

            return panel_wid;
        }

        public override Gtk.Widget? get_widget () {
            if (popover_wid == null) {
                popover_wid = new Widgets.Popover ();
                popover_wid.close_popover.connect (() => {
                    extended = false;
                });
            }

            return popover_wid;
        }

        private void start_watcher () {
            if (timeout_id > 0) {
                Source.remove (timeout_id);
            }

            timeout_id = GLib.Timeout.add_seconds (1, update);
        }

        private void stop_watcher () {
            if (timeout_id > 0) {
                Source.remove (timeout_id);
            }
        }

        public override void opened () {
            extended = true;
        }

        public override void closed () {
            extended = false;
        }
    }
}

public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("Activating Monitor Indicator");
    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        return null;
    }

    var indicator = new Monitor.Indicator ();
    return indicator;
}
