/*
 * Copyright (c) 2018-2022 Dirli <litandrej85@gmail.com>
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
    public class Widgets.Cpu : Gtk.Grid {
        private Gtk.Label freq_val;

        public Gdk.RGBA f_color {
            get;
            construct set;
        }

        private Tools.DrawCpu draw_cpu;
        public int cores {
            get;
            construct set;
        }

        public Cpu (Gdk.RGBA current_color, int cores) {
            Object (hexpand: true,
                    halign: Gtk.Align.CENTER,
                    valign: Gtk.Align.CENTER,
                    margin_start: 12,
                    margin_end: 12,
                    margin_top: 12,
                    margin_bottom: 12,
                    row_spacing: 8,
                    column_spacing: 8,
                    f_color: current_color,
                    cores: cores);
        }

        construct {
            var cpu_label = new Gtk.Label (_("CPU")) {
                halign = Gtk.Align.START
            };
            cpu_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

            freq_val = new Gtk.Label ("");
            freq_val.set_width_chars (8);

            var info_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 5) {
                valign = Gtk.Align.CENTER
            };
            info_box.add (freq_val);
            info_box.add (new Gtk.Label ("%d %s".printf (cores, _("cores"))));

            var view_btns = new Granite.Widgets.ModeButton () {
                homogeneous = false,
                halign = Gtk.Align.END
            };

            view_btns.append (new Gtk.Label (_("diagram")));
            view_btns.append (new Gtk.Label (_("graph")));

            draw_cpu = new Tools.DrawCpu (cores);
            draw_cpu.t_color = f_color;

            attach (cpu_label, 0, 0);
            attach (view_btns, 1, 0);
            attach (info_box, 0, 1);
            attach (draw_cpu, 1, 1);

            view_btns.mode_changed.connect (() => {
                halign = view_btns.selected == Enums.ViewCPU.DIAGRAM ? Gtk.Align.CENTER : Gtk.Align.FILL;
                draw_cpu.view_type = (Enums.ViewCPU) view_btns.selected;
            });
            view_btns.selected = 0;
        }

        public void update_values (string new_freq, int[] cpus_percentage) {
            freq_val.label = new_freq;
            draw_cpu.update_used (cpus_percentage);
        }
    }
}
