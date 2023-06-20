project (
  'io.elementary.monitor',
  ['vala', 'c'],
  version: '1.1.0'
)

gnome = import ('gnome')
i18n = import ('i18n')

if not get_option ('sensors') and not get_option ('resources') and not get_option ('gui')
  error ('There is nothing to build at all!')
endif

data_dir = join_paths (get_option ('prefix'), get_option ('datadir'))

gio_dep = dependency ('gio-2.0')
gobject_dep = dependency ('gobject-2.0')
glib_dep = dependency ('glib-2.0')
gio_unix_dep = dependency ('gio-unix-2.0')
gtk_dep = dependency ('gtk+-3.0')
gtop_dep = dependency ('libgtop-2.0')
udisks2_dep = dependency ('udisks2')
gee_dep = dependency ('gee-0.8')

add_project_arguments (
  '-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name ()),
  language:'c'
)

c_args = [
  '-DWNCK_I_KNOW_THIS_IS_UNSTABLE'
]

vala_args = ['--vapidir=' + meson.source_root () + '/vapi/']

conf_data = configuration_data ()
conf_data.set_quoted('PROJECT_NAME', meson.project_name ())
conf_data.set_quoted('VERSION', meson.project_version ())
config_header = configure_file (
  input: 'src/config.vala.in',
  output: 'config.vala',
  configuration: conf_data
)

subdir ('data')

if get_option ('resources')
  resources_files = files (
    'src/Structs.vala',
    'src/Objects/DiskDrive.vala',
    'src/Services/DisksManager.vala',
    'src/Services/ResourcesManager.vala',
    'src/Utils/Format.vala',
  )
endif

if get_option ('sensors')
  sensors_files = files (
    'src/Constants.vala',
  )
endif

if get_option ('gui')
  granite_dep = dependency ('granite')
  wnck_dep = dependency ('libwnck-3.0')
  cairo_dep = dependency ('cairo')
  subdir ('src')
endif

if get_option ('sensors') or get_option ('resources')
  wingpanel_dep = dependency('wingpanel')
  subdir ('indicator')
endif

subdir ('po')

meson.add_install_script ('meson/post_install.py')
