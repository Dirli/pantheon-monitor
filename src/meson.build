conf_data = configuration_data()
conf_data.set_quoted('PROJECT_NAME', meson.project_name())
conf_data.set_quoted('VERSION', meson.project_version())
config_header = configure_file(
    input : 'config.vala.in',
    output : 'config.vala',
    configuration : conf_data
)

executable(
    meson.project_name(),
    'MainWindow.vala',
    'Constants.vala',
    'Enums.vala',
    'Monitor.vala',
    'Structs.vala',
    'Dialogs/About.vala',
    'Dialogs/Preferences.vala',
    'Dialogs/Smart.vala',
    'Objects/DiskDrive.vala',
    'Services/DisksManager.vala',
    'Services/ProcessManager.vala',
    'Services/ResourcesManager.vala',
    'Tools/DrawBody.vala',
    'Tools/DrawCircle.vala',
    'Tools/DrawCpu.vala',
    'Tools/DrawDiskIO.vala',
    'Tools/DrawNetCircle.vala',
    'Tools/DrawRAM.vala',
    'Tools/DrawSmart.vala',
    'Tools/DrawVolume.vala',
    'Utils/Circle.vala',
    'Utils/Format.vala',
    'Views/Disks.vala',
    'Views/Monitor.vala',
    'Views/Processes.vala',
    'Views/ViewWrapper.vala',
    'Widgets/Cpu.vala',
    'Widgets/DiskIO.vala',
    'Widgets/Headerbar.vala',
    'Widgets/Memory.vala',
    'Widgets/Network.vala',
    'Widgets/NetworkPopover.vala',
    'Widgets/ProcessList.vala',
    'Widgets/SmartBox.vala',
    'Widgets/Statusbar.vala',
    'Widgets/VolumesBox.vala',
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

if get_option('indicator')
    shared_library(
        'monitor',
        'Structs.vala',
        'Indicator.vala',
        'Objects/DiskDrive.vala',
        'Widgets/Panel.vala',
        'Widgets/Popover.vala',
        'Services/DisksManager.vala',
        'Services/ResourcesManager.vala',
        'Utils/Format.vala',
        gresource,
        config_header,
        dependencies: [
            gio_dep,
            gobject_dep,
            glib_dep,
            gio_unix_dep,
            gtk_dep,
            gee_dep,
            gtop_dep,
            udisks2_dep,
            wingpanel_dep,
            meson.get_compiler ('c').find_library ('m'),
            meson.get_compiler ('vala').find_library ('posix')
        ],
        vala_args: vala_args,
        install: true,
        install_dir: wingpanel_dep.get_pkgconfig_variable('indicatorsdir'),
    )
endif
