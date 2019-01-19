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

using Math;

namespace Monitor {
    public class Widgets.Network : Services.Circle {
        public int net_speed { get; set; default = 0;}

        public Network (string net_name) {
            _net_speed = 0;
            layout_name = create_pango_layout (net_name);
            layout_name.set_font_description (description_name);
        }

        public override string get_signature () {
            return Utils.format_net_speed (net_speed);
        }
    }
}
