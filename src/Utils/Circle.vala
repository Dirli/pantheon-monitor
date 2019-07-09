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
    public class Utils.Circle : GLib.Object {
        public float get_rgb_gtk (int color) {
            return (float) color / 255;
        }

        public double get_radians (double grades) {
            return grades / 180 * Math.PI;
        }

        public float get_circuference_x (float radius, double angle){
            return (float) (radius * cos (get_radians (angle)));
        }

        public float get_circuference_y (float radius, double angle){
            return (float) (radius * sin (get_radians (angle)));
        }

        public void get_point_circuference (float radius, double angle, float x_center, double y_center, out float x, out float y) {
            x = 0;
            y = 0;

            var j = get_circuference_x (radius, angle);
            var k = get_circuference_y (radius, angle);

            if (angle == 0) {
                x = (float) x_center + radius;
                y = (float) y_center;
            } else if (angle == 90){
                x = (float) x_center;
                y = (float) y_center - radius;
            } else if (angle == 180){
                x = (float) x_center - radius;
                y = (float) y_center;
            } else if (angle == 270){
                x = (float) x_center;
                y = (float) y_center + radius;
            } else if (angle == 360){
                x = (float) x_center + radius;
                y = (float) y_center;
            } else {
                if (angle > 0 && angle < 90){
                    x = (float) x_center + j.abs ();
                    y = (float) y_center - k.abs ();
                } else if (angle > 90 && angle < 180){
                    x = (float) x_center - j.abs ();
                    y = (float) y_center - k.abs ();
                }  else if (angle > 180 && angle < 270){
                    x = (float) x_center - j.abs ();
                    y = (float) y_center + k.abs ();
                } else if (angle > 270 && angle < 360){
                    x = (float) x_center + j.abs ();
                    y = (float) y_center + k.abs ();
                }
            }
        }
    }
}
