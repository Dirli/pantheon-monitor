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
    public class Widgets.Cpu : Gtk.Box {
        private Gtk.Label freq_val;

        private Tools.DrawCpu draw_cpu;

        public Cpu (Gdk.RGBA font_color, int cores) {
            orientation = Gtk.Orientation.HORIZONTAL;
            hexpand = true;
            halign = Gtk.Align.CENTER;
            valign = Gtk.Align.CENTER;
            spacing = 8;
            margin = 25;

            var info_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
            info_box.valign = Gtk.Align.CENTER;
            var cpu_label = new Gtk.Label (_("CPU"));
            cpu_label.get_style_context ().add_class ("section");
            freq_val = new Gtk.Label ("");
            freq_val.set_width_chars (8);
            var cores_label = new Gtk.Label ("%d %s".printf (cores, _("cores")));

            info_box.add (cpu_label);
            info_box.add (freq_val);
            info_box.add (cores_label);

            draw_cpu = new Tools.DrawCpu (font_color, cores);
            draw_cpu.hexpand = true;

            add (info_box);
            add (draw_cpu);
        }

        public void update_values (string new_freq, int[] cpus_percentage) {
            freq_val.label = new_freq;
            draw_cpu.update_used (cpus_percentage);
        }
    }
}
