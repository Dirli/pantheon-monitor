# Pantheon-monitor
Manage processes, monitor of system resources and drives.

<p align="left">
    <a href="https://paypal.me/Dirli85">
        <img src="https://img.shields.io/badge/Donate-PayPal-green.svg">
    </a>
</p>

----

<img src="data/screenshot1.png" title="Process monitor" width="600"> </img>

#### Indicator
![Screenshot](data/screenshot4.png)

<img src="data/screenshot2.png" title="Resource monitor" width="420"> </img>
<img src="data/screenshot3.png" title="Disks monitor" width="420"> </img>

Special thanks Alexey Varfolomeev (@varlesh) who designed icons.

## Building and Installation

### You'll need the following dependencies to build:
* valac
* libgtk-3-dev
* libgranite-dev
* libwnck-3-dev
* libgee-0.8-dev
* libgtop2-dev
* libcairo2-dev
* libwingpanel-dev
* libudisks2-dev
* meson

### How to build
    meson build --prefix=/usr
    ninja -C build
    sudo ninja -C build install
