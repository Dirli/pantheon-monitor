indicator_sensors = gnome.compile_resources (
  'in-sensors',
  join_paths (meson.project_name () + '.sensors.gresource.xml'),
  source_dir: 'data',
  c_name: 'insen'
)

shared_module (
  'sensors',
  'Indicator.vala',
  'HWMonitor.vala',
  'Popover.vala',
  'Utils.vala',
  sensors_files,
  config_header,
  indicator_sensors,
  dependencies: [
    glib_dep,
    gobject_dep,
    gtk_dep,
    gee_dep,
    wingpanel_dep
  ],
  install: true,
  install_dir : wingpanel_dep.get_pkgconfig_variable ('indicatorsdir')
)

install_data (meson.project_name () + '.sensors.gschema.xml',
  install_dir: join_paths (data_dir, 'glib-2.0/schemas')
)
