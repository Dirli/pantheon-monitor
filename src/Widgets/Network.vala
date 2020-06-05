namespace Monitor {
    public class Widgets.Network : Gtk.Box {
        private Tools.DrawNetCircle widget_down;
        private Tools.DrawNetCircle widget_up;

        private Gtk.Label net_d_val;
        private Gtk.Label net_u_val;

        public Network (Gdk.RGBA font_color) {
            orientation = Gtk.Orientation.HORIZONTAL;
            spacing = 12;
            hexpand = true;
            halign = Gtk.Align.CENTER;

            widget_down = new Tools.DrawNetCircle ("▼ (MB)", font_color);
            widget_down.halign = Gtk.Align.CENTER;
            widget_down.tooltip_text = _("Download");
            widget_up = new Tools.DrawNetCircle ("▲ (MB)", font_color);
            widget_up.halign = Gtk.Align.CENTER;
            widget_up.tooltip_text = _("Upload");

            Gtk.Label net_label = new Gtk.Label (_("Network"));
            net_label.halign = Gtk.Align.CENTER;
            net_label.get_style_context ().add_class ("section");

            Gtk.Label net_d_label = new Gtk.Label (_("Downloaded") + ": ");
            net_d_val = new Gtk.Label ("-");

            Gtk.Label net_u_label = new Gtk.Label (_("Uploaded") + ": ");
            net_u_val = new Gtk.Label ("-");

            net_d_label.halign = net_u_label.halign = Gtk.Align.START;
            net_d_val.halign = net_u_val.halign = Gtk.Align.END;

            Gtk.Grid info_grid = new Gtk.Grid ();
            info_grid.margin_start = info_grid.margin_end = 10;
            info_grid.row_spacing = 8;
            info_grid.halign = Gtk.Align.START;
            info_grid.attach (net_label,   0, 0, 2, 1);
            info_grid.attach (net_d_label, 0, 1);
            info_grid.attach (net_d_val,   1, 1);
            info_grid.attach (net_u_label, 0, 2);
            info_grid.attach (net_u_val,   1, 2);

            var info_wrapper = new Gtk.EventBox ();
            info_wrapper.add_events(Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.ENTER_NOTIFY_MASK);

            info_wrapper.enter_notify_event.connect ((e) => {
                e.window.set_cursor (new Gdk.Cursor.from_name(Gdk.Display.get_default(), "hand2"));

                return true;
            });

            info_wrapper.add (info_grid);

            add (widget_down);
            add (info_wrapper);
            add (widget_up);
        }

        public void set_new_max (int max_val) {
            widget_down.max_numbers = max_val;
            widget_up.max_numbers = max_val;
        }

        public void update_values (Structs.NetLoadData data) {
            widget_down.net_speed = data.bytes_in;
            widget_up.net_speed = data.bytes_out;

            widget_down.progress = data.percent_in;
            widget_up.progress = data.percent_out;

            net_d_val.label = Utils.format_net_speed (data.total_in, true);
            net_u_val.label = Utils.format_net_speed (data.total_out, true);
        }
    }
}
