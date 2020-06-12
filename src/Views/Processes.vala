namespace Monitor {
    public class Views.Processes : Views.ViewWrapper {
        private uint t_id = 0;

        private Gtk.Popover menu_popover;

        private Services.ProcessManager process_manager;
        private Widgets.Process process_view;
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

            tree_selection = process_view.get_selection ();
            tree_selection.set_mode (Gtk.SelectionMode.SINGLE);

            create_popover_menu ();

            process_view.button_press_event.connect ((event) => {
                if (event.window != process_view.get_bin_window ()) {
                    return base.button_press_event (event);
                }

                if (event.button == Gdk.BUTTON_SECONDARY) {
                    on_button_press (event);
                }

                return base.button_press_event (event);
            });

            proc_filter = new Gtk.TreeModelFilter (process_manager.process_store, null);
            proc_filter.set_visible_func (row_visible);
            process_view.set_model (proc_filter);

            main_widget.add (process_view);
        }

        private bool on_button_press (Gdk.EventButton event) {
            int cell_x, cell_y;
            Gtk.TreePath? cursor_path;
            Gtk.TreeViewColumn? cursor_column;
            process_view.get_path_at_pos ((int) event.x, (int) event.y, out cursor_path, out cursor_column, out cell_x, out cell_y);

            unowned Gtk.TreeModel mod;
            var paths_list = tree_selection.get_selected_rows (out mod);

            bool contains_cursor_path = false;
            paths_list.@foreach ((iter_path) => {
                if (cursor_path != null && iter_path.compare (cursor_path) == 0) {
                    contains_cursor_path = true;
                }
            });

            if (!contains_cursor_path && cursor_path != null) {
                tree_selection.unselect_all ();
                tree_selection.select_path (cursor_path);
            }

            Gdk.Rectangle rect = {};

            rect.x = (int) event.x;
            rect.y = (int) event.y;
            rect.height = 1;
            rect.width = 1;

            menu_popover.set_pointing_to (rect);

            menu_popover.popup ();
            return true;
        }

        private void create_popover_menu () {
            var end_button = new Gtk.Button ();
            end_button.set_action_name (Constants.ACTION_PREFIX + Constants.ACTION_END_PROC);
            end_button.add (
                new Granite.AccelLabel.from_action_name (
                    _("End Process"),
                    end_button.action_name
                )
            );
            end_button.clicked.connect (() => {
                menu_popover.popdown ();
            });

            var kill_button = new Gtk.Button ();
            kill_button.set_action_name (Constants.ACTION_PREFIX + Constants.ACTION_KILL_PROC);
            kill_button.add (
                new Granite.AccelLabel.from_action_name (
                    _("Kill process"),
                    kill_button.action_name
                )
            );
            kill_button.clicked.connect (() => {
                menu_popover.popdown ();
            });

            var menu_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
            menu_box.add (end_button);
            menu_box.add (kill_button);

            menu_popover = new Gtk.Popover (process_view);
            menu_popover.add (menu_box);
            menu_popover.show_all ();

            menu_popover.popdown ();
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
            if (pid > 0) {
                process_manager.stop_process (pid, Posix.Signal.KILL);
            }
        }

        public void end_process () {
            int pid = get_selected_pid ();
            if (pid > 0) {
                process_manager.stop_process (pid, Posix.Signal.TERM);
            }
        }

        public int get_selected_pid () {
            unowned Gtk.TreeModel temp_model;
            Gtk.TreeIter iter;

            if (tree_selection.get_selected (out temp_model, out iter)) {
                int pid = 0;
                temp_model.@get (iter, Enums.Column.PID, out pid, -1);
                return pid;
            }

            return -1;
        }

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
