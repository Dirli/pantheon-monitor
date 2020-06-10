namespace Monitor {
    public class Views.Processes : Views.ViewWrapper {
        private Widgets.Process process_view;
        private Models.GenericModel process_list;
        private Gtk.TreeModelFilter proc_filter;

        private Gtk.TreeSelection tree_selection;

        private string _filter_text = "";
        public string filter_text {
            set {
                _filter_text = value;
                proc_filter.refilter ();
            }
        }

        public Processes () {
            Object (orientation: Gtk.Orientation.VERTICAL,
                    spacing: 0);
        }

        construct {
            process_list = new Models.GenericModel ();

            process_view = new Widgets.Process ();

            proc_filter = new Gtk.TreeModelFilter (process_list, null);
            proc_filter.set_visible_func (row_visible);
            process_view.set_model (proc_filter);

            main_widget.add (process_view);

            tree_selection = process_view.get_selection ();
            tree_selection.set_mode (Gtk.SelectionMode.SINGLE);
        }

        private bool row_visible (Gtk.TreeModel model, Gtk.TreeIter iter) {
            string proc_name;
            int proc_pid;
            bool found = false;
            if ( _filter_text.length == 0 ) {
                return true;
            }

            model.get( iter, Column.NAME, out proc_name, Column.PID, out proc_pid, -1);

            if (proc_name != null) {
                found = (proc_name.casefold ().index_of (_filter_text) >= 0) || (proc_pid.to_string () == _filter_text);
            }

            Gtk.TreeIter child_iter;
            bool child_found = false;

            if (model.iter_children (out child_iter, iter)) {
                do {
                    child_found = row_visible (model, child_iter);
                } while (model.iter_next (ref child_iter) && !child_found);
            }

            if (child_found && _filter_text.length > 0) {
                process_view.expand_all ();
            }

            return found || child_found;
        }

        public void kill_process () {
            int pid = get_selected_pid ();
            process_list.kill_process (pid);
        }

        public void end_process () {
            int pid = get_selected_pid ();
            process_list.end_process (pid);
        }

        public int get_selected_pid () {
            unowned Gtk.TreeModel temp_model;
            Gtk.TreeIter iter;
            int pid = 0;

            if (tree_selection.get_selected (out temp_model, out iter)) {
                temp_model.@get (iter, Column.PID, out pid, -1);
            }

            return pid;
        }

        // private void init_statusbar (Widgets.Statusbar statusbar) {
        //     var end_process_button = new Gtk.Button.with_label (_("End Process"));
        //     end_process_button.valign = Gtk.Align.CENTER;
        //     end_process_button.margin = 10;
        //     end_process_button.clicked.connect (process_view.end_process);
        //     // end_process_button.tooltip_text = (_("Ctrl+E"));
        //
        //     var kill_process_button = new Gtk.Button.with_label (_("Kill process"));
        //     kill_process_button.valign = Gtk.Align.CENTER;
        //     kill_process_button.margin = 10;
        //     kill_process_button.clicked.connect (process_view.kill_process);
        //     // kill_process_button.tooltip_text = ("Ctrl+E");
        //
        //     statusbar.pack_start (end_process_button);
        //     statusbar.pack_start (kill_process_button);
        // }

        public override void stop_timer () {
            //
        }

        public override void start_timer () {
            //
        }
    }
}
