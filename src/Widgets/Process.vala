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
    public class Widgets.Process : Gtk.TreeView {
        private Gtk.TreeViewColumn name_column;
        private Gtk.TreeViewColumn cpu_column;
        private Gtk.TreeViewColumn memory_column;
        private Gtk.TreeViewColumn pid_column;
        private Regex? regex;

        const string NO_DATA = "\u2014";

        public Process () {
            regex = /(?i:^.*\.(xpm|png)$)/;

            name_column = new Gtk.TreeViewColumn ();
            name_column.title = _("Process Name");
            name_column.expand = true;
            name_column.min_width = 250;
            name_column.set_sort_column_id (Column.NAME);

            var icon_cell = new Gtk.CellRendererPixbuf ();
            name_column.pack_start (icon_cell, false);

            // name_column.add_attribute (icon_cell, "icon_name", Column.ICON);
            name_column.set_cell_data_func (icon_cell, icon_cell_layout);
            var name_cell = new Gtk.CellRendererText ();
            name_cell.ellipsize = Pango.EllipsizeMode.END;
            name_cell.set_fixed_height_from_font (1);
            name_column.pack_start (name_cell, false);
            name_column.add_attribute (name_cell, "text", Column.NAME);
            insert_column (name_column, -1);

            // setup cpu column
            var cpu_cell = new Gtk.CellRendererText ();
            cpu_cell.xalign = 0.5f;

            cpu_column = new Gtk.TreeViewColumn.with_attributes (_("CPU"), cpu_cell);
            cpu_column.expand = false;
            cpu_column.set_cell_data_func (cpu_cell, cpu_usage_cell_layout);
            cpu_column.alignment = 0.5f;
            cpu_column.set_sort_column_id (Column.CPU);
            insert_column (cpu_column, -1);

            // setup memory column
            var memory_cell = new Gtk.CellRendererText ();
            memory_cell.xalign = 0.5f;

            memory_column = new Gtk.TreeViewColumn.with_attributes (_("Memory"), memory_cell);
            memory_column.expand = false;
            memory_column.set_cell_data_func (memory_cell, memory_usage_cell_layout);
            memory_column.alignment = 0.5f;
            memory_column.set_sort_column_id (Column.MEMORY);
            insert_column (memory_column, -1);

            // setup PID column
            var pid_cell = new Gtk.CellRendererText ();
            pid_cell.xalign = 0.5f;
            pid_column = new Gtk.TreeViewColumn.with_attributes (_("PID"), pid_cell);
            pid_column.set_cell_data_func (pid_cell, pid_cell_layout);
            pid_column.expand = false;
            pid_column.alignment = 0.5f;
            pid_column.set_sort_column_id (Column.PID);

            //Gtk-WARNING **: 13:50:29.054: Refusing to add the same cell renderer to a GtkCellAreaBox twice
            /* pid_column.pack_start (pid_cell, false); */

            pid_column.add_attribute (pid_cell, "text", Column.PID);
            insert_column (pid_column, -1);

            // resize all of the columns
            columns_autosize ();
        }

        public void icon_cell_layout (Gtk.CellLayout cell_layout, Gtk.CellRenderer icon_cell, Gtk.TreeModel model, Gtk.TreeIter iter) {
            Value icon_name;
            model.get_value (iter, Column.ICON, out icon_name);
            if (regex.match ((string) icon_name)) {
                try {
                    string path = ((string) icon_name);
                    Gdk.Pixbuf icon = new Gdk.Pixbuf.from_file_at_size (path, 16, -1);
                    (icon_cell as Gtk.CellRendererPixbuf).pixbuf = icon;
                } catch (Error e) {
                    warning (e.message);
                    (icon_cell as Gtk.CellRendererPixbuf).icon_name = (string) icon_name;
                }
            } else {
                (icon_cell as Gtk.CellRendererPixbuf).icon_name = (string) icon_name;
            }
        }

        public void cpu_usage_cell_layout (Gtk.CellLayout cell_layout, Gtk.CellRenderer cell, Gtk.TreeModel model, Gtk.TreeIter iter) {
            // grab the value that was store in the model and convert it down to a usable format
            Value cpu_usage_value;
            model.get_value (iter, Column.CPU, out cpu_usage_value);
            double cpu_usage = cpu_usage_value.get_double ();

            // format the double into a string
            if (cpu_usage < 0.0) {
                (cell as Gtk.CellRendererText).text = NO_DATA;
            } else {
                (cell as Gtk.CellRendererText).text = "%.0f%%".printf (cpu_usage * 100.0);
            }
        }

        public void memory_usage_cell_layout (Gtk.CellLayout cell_layout, Gtk.CellRenderer cell, Gtk.TreeModel model, Gtk.TreeIter iter) {
            // grab the value that was store in the model and convert it down to a usable format
            Value memory_usage_value;
            model.get_value (iter, Column.MEMORY, out memory_usage_value);
            int64 memory_usage = memory_usage_value.get_int64 ();
            double memory_usage_double = (double) memory_usage;
            string units = "KiB";

            // convert to MiB if needed
            if (memory_usage_double > 1024.0) {
                memory_usage_double /= 1024.0;
                units = "MiB";
            }

            // convert to GiB if needed
            if (memory_usage_double > 1024.0) {
                memory_usage_double /= 1024.0;
                units = "GiB";
            }

            // format the double into a string
            if (memory_usage == 0) {
                (cell as Gtk.CellRendererText).text = NO_DATA;
            } else {
                (cell as Gtk.CellRendererText).text = "%.1f %s".printf (memory_usage_double, units);
            }
        }

        private void pid_cell_layout (Gtk.CellLayout cell_layout, Gtk.CellRenderer cell, Gtk.TreeModel model, Gtk.TreeIter iter) {
            Value pid_value;
            model.get_value (iter, Column.PID, out pid_value);
            int pid = pid_value.get_int ();
            // format the double into a string
            if (pid == 0) {
                (cell as Gtk.CellRendererText).text = NO_DATA;
            }
        }

        public void focus_on_first_row () {
            Gtk.TreePath tree_path = new Gtk.TreePath.from_indices (0);
            this.set_cursor (tree_path, null, false);
            grab_focus ();
        }

        public void focus_on_child_row () {
            Gtk.TreePath tree_path = new Gtk.TreePath.from_indices (0, 0);
            this.set_cursor (tree_path, null, false);
            grab_focus ();
        }

        // How about GtkTreeSelection ?

        public void expanded () {
            Gtk.TreeModel model;
            var selection = this.get_selection ().get_selected_rows(out model).nth_data(0);
		    this.expand_row (selection, false);
        }

        public void collapse () {
            Gtk.TreeModel model;
            var selection = this.get_selection ().get_selected_rows(out model).nth_data(0);
		    this.collapse_row (selection);
        }
    }
}
