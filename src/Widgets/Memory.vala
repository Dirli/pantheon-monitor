/*
 * Copyright (c) 2020 Dirli <litandrej85@gmail.com>
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
    public class Widgets.Memory : Gtk.Grid {
        private Gtk.ProgressBar memory_bar;
        private Gtk.ProgressBar swap_bar;

        private Gtk.Label swap_val;
        private Gtk.Label memory_val;

        public bool swap_on {construct set; get;}

        public Structs.MemoryTotal memory_total {construct set; get;}

        public Memory (Structs.MemoryTotal m_total) {
            Object (margin_start: 12,
                    margin_end: 12,
                    hexpand: true,
                    row_spacing: 8,
                    column_spacing: 8,
                    halign: Gtk.Align.FILL,
                    valign: Gtk.Align.CENTER,
                    memory_total: m_total);
        }

        construct {
            unowned Gtk.StyleContext style_context = get_style_context ();
            style_context.add_class (Granite.STYLE_CLASS_CARD);
            style_context.add_class (Granite.STYLE_CLASS_ROUNDED);
            style_context.add_class ("res-card");

            swap_on = memory_total.swap != null;

            var total_label = new Gtk.Label (_("Memory") + ": ");
            total_label.halign = Gtk.Align.START;
            memory_val = new Gtk.Label (Utils.format_bytes (memory_total.memory));
            memory_val.halign = Gtk.Align.CENTER;

            memory_bar = new Gtk.ProgressBar ();
            memory_bar.valign = Gtk.Align.CENTER;
            memory_bar.hexpand = true;

            attach (total_label, 0, 0, 1, 2);
            attach (memory_val,  1, 0);
            attach (memory_bar,  1, 1);

            if (swap_on) {
                var swap_label = new Gtk.Label (_("Swap") + ": ");
                swap_label.halign = Gtk.Align.START;
                swap_val = new Gtk.Label (Utils.format_bytes (memory_total.swap));
                swap_val.halign = Gtk.Align.CENTER;

                swap_bar = new Gtk.ProgressBar ();
                swap_bar.valign = Gtk.Align.CENTER;
                swap_bar.hexpand = true;

                attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, 2, 2);
                attach (swap_label, 0, 3, 1, 2);
                attach (swap_val,   1, 3);
                attach (swap_bar,   1, 4);
            }
        }

        public void update_values (Structs.MemoryData memory_data) {
            memory_bar.set_fraction (memory_data.percent_memory / 100.0);
            memory_bar.tooltip_text = @"$(memory_data.percent_memory)%";
            memory_val.label = "%s / %s".printf (Utils.format_bytes (memory_data.used_memory, true),
                                                 Utils.format_bytes (memory_total.memory, true));

            if (swap_on) {
                swap_bar.set_fraction (memory_data.percent_swap / 100.0);
                swap_bar.tooltip_text = @"$(memory_data.percent_swap)%";
                swap_val.label = "%s / %s".printf (Utils.format_bytes (memory_data.used_swap, true),
                                                   Utils.format_bytes (memory_total.swap, true));
            }
        }
    }
}
