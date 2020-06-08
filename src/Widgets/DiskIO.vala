namespace Monitor {
    public class Widgets.DiskIO : Gtk.Box {
        private Tools.DrawDiskIO draw_diskio;

        public DiskIO () {
            orientation = Gtk.Orientation.VERTICAL;
            margin_start = 12;
            margin_end = 12;
            spacing = 8;
            hexpand = true;
            halign = Gtk.Align.FILL;
            valign = Gtk.Align.CENTER;

            var diskio_label = new Gtk.Label (_("Disk read/write"));
            add (diskio_label);

            draw_diskio = new Tools.DrawDiskIO ();
            draw_diskio.hexpand = true;

            add (draw_diskio);
        }

        public void update_values (uint64 read_value, uint64 write_value) {
            draw_diskio.add_values (read_value, write_value);
        }
    }
}
