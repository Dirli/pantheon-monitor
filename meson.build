project (
  'io.elementary.monitor',
  ['vala', 'c'],
  version: '1.0.0'
)

gnome = import ('gnome')
i18n = import ('i18n')

data_dir = join_paths (get_option ('prefix'), get_option ('datadir'))

gio_dep = dependency ('gio-2.0')
gobject_dep = dependency ('gobject-2.0')
glib_dep = dependency ('glib-2.0')
gio_unix_dep = dependency ('gio-unix-2.0')
gtk_dep = dependency ('gtk+-3.0')
granite_dep = dependency ('granite')
gtop_dep = dependency ('libgtop-2.0')
wnck_dep = dependency ('libwnck-3.0')
cairo_dep = dependency ('cairo')
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

subdir ('data')
subdir ('src')

if get_option ('sensors') or get_option ('resources')
  wingpanel_dep = dependency('wingpanel')
endif

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

subdir ('indicator')
subdir ('po')

meson.add_install_script ('meson/post_install.py')
