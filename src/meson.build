executable(
    meson.project_name(),
    'MainWindow.vala',
    'Constants.vala',
    'Enums.vala',
    'Monitor.vala',
    'Structs.vala',
    'Dialogs/About.vala',
    'Dialogs/Preferences.vala',
    'Objects/DiskDrive.vala',
    'Services/DisksManager.vala',
    'Services/ProcessManager.vala',
    'Services/ResourcesManager.vala',
    'Tools/DrawBody.vala',
    'Tools/DrawCircle.vala',
    'Tools/DrawCpu.vala',
    'Tools/DrawDiskIO.vala',
    'Tools/DrawNetCircle.vala',
    'Utils/Circle.vala',
    'Utils/Format.vala',
    'Views/Disks.vala',
    'Views/Monitor.vala',
    'Views/Processes.vala',
    'Views/ViewWrapper.vala',
    'Widgets/Cpu.vala',
    'Widgets/Device.vala',
    'Widgets/DiskIO.vala',
    'Widgets/Headerbar.vala',
    'Widgets/Memory.vala',
    'Widgets/Network.vala',
    'Widgets/NetworkPopover.vala',
    'Widgets/ProcessList.vala',
    'Widgets/Smart.vala',
    'Widgets/Statusbar.vala',
    'Widgets/VolumeBox.vala',
    gresource,
    config_header,
    c_args: c_args,
    vala_args: vala_args,
    dependencies: [
        gio_dep,
        gobject_dep,
        glib_dep,
        gtk_dep,
        granite_dep,
        gtop_dep,
        wnck_dep,
        cairo_dep,
        udisks2_dep,
        meson.get_compiler ('c').find_library ('m'),
        meson.get_compiler ('vala').find_library ('posix')
    ],
    install : true
)
