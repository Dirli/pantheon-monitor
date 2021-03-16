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

        private bool? _indicator_ram = null;
        public bool indicator_ram {
            get {
                return _indicator_ram;
            }
            set {
                bool update_ui_flag = _indicator_ram != null;
                _indicator_ram = value;
                if (update_ui_flag) {
                    update_ui ();
                }
            }
        }
        private bool? _indicator_cpu = null;
        public bool indicator_cpu {
            get {
                return _indicator_cpu;
            }
            set {
                bool update_ui_flag = _indicator_cpu != null;
                _indicator_cpu = value;
                if (update_ui_flag) {
                    update_ui ();
                }
            }
        }
        private bool? _indicator_net = null;
        public bool indicator_net {
            get {
                return _indicator_net;
            }
            set {
                bool update_ui_flag = _indicator_net != null;
                _indicator_net = value;
                if (update_ui_flag) {
                    update_ui ();
                }
            }
        }
        private bool? _indicator_titles = null;
        public bool indicator_titles {
            get {
                return _indicator_titles;
            }
            set {
                bool update_ui_flag = _indicator_titles != null;
                _indicator_titles = value;
                if (update_ui_flag) {
                    update_ui ();
                }
            }
        }

        private Widgets.Popover popover_wid = null;
        private Widgets.Panel panel_wid;

        private Services.ResourcesManager resource_manager;

        private bool extended;
        private uint timeout_id;

        public Indicator () {
            Object (code_name: "monitor-indicator");

            extended = false;

            Gtk.IconTheme.get_default().add_resource_path("/io/elementary/monitor/icons");

            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/io/elementary/monitor/style/application.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            settings = new GLib.Settings (Constants.PROJECT_NAME);
            visible = settings.get_boolean ("indicator");

            resource_manager = new Services.ResourcesManager ();

            settings.bind ("indicator-ram", this, "indicator-ram", SettingsBindFlags.DEFAULT);
            settings.bind ("indicator-net", this, "indicator-net", SettingsBindFlags.DEFAULT);
            settings.bind ("indicator-titles", this, "indicator-titles", SettingsBindFlags.DEFAULT);
            settings.bind ("indicator-cpu", this, "indicator-cpu", SettingsBindFlags.DEFAULT);

            settings.changed["indicator"].connect (on_indicator_change);
        }

        protected void update_ui () {
            panel_wid.update_ui (
                indicator_cpu,
                indicator_ram,
                indicator_net,
                indicator_titles
            );
        }

        private unowned bool update() {
            if (extended) {
                if (popover_wid != null) {
                    var memory_data = resource_manager.update_memory ();
                    popover_wid.update_state (
                        Utils.format_frequency (resource_manager.update_freq ()),
                        Utils.format_bytes (memory_data.used_memory, true),
                        memory_data.used_swap != null ? Utils.format_bytes (memory_data.used_swap, true) : _("Off"),
                        resource_manager.update_uptime ()
                    );

                    var io_data = resource_manager.update_diskio ();
                    popover_wid.update_io (Utils.format_bytes (io_data.read), Utils.format_bytes (io_data.write));
                }
            } else {
                if (indicator_cpu) {
                    panel_wid.update_cpu ("%.2d%%".printf (resource_manager.update_cpu ()));
                }
                if (indicator_ram) {
                    var m = resource_manager.update_memory (false);
                    panel_wid.update_mem ("%.2d%%".printf (m.percent_memory));
                }
                if (indicator_net) {
                    Structs.NetLoadData net_data = resource_manager.update_network (false);
                    string down_val = net_data.bytes_in > 0 ? Utils.format_bytes (net_data.bytes_in) : "";
                    string up_val = net_data.bytes_out > 0 ? Utils.format_bytes (net_data.bytes_out) : "";

                    panel_wid.update_net (down_val, up_val);
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
                settings.bind ("compact-size", panel_wid, "compact-size", SettingsBindFlags.DEFAULT);
                settings.bind ("compact-net", panel_wid, "compact-net", SettingsBindFlags.DEFAULT);
                if (visible) {
                    start_watcher ();
                    Timeout.add_seconds (1, () => {
                        update_ui ();
                        return false;
                    });
                }
            }

            return panel_wid;
        }

        public override Gtk.Widget? get_widget () {
            if (popover_wid == null) {
                popover_wid = new Widgets.Popover ();
                popover_wid.open_monitor.connect (() => {
                    close ();

                    var app_info = new GLib.DesktopAppInfo (Constants.PROJECT_NAME + ".desktop");
                    if (app_info == null) {return;}

                    try {
                        app_info.launch (null, null);
                    } catch (Error e) {
                        warning ("Unable to launch io.elementary.monitor.desktop: %s", e.message);
                    }
                });
                popover_wid.hide_indicator.connect (() => {
                    settings.set_boolean ("indicator", false);
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

                timeout_id = 0;
            }
        }

        public override void opened () {
            extended = true;
            if (popover_wid != null) {
                Structs.NetLoadData net_data = resource_manager.update_network (false);
                popover_wid.update_total_network (Utils.format_bytes (net_data.total_in, true),
                                                  Utils.format_bytes (net_data.total_out, true));

                popover_wid.clear_volumes_box ();

                var d_manager = new Services.DisksManager ();
                d_manager.get_mounted_volumes ().foreach ((volume) => {
                    var vol_label = new Gtk.Label (volume.label != ""
                                                   ? "%s (%s)".printf (volume.label, volume.device)
                                                   : volume.device);
                    vol_label.halign = Gtk.Align.START;

                    var progress_bar = new Gtk.ProgressBar ();
                    progress_bar.tooltip_text = _("free / total") + ": %s / %s".printf (d_manager.size_to_display (volume.free),
                                                                                        d_manager.size_to_display (volume.size));

                    var used_percent = 1 - (double) volume.free / volume.size;

                    progress_bar.set_fraction (used_percent);
                    popover_wid.add_volume (vol_label, progress_bar);

                    return true;
                });

                popover_wid.show_all ();
            }
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
