icon_sizes = ['16', '24', '32', '48', '64']


icon_dir = join_paths (data_dir, 'icons', 'hicolor')

foreach i : icon_sizes
    install_data (
        join_paths ('icons', i, meson.project_name () + '.svg'),
        install_dir: join_paths (icon_dir, i + 'x' + i, 'apps')
    )
endforeach

install_data ('io.elementary.monitor.desktop',
    install_dir: join_paths (data_dir, 'applications')
)

if get_option ('indicator')
    install_data ('io.elementary.monitor.gschema.xml',
        install_dir: join_paths (data_dir, 'glib-2.0/schemas')
    )
endif

gresource = gnome.compile_resources (
    'as-resources',
    join_paths (meson.project_name () + '.gresource.xml'),
    source_dir: 'data',
    c_name: 'as'
)
