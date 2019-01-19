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
    public enum Column {
        ICON,
        NAME,
        CPU,
        MEMORY,
        PID,
    }

    // can't use TreeIter in HashMap for some reason, wrap it in a class
    public class ApplicationProcessRow {
        public Gtk.TreeIter iter;
        public ApplicationProcessRow (Gtk.TreeIter iter) { this.iter = iter; }
    }

    public class ModelHelper {
        private Gtk.TreeStore model;

        public ModelHelper (Gtk.TreeStore model) { this.model = model; }

        public void set_static_columns (Gtk.TreeIter iter, string icon, string name, int pid=0) {
            model.set (iter,
                Column.NAME, name,
                Column.ICON, icon,
                Column.PID, pid,
                -1);
        }

        public void set_dynamic_columns (Gtk.TreeIter iter, double cpu, uint64 mem) {
            model.set (iter,
                Column.CPU, cpu,
                Column.MEMORY, mem,
                -1);
        }
    }
}
