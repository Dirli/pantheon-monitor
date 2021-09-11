indicator_resource = gnome.compile_resources (
    'in-resources',
    join_paths (meson.project_name () + '.resources.gresource.xml'),
    source_dir: 'data',
    c_name: 'inres'
)

shared_library (
  'resources',
  'Indicator.vala',
  'Panel.vala',
  'Popover.vala',
  resources_files,
  gresource,
  indicator_resource,
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
  install_dir: wingpanel_dep.get_pkgconfig_variable ('indicatorsdir'),
)

install_data (meson.project_name () + '.resources.gschema.xml',
  install_dir: join_paths (data_dir, 'glib-2.0/schemas')
)
