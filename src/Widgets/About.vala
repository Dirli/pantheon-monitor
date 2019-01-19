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
    public class Widgets.About : Granite.GtkPatch.AboutDialog {
        public About () {
            modal = true;
            destroy_with_parent = true;
            authors = {
                "Stanisław Dac <stanislawdac@gmail.com>",
                "Paulo Galardi <lainsce@airmail.cc>",
                "Kenet Mauricio Acuña Lago <kma.kenneth@live.com>",
                "Dirli <litandrej85@gmail.com>"
            };
            comments = _("System monitor for ElementaryOS");
            license_type = Gtk.License.GPL_3_0;
            program_name = "Pantheon-monitor";
            translator_credits = "(ru) Dirli <litandrej85@gmail.com>";
            website = "https://github.com/Dirli/pantheon-monitor";
            website_label = _("website");
            logo_icon_name = "utilities-system-monitor";
            response.connect (() => {destroy ();});
            show_all ();
        }
    }
}
