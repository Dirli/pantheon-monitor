/*
 * Copyright (c) 2021-2022 Dirli <litandrej85@gmail.com>
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
    public class Widgets.Smart : Gtk.Box {
        public signal void show_main_page ();

        private Gtk.Label label_val;
        private Gtk.Label firmvare_val;
        private Gtk.Label serial_val;
        private Gtk.Label hours_val;
        private Gtk.Label starts_val;
        private Gtk.Label writes_val;

        private Gtk.TreeView smart_tree_view;

        public Smart () {
            Object (orientation: Gtk.Orientation.VERTICAL,
                    margin_start: 10,
                    margin_end: 10,
                    spacing: 8);
        }

        construct {
            var back_btn = new Gtk.Button.with_label (_("Back"));
            back_btn.get_style_context ().add_class (Granite.STYLE_CLASS_BACK_BUTTON);
            back_btn.clicked.connect (() => {
                clear_cache ();
                show_main_page ();
            });

            label_val = new Gtk.Label (null);
            label_val.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

            firmvare_val = new Gtk.Label (null);
            serial_val = new Gtk.Label (null);

            var smart_head_l = new Gtk.Grid () {
                halign = Gtk.Align.START,
                row_spacing = 8,
                column_spacing = 8,
                hexpand = true,
                margin = 12
            };

            smart_head_l.attach (create_label (_("Firmware:")), 0, 0);
            smart_head_l.attach (firmvare_val, 1, 0);
            smart_head_l.attach (create_label (_("Serial number:")), 0, 1);
            smart_head_l.attach (serial_val, 1, 1);

            writes_val = new Gtk.Label (null);
            hours_val = new Gtk.Label (null);
            starts_val = new Gtk.Label (null);

            var smart_head_r = new Gtk.Grid () {
                halign = Gtk.Align.END,
                row_spacing = 8,
                column_spacing = 8,
                hexpand = true,
                margin = 12
            };

            smart_head_r.attach (create_label (_("Number of starts:")), 0, 0);
            smart_head_r.attach (starts_val, 1, 0);
            smart_head_r.attach (create_label (_("Worked hours:")), 0, 1);
            smart_head_r.attach (hours_val, 1, 1);
            smart_head_r.attach (create_label (_("Total writes:")), 0, 2);
            smart_head_r.attach (writes_val, 1, 2);

            var smart_head  = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
            smart_head.add (smart_head_l);
            smart_head.add (smart_head_r);

            smart_tree_view = create_smart_view ();

            add (back_btn);
            add (label_val);
            add (smart_head);
            add (smart_tree_view);
        }

        public void show_smart (Objects.DiskDrive drive) {
            label_val.set_label (drive.model);
            firmvare_val.set_label (drive.revision);
            serial_val.set_label (drive.serial);

            var smart = drive.get_smart ();
            if (smart != null) {
                smart_tree_view.set_model (smart.smart_store);

                hours_val.set_label (@"$(smart.power_seconds / 3600) h.");
                starts_val.set_label (@"$(smart.power_counts)");
                writes_val.set_label (@"$(smart.total_write != 0 ? Utils.format_bytes (smart.total_write, true) : "--")");
            }
        }

        public void clear_cache () {
            smart_tree_view.set_model (null);

            label_val.set_label ("");
            firmvare_val.set_label ("");
            serial_val.set_label ("");
            hours_val.set_label ("");
            starts_val.set_label ("");
            writes_val.set_label ("");
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

        private Gtk.Label create_label (string label_str) {
            var iter_label = new Gtk.Label (label_str);
            iter_label.halign = Gtk.Align.END;

            return iter_label;
        }
    }
}
