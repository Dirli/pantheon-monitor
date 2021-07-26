/*
 * Copyright (c) 2021 Dirli <litandrej85@gmail.com>
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
    public class Dialogs.Smart : Gtk.Dialog {
        public Objects.DiskDrive drive { get; construct set; }
        public string did { get; construct set; }

        public Smart (Objects.DiskDrive d) {
            Object (modal: true,
                    deletable: false,
                    resizable: false,
                    destroy_with_parent: true,
                    drive: d);
        }

        construct {
            set_default_response (Gtk.ResponseType.CANCEL);

            title = drive.model;

            var smart_grid = new Gtk.Grid ();
            smart_grid.halign = Gtk.Align.START;
            smart_grid.row_spacing = 8;
            smart_grid.column_spacing = 8;
            smart_grid.margin = 12;

            var top = 0;

            add_new_str (ref smart_grid, _("Firmware:"), drive.revision, top++);
            add_new_str (ref smart_grid, _("Serial number:"), drive.serial, top++);

            var smart_layout = new Gtk.Box (Gtk.Orientation.VERTICAL, 8);
            smart_layout.add (smart_grid);

            var smart = drive.get_smart ();
            if (smart != null) {
                var smart_store = drive.get_smart_store ();

                var smart_tree_view = create_smart_view ();
                smart_tree_view.set_model (smart.smart_store);

                smart_layout.add (smart_tree_view);
            }

            Gtk.Box content = this.get_content_area () as Gtk.Box;
            content.valign = Gtk.Align.START;
            content.border_width = 6;
            content.add (smart_layout);

            add_button (_("Close"), Gtk.ResponseType.CANCEL);

            response.connect (() => {destroy ();});
        }

        private Gtk.TreeView create_smart_view () {
            var tree_view = new Gtk.TreeView ();
            tree_view.headers_visible = true;
            tree_view.activate_on_single_click = false;
            tree_view.margin = 12;
            tree_view.can_focus = false;

            tree_view.insert_column (create_column (Enums.Attr.ID, _("ID")), -1);
            tree_view.insert_column (create_column (Enums.Attr.NAME, _("Name")), -1);
            tree_view.insert_column (create_column (Enums.Attr.CURRENT, _("Current")), -1);
            tree_view.insert_column (create_column (Enums.Attr.WORST, _("Worst")), -1);
            tree_view.insert_column (create_column (Enums.Attr.THRESHOLD, _("Threshold")), -1);
            tree_view.insert_column (create_column (Enums.Attr.PRETTY, _("Pretty")), -1);

            tree_view.columns_autosize ();
            tree_view.set_headers_clickable (false);

            return tree_view;
        }

        private Gtk.TreeViewColumn create_column (Enums.Attr sort_column_id, string title) {
            var renderer_cell = new Gtk.CellRendererText ();
            renderer_cell.xalign = sort_column_id == Enums.Attr.NAME ? 0.0f : 1.0f;

            var tv_column = new Gtk.TreeViewColumn ();
            tv_column.title = title;
            tv_column.expand = false;
            tv_column.set_cell_data_func (renderer_cell, cell_layout);
            tv_column.set_sort_column_id (sort_column_id);
            tv_column.pack_start (renderer_cell, true);

            return tv_column;
        }

        public void cell_layout (Gtk.CellLayout layout, Gtk.CellRenderer cell, Gtk.TreeModel model, Gtk.TreeIter iter) {
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

            string layout_text = "";
            switch (cid) {
                case Enums.Attr.CURRENT:
                case Enums.Attr.WORST:
                case Enums.Attr.THRESHOLD:
                    layout_text = @"$(usage_value.get_int ())";
                    break;
                case Enums.Attr.ID:
                    layout_text = @"$(usage_value.get_uchar ())";
                    break;
                case Enums.Attr.NAME:
                    layout_text = usage_value.get_string ();
                    break;
                case Enums.Attr.PRETTY:
                    layout_text = @"$(usage_value.get_uint64 ())";
                    break;

            }

            cell_text.text = layout_text;
        }

        private void add_new_str (ref Gtk.Grid w, string label_str, string value_str, int str_top, int str_left = 0) {
            var iter_label = new Gtk.Label (label_str);
            iter_label.halign = Gtk.Align.END;

            var iter_value = new Gtk.Label (value_str);
            iter_value.halign = Gtk.Align.START;

            w.attach (iter_label, str_left++, str_top);
            w.attach (iter_value, str_left, str_top);
        }
    }
}
