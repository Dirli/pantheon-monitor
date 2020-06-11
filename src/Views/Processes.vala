namespace Monitor {
    public class Views.Processes : Views.ViewWrapper {
        private uint t_id = 0;

        private Services.ProcessManager process_manager;
        private Widgets.Process process_view;
        // private Models.GenericModel process_list;
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
            process_manager = new Services.ProcessManager ();

            process_view = new Widgets.Process ();

            proc_filter = new Gtk.TreeModelFilter (process_manager.process_store, null);
            proc_filter.set_visible_func (row_visible);
            process_view.set_model (proc_filter);
            // process_view.set_model (process_manager.process_store);

            main_widget.add (process_view);

            tree_selection = process_view.get_selection ();
            tree_selection.set_mode (Gtk.SelectionMode.SINGLE);
        }

        // Gtk.TreeIter first_iter;
        // if (list_store.get_iter_first (out first_iter)) {
        //     var first_path = list_store.get_path (first_iter);
        //     if (first_path != null) {
        //         list_view.set_cursor (first_path, null, false);
        //     }
        // }

        // public void focus_on_first_row () {
        //     Gtk.TreePath tree_path = new Gtk.TreePath.from_indices (0);
        //     this.set_cursor (tree_path, null, false);
        //     grab_focus ();
        // }

        private bool row_visible (Gtk.TreeModel model, Gtk.TreeIter iter) {
            if ( _filter_text.length == 0 ) {
                return true;
            }

            string proc_name;
            int proc_pid;
            bool found = false;

            model.get( iter, Enums.Column.NAME, out proc_name, Enums.Column.PID, out proc_pid, -1);

            if (proc_name != null) {
                found = (proc_name.casefold ().index_of (_filter_text) >= 0) || (proc_pid.to_string () == _filter_text);
            }

            return found;
        }

        public void kill_process () {
            int pid = get_selected_pid ();
            process_manager.stop_process (pid, Posix.Signal.KILL);
        }

        public void end_process () {
            int pid = get_selected_pid ();
            process_manager.stop_process (pid, Posix.Signal.TERM);
        }

        public int get_selected_pid () {
            unowned Gtk.TreeModel temp_model;
            Gtk.TreeIter iter;
            int pid = 0;

            if (tree_selection.get_selected (out temp_model, out iter)) {
                temp_model.@get (iter, Enums.Column.PID, out pid, -1);
            }

            return pid;
        }

        // private void init_statusbar (Widgets.Statusbar statusbar) {
        // Posix.Signal.TERM
        //     var end_process_button = new Gtk.Button.with_label (_("End Process"));
        //     end_process_button.valign = Gtk.Align.CENTER;
        //     end_process_button.margin = 10;
        //     end_process_button.clicked.connect (process_view.end_process);
        //     // end_process_button.tooltip_text = (_("Ctrl+E"));
        //
        // Posix.Signal.KILL
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
            if (t_id > 0) {
                GLib.Source.remove (t_id);
                t_id = 0;
            }
        }

        public override void start_timer () {
            if (t_id == 0) {
                process_manager.update_processes ();

                t_id = GLib.Timeout.add_seconds (1, () => {
                    process_manager.update_processes ();
                    return true;
                });
            }
        }
    }
}
