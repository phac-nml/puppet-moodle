#
define moodle::plugin (
  $plugin                                     = $name,
  String $install_subdir,
  $moodle_install_dir                         = $moodle::install_dir,
  $install_provider                           = $moodle::install_provider,
  String $download_url,
  $plugin_version                             = $moodle::moodle_version,
  Enum['moodle','branch','tag'] $version_type = 'moodle',
  $www_owner                                  = $moodle::www_owner,
  $www_group                                  = $moodle::www_group,
) {

  $plugin_install_dir = "${moodle_install_dir}/${install_subdir}"

  case $install_provider {
    'http': {
      fail('Moodle plugin http install not supported at this time.')
      # Implement this after implementing same in app.pp
    }
    'git': {
      case $version_type {
        'moodle':         {
          $stripped_version = $plugin_version.split('\.')[0,2].join()
          $git_branch = "MOODLE_${stripped_version}_STABLE"
        }
        'tag', 'branch':  {
          $git_branch = $plugin_version
        }
      }
      git::repo { "moodle-${moodle_install_dir}-${name}":
        target => $plugin_install_dir,
        source => $download_url,
        user   => $www_owner,
        group  => $www_group,
        mode   => '0755',
        args   => "-b '${git_branch}' --depth 2",
      }
    }
  }

  # Exclude plugin from main moodle git
  if $moodle::install_provider == 'git' { # Better would be to use the parent moodle::app resource's install_provider
      concat::fragment { "git-exclude-${moodle_install_dir}-${name}":
        target  => "git-exclude-${moodle_install_dir}",
        content => "/${install_subdir}/",
        order   => '10',
      }
  }

}
