/*
 * Copyright (c) 2018-2021 Dirli <litandrej85@gmail.com>
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

namespace Monitor.Enums {
    public enum Column {
        NAME,
        CPU,
        MEMORY,
        PID,
        USER,
    }

    public enum ViewIO {
        ALL,
        WRITE,
        READ,
    }

    public enum ViewCPU {
        DIAGRAM,
        GRAPH
    }

    public enum Attr {
        ID,
        NAME,
        CURRENT,
        WORST,
        THRESHOLD,
        PRETTY,
    }








    public enum PresetColors {
        RED,
        LIME,
        BLUE,
        YELLOW,
        GREEN,
        FUCHSIA,
        OLIVE,
        ORANGE,
        PURPLE,
        GOLD,
        BROWN,
        GREY,
        DARKBLUE,
        BLUEGREEN,
        CYANOGEN,
        N_PRESETS;

        public Gdk.RGBA get_rgba () {
            switch (this) {
                case PresetColors.RED:
                    return {red: 1.0, green: 0, blue: 0, alpha: 0.8};
                case PresetColors.LIME:
                    return {red: 0, green: 1.0, blue: 0, alpha: 0.8};
                case PresetColors.BLUE:
                    return {red: 0, green: 0, blue: 1.0, alpha: 0.8};
                case PresetColors.YELLOW:
                    return {red: 1.0, green: 1.0, blue: 0, alpha: 0.8};
                case PresetColors.GREEN:
                    return {red: 0, green: 0.5, blue: 0, alpha: 0.8};
                case PresetColors.FUCHSIA:
                    return {red: 1.0, green: 0, blue: 1.0, alpha: 0.8};
                case PresetColors.OLIVE:
                    return {red: 0.5, green: 0.5, blue: 0, alpha: 0.8};
                case PresetColors.ORANGE:
                    return {red: 1.0, green: 0.65, blue: 0, alpha: 0.8};
                case PresetColors.PURPLE:
                    return {red: 0.5, green: 0, blue: 0.5, alpha: 0.8};
                case PresetColors.GOLD:
                    return {red: 1.0, green: 0.84, blue: 0, alpha: 0.8};
                case PresetColors.GREY:
                    return {red: 0.5, green: 0.5, blue: 0.5, alpha: 0.8};
                case PresetColors.DARKBLUE:
                    return {red: 0, green: 0, blue: 0.5, alpha: 0.8};
                case PresetColors.BROWN:
                    return {red: 0.59, green: 0.29, blue: 0, alpha: 0.8};
                case PresetColors.BLUEGREEN:
                    return {red: 0, green: 0.5, blue: 0.5, alpha: 0.8};
                case PresetColors.CYANOGEN:
                    return {red: 0, green: 1.0, blue: 1.0, alpha: 0.8};
                default:
                    return {red: 0.75, green: 0.75, blue: 0.75, alpha: 0.8};
            }
        }
    }

}
