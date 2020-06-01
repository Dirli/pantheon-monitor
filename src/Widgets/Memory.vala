namespace Monitor {
    public class Widgets.Memory : Gtk.Grid {
        private Tools.DrawRAM draw_ram;
        private Tools.DrawRAM draw_swap;

        private Gtk.Label swap_val;
        private Gtk.Label memory_val;

        private float memory_total;
        private float swap_total;

        public Memory (float m_total, float s_total, Gdk.RGBA font_color) {
            margin_start = 12;
            margin_end = 12;
            hexpand = true;
            row_spacing = 8;
            column_spacing = 8;
            halign = Gtk.Align.FILL;
            valign = Gtk.Align.CENTER;

            memory_total = m_total;
            swap_total = s_total;

            var total_label = new Gtk.Label (_("Memory") + ": ");
            total_label.halign = Gtk.Align.START;
            memory_val = new Gtk.Label ("%.1f GiB".printf (m_total));
            memory_val.halign = Gtk.Align.CENTER;

            draw_ram = new Tools.DrawRAM (font_color);
            draw_ram.hexpand = true;

            attach (total_label, 0, 0);
            attach (draw_ram,    1, 0);
            attach (memory_val,  0, 1, 2, 1);

            if (s_total > 0.0) {
                var swap_label = new Gtk.Label (_("Swap") + ": ");
                swap_label.halign = Gtk.Align.START;
                swap_val = new Gtk.Label ("%.1f GiB".printf (s_total));
                swap_val.halign = Gtk.Align.CENTER;

                draw_swap = new Tools.DrawRAM (font_color);
                draw_swap.hexpand = true;

                attach (swap_label,  0, 2);
                attach (draw_swap,   1, 2);
                attach (swap_val,    0, 3, 2, 1);
            }
        }

        public void update_values (int mem_percent, float mem_used, int swap_percent, float swap_used) {
            draw_ram.update_used (mem_percent);
            memory_val.label = "%.1f GiB / %.1f GiB".printf (mem_used, memory_total);

            if (swap_total > 0.0) {
                draw_swap.update_used (swap_percent);
                swap_val.label = "%.1f GiB / %.1f GiB".printf (swap_used, swap_total);
            }
        }
    }
}
