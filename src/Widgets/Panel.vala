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
    public class Widgets.Panel : Gtk.Box {
        private Gtk.Image mem_image;
        private Gtk.Label mem_value;
        private Gtk.Image cpu_image;
        private Gtk.Label cpu_value;

        public Panel () {
            Object (orientation: Gtk.Orientation.HORIZONTAL);

            cpu_image = new Gtk.Image.from_icon_name ("proc-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            cpu_value = new Gtk.Label ("-");
            pack_start (cpu_image, false, false, 0);
            pack_start (cpu_value, false, false, 0);

            mem_image = new Gtk.Image.from_icon_name ("memory-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            mem_value = new Gtk.Label ("-");
            pack_start (mem_image, false, false, 0);
            pack_start (mem_value, false, false, 0);
        }

        public void update_cpu (string new_val) {
            cpu_value.label = new_val;
        }

        public void update_mem (string new_val) {
            mem_value.label = new_val;
        }


        public void update_ui (bool cpu_flag, bool ram_flag, bool titles_flag) {
            cpu_value.set_visible(cpu_flag);
            mem_value.set_visible(ram_flag);
            if (ram_flag) {
                mem_image.set_visible(titles_flag);
            } else {
                mem_image.set_visible(false);
            }

            if (cpu_flag) {
                cpu_image.set_visible(titles_flag);
            } else {
                cpu_image.set_visible(false);
            }
        }
    }
}
