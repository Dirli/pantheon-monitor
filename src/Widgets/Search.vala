/*
 * Copyright (c) 2018 Dirli <litandrej85@gmail.com>
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

    public class Widgets.Search : Gtk.SearchEntry {
        public signal void find_result (bool state);
        public Gtk.TreeModelFilter filter_model { get; private set; }
        private Widgets.Process process_view;

        public Search (Widgets.Process process_view, Gtk.TreeModel model) {
            this.process_view = process_view;
            placeholder_text = _("Search Process");
            set_tooltip_text (_("Type Process Name or PID"));
            filter_model = new Gtk.TreeModelFilter (model, null);
            connect_signal ();
            filter_model.set_visible_func(filter_func);
            process_view.set_model (filter_model);

            var sort_model = new Gtk.TreeModelSort.with_model (filter_model);
            process_view.set_model (sort_model);
        }

        private void connect_signal () {
            search_changed.connect (() => {
                // collapse tree only when search is focused and changed
                if (is_focus) {
                    process_view.collapse_all ();
                }

                filter_model.refilter ();

                // if there's no search result, make kill_process_button insensitive to avoid the app crashes
                find_result (filter_model.iter_n_children (null) != 0);

                // focus on child row to avoid the app crashes by clicking "Kill/End Process" buttons in headerbar
                process_view.focus_on_child_row ();
                grab_focus ();

                if (text != "") {
                    insert_at_cursor ("");
                }
            });
        }

        private bool filter_func (Gtk.TreeModel model, Gtk.TreeIter iter) {
            string name_haystack;
            int pid_haystack;
            bool found = false;
            var needle = this.text;
            if ( needle.length == 0 ) {
                return true;
            }

            model.get( iter, Column.NAME, out name_haystack, -1 );
            model.get( iter, Column.PID, out pid_haystack, -1 );

            // sometimes name_haystack is null
            if (name_haystack != null) {
                bool name_found = name_haystack.casefold().contains(needle.casefold()) || false;
                bool pid_found = pid_haystack.to_string().casefold().contains(needle.casefold()) || false;
                found = name_found || pid_found;
            }


            Gtk.TreeIter child_iter;
            bool child_found = false;

            if (model.iter_children (out child_iter, iter)) {
                do {
                    child_found = filter_func (model, child_iter);
                } while (model.iter_next (ref child_iter) && !child_found);
            }

            if (child_found && needle.length > 0) {
                process_view.expand_all ();
            }

            return found || child_found;
        }

        // reset filter, grab focus and insert the character
        public void activate_entry (string search_text = "") {
            text = "";
            // this.grab_focus ();
            search_changed ();
            insert_at_cursor (search_text);
        }
    }
}
