namespace Monitor {
    public class Widgets.NetworkPopover : Gtk.Box {
        public NetworkPopover (Structs.NetIface[] ifaces) {
            Object (margin: 12,
                    orientation: Gtk.Orientation.HORIZONTAL,
                    spacing: 8);

            bool need_separator = false;
            foreach (Structs.NetIface iface in ifaces) {
                if (need_separator) {
                    var v_separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);
                    v_separator.hexpand = true;

                    add (v_separator);
                } else {
                    need_separator = true;
                }

                add_iface (iface);
            }

            show_all ();
        }

        public void add_iface (Structs.NetIface iface) {
            var iface_grid = new Gtk.Grid ();
            iface_grid.valign = Gtk.Align.CENTER;
            iface_grid.row_spacing = 6;
            iface_grid.column_spacing = 6;

            int top = 0;
            var iface_name = new Gtk.Label (iface.name);
            iface_grid.attach (iface_name, 0, top++, 2, 1);

            var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            separator.hexpand = true;

            iface_grid.attach (separator, 0, top++, 2, 1);

            string address_value = _("Unplugged");
            if (iface.address != 0) {
                address_value = "%u.%u.%u.%u".printf ((iface.address & 0x000000ff),
                                                      (iface.address & 0x0000ff00) >> 8,
                                                      (iface.address & 0x00ff0000) >> 16,
                                                      (iface.address & 0xff000000) >> 24);
            }


            add_new_str (ref iface_grid, _("IP address"), address_value, top++);

            if (iface.hwaddress != "") {
                add_new_str (ref iface_grid, _("MAC address"), iface.hwaddress, top++);
            }

            var bytes_title = new Gtk.Label (_("Bytes"));
            iface_grid.attach (bytes_title, 0, top++, 2, 1);

            add_new_str (ref iface_grid, _("Downloaded"), Utils.format_bytes (iface.bytes_in, true), top++);
            add_new_str (ref iface_grid, _("Uploaded"), Utils.format_bytes (iface.bytes_out, true), top++);

            var packets_title = new Gtk.Label (_("Packets"));
            iface_grid.attach (packets_title, 0, top++, 2, 1);

            add_new_str (ref iface_grid, _("Received"), "%llu".printf (iface.packets_in), top++);
            add_new_str (ref iface_grid, _("Transferred"), "%llu".printf (iface.packets_out), top++);

            add (iface_grid);
        }

        private void add_new_str (ref Gtk.Grid w, string label_str, string value_str, int str_top) {
            var iter_label = new Gtk.Label (label_str + ":");
            iter_label.halign = Gtk.Align.END;

            var iter_value = new Gtk.Label (value_str);
            iter_value.halign = Gtk.Align.START;
            iter_value.set_ellipsize (Pango.EllipsizeMode.END);

            w.attach (iter_label, 0, str_top);
            w.attach (iter_value, 1, str_top);
        }
    }
}
