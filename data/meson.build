install_data('io.elementary.monitor.desktop',
    install_dir: join_paths(get_option('datadir'), 'applications')
)

install_data('io.elementary.monitor.gschema.xml',
    install_dir: join_paths(get_option('datadir'), 'glib-2.0/schemas')
)

gresource = gnome.compile_resources(
    'as-resources',
    join_paths(meson.project_name() + '.gresource.xml'),
    source_dir: 'data',
    c_name: 'as'
)
