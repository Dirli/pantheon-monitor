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
    public class Services.SettingsManager : GLib.Settings {

        private static Services.SettingsManager? _settings = null;
        public static unowned Settings get_default () {
            if (_settings == null) {
                _settings = new SettingsManager ();
            }
            return _settings;
        }

        private SettingsManager ()  {
            Object (schema_id: "io.elementary.monitor");
        }
    }
}
