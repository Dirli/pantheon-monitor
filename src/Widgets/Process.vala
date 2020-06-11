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
        const string NO_DATA = "\u2014";

        public Process () {
            var name_cell = new Gtk.CellRendererText ();
            name_cell.ellipsize = Pango.EllipsizeMode.END;
            name_cell.set_fixed_height_from_font (1);

            var name_column = new Gtk.TreeViewColumn ();
            name_column.title = _("Process Name");
            name_column.expand = true;
            name_column.min_width = 250;
            name_column.set_sort_column_id (Enums.Column.NAME);
            name_column.pack_start (name_cell, false);
            name_column.add_attribute (name_cell, "text", Enums.Column.NAME);

            insert_column (name_column, -1);

            insert_column (create_numeric_column (Enums.Column.CPU, _("CPU")), -1);
            insert_column (create_numeric_column (Enums.Column.MEMORY, _("Memory")), -1);
            insert_column (create_numeric_column (Enums.Column.PID, _("PID")), -1);

            columns_autosize ();
        }

        private Gtk.TreeViewColumn create_numeric_column (int sort_column_id, string title) {
            var renderer_cell = new Gtk.CellRendererText ();
            renderer_cell.xalign = 0.5f;

            var numeric_column = new Gtk.TreeViewColumn ();
            numeric_column.title = title;
            numeric_column.expand = false;
            numeric_column.set_cell_data_func (renderer_cell, numeric_cell_layout);
            numeric_column.alignment = 0.5f;
            numeric_column.set_sort_column_id (sort_column_id);
            numeric_column.pack_start (renderer_cell, true);

            return numeric_column;
        }

        public void numeric_cell_layout (Gtk.CellLayout layout, Gtk.CellRenderer cell, Gtk.TreeModel model, Gtk.TreeIter iter) {
            var tvc = layout as Gtk.TreeViewColumn;
            var cell_text = cell as Gtk.CellRendererText;
            if (tvc == null || cell_text == null) {
                return;
            }

            var cid = tvc.sort_column_id;
            if (cid < 0) {
                return;
            }

            GLib.Value usage_value;
            model.get_value (iter, cid, out usage_value);

            string layout_text = NO_DATA;
            switch (cid) {
                case Enums.Column.PID:
                    int pid = usage_value.get_int ();
                    if (pid > 0) {
                        layout_text = @"$pid";
                    }
                    break;
                case Enums.Column.CPU:
                    double cpu_usage = usage_value.get_double ();
                    if (cpu_usage >= 0.0) {
                        layout_text = "%.1f%%".printf (cpu_usage);
                    }
                    break;
                case Enums.Column.MEMORY:
                    var memory_usage = usage_value.get_uint64 ();
                    layout_text = Utils.format_bytes (memory_usage, true);
                    break;
            }

            cell_text.text = layout_text;
        }
    }
}
