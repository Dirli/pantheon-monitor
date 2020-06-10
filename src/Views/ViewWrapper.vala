namespace Monitor {
    public abstract class Views.ViewWrapper : Gtk.Box {
        public abstract void start_timer ();
        public abstract void stop_timer ();

        public Gtk.ScrolledWindow main_widget;

        construct {
            main_widget = new Gtk.ScrolledWindow (null, null);

            main_widget.expand = true;
            main_widget.margin_start = main_widget.margin_end = 15;
            main_widget.margin_top = main_widget.margin_bottom = 10;

            add (main_widget);
        }

    }
}
