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

    public class MonitorApp : Gtk.Application {
        private MainWindow window = null;
        public string[] args;

        construct {
            application_id = "io.elementary.monitor";
        }

        public override void activate () {
            // only have one window
            if (get_windows () == null) {
                window = new MainWindow (this);
                window.show_all ();
            } else {
                window.present ();
            }

            var quit_action = new SimpleAction ("quit", null);
            add_action (quit_action);
            set_accels_for_action ("app.quit", {"<Ctrl>q"});
            quit_action.activate.connect (() => {
                if (window != null) {
                    window.destroy ();
                }
            });
        }

        public static int main (string [] args) {
            var app = new MonitorApp ();
            return app.run (args);
        }
    }
}
