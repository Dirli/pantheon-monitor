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
    public class Widgets.Cpu : Gtk.Box {
        private Gtk.Label freq_val;

        private Tools.DrawCpu draw_cpu;
        public int cores {
            get;
            construct set;
        }

        public Cpu (int cores) {
            Object (orientation: Gtk.Orientation.VERTICAL,
                    hexpand: true,
                    spacing: 8,
                    halign: Gtk.Align.FILL,
                    valign: Gtk.Align.CENTER,
                    cores: cores);
        }

        construct {
            unowned Gtk.StyleContext style_context = get_style_context ();
            style_context.add_class (Granite.STYLE_CLASS_CARD);
            style_context.add_class (Granite.STYLE_CLASS_ROUNDED);
            style_context.add_class ("res-card");

            var cpu_label = new Gtk.Label (_("CPU"));
            cpu_label.halign = Gtk.Align.START;
            cpu_label.get_style_context ().add_class ("section");

            freq_val = new Gtk.Label ("");
            freq_val.set_width_chars (8);

            var info_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
            info_box.valign = Gtk.Align.CENTER;
            info_box.add (freq_val);
            info_box.add (new Gtk.Label ("%d %s".printf (cores, _("cores"))));

            draw_cpu = new Tools.DrawCpu (cores);

            var cpu_wrapper = new Gtk.Grid ();
            cpu_wrapper.halign = Gtk.Align.CENTER;
            cpu_wrapper.row_spacing = 8;
            cpu_wrapper.column_spacing = 8;

            cpu_wrapper.attach (cpu_label, 0, 0);
            cpu_wrapper.attach (info_box, 0, 1);
            cpu_wrapper.attach (draw_cpu, 1, 1);

            add (cpu_wrapper);
        }

        public void update_values (string new_freq, int[] cpus_percentage) {
            freq_val.label = new_freq;
            draw_cpu.update_used (cpus_percentage);
        }
    }
}
