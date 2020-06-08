namespace Monitor {
    public class Widgets.Memory : Gtk.Grid {
        private Tools.DrawRAM draw_ram;
        private Tools.DrawRAM draw_swap;

        private Gtk.Label swap_val;
        private Gtk.Label memory_val;

        private bool swap_on;

        private Structs.MemoryTotal memory_total;

        public Memory (Structs.MemoryTotal memory_total, Gdk.RGBA font_color) {
            margin_start = 12;
            margin_end = 12;
            hexpand = true;
            row_spacing = 8;
            column_spacing = 8;
            halign = Gtk.Align.FILL;
            valign = Gtk.Align.CENTER;

            this.memory_total = memory_total;
            swap_on = memory_total.swap != null;

            var total_label = new Gtk.Label (_("Memory") + ": ");
            total_label.halign = Gtk.Align.START;
            memory_val = new Gtk.Label (Utils.format_bytes (memory_total.memory));
            memory_val.halign = Gtk.Align.CENTER;

            draw_ram = new Tools.DrawRAM (font_color);
            draw_ram.hexpand = true;

            attach (total_label, 0, 0);
            attach (draw_ram,    1, 0);
            attach (memory_val,  0, 1, 2, 1);

            if (swap_on) {
                var swap_label = new Gtk.Label (_("Swap") + ": ");
                swap_label.halign = Gtk.Align.START;
                swap_val = new Gtk.Label (Utils.format_bytes (memory_total.swap));
                swap_val.halign = Gtk.Align.CENTER;

                draw_swap = new Tools.DrawRAM (font_color);
                draw_swap.hexpand = true;

                attach (swap_label,  0, 2);
                attach (draw_swap,   1, 2);
                attach (swap_val,    0, 3, 2, 1);
            }
        }

        public void update_values (Structs.MemoryData memory_data) {
            draw_ram.update_used (memory_data.percent_memory);
            memory_val.label = "%s / %s".printf (Utils.format_bytes (memory_data.used_memory, true),
                                                 Utils.format_bytes (memory_total.memory, true));

            if (swap_on) {
                draw_swap.update_used (memory_data.percent_swap);
                swap_val.label = "%s / %s".printf (Utils.format_bytes (memory_data.used_swap, true),
                                                   Utils.format_bytes (memory_total.swap, true));
            }
        }
    }
}
