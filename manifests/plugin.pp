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
  Optional[String] $install_cmd               = undef,
  Optional[Hash] $install_exec                = undef,
) {

  $plugin_install_dir = $install_subdir ? {
    /^\//     => $install_subdir,
    default   => "${moodle_install_dir}/${install_subdir}",
  }

  case $install_provider {
    'http': {
      fail('Moodle plugin http install not supported at this time.')
      # Implement this after implementing same in app.pp
    }
    'git': {
      case $version_type {
        'moodle':         {
          $stripped_version = $plugin_version.split('\.')[0,2].join()
          $git_branch = $plugin_version ? {
            /^\d+\.\d+$/  => "MOODLE_${stripped_version}_STABLE",
            /^\d\d+$/     => "MOODLE_${stripped_version}_STABLE",
            default       => $plugin_version,
          }
        }
        'tag', 'branch':  {
          $git_branch = $plugin_version
        }
      }
      if false {
        git::repo { "moodle-${moodle_install_dir}-${name}":
          target => $plugin_install_dir,
          source => $download_url,
          user   => $www_owner,
          group  => $www_group,
          mode   => '0755',
          args   => "-b '${git_branch}' --depth 2",
        }
      } else {
        vcsrepo { "moodle-${moodle_install_dir}-${name}":
          ensure   => 'latest',
          provider => 'git',
          path     => $plugin_install_dir,
          source   => $download_url,
          revision => $git_branch,
          depth    => 1,
          owner    => $www_owner,
          group    => $www_group,
        }
      }
    }
  }

  # Exclude plugin from main moodle git
  if $moodle::install_provider == 'git' and $plugin_install_dir =~ "^${moodle_install_dir}" {
    concat::fragment { "git-exclude-${moodle_install_dir}-${name}":
      target  => "git-exclude-${moodle_install_dir}",
      content => "/${install_subdir}/",
      order   => '10',
    }
  }

  if $install_cmd {
    exec { "moodle-plugin-${name}-install":
      command     => $install_cmd,
      cwd         => $plugin_install_dir,
      refreshonly => true,
    }
    if defined(Git::Repo["moodle-${moodle_install_dir}-${name}"]) {
      Git::Repo["moodle-${moodle_install_dir}-${name}"] ~> Exec["moodle-plugin-${name}-install"]
    }
    if defined(Vcsrepo["moodle-${moodle_install_dir}-${name}"]) {
      Vcsrepo["moodle-${moodle_install_dir}-${name}"] ~> Exec["moodle-plugin-${name}-install"]
    }
  }
  if $install_exec {
    exec { "moodle-plugin-${name}-exec":
      # Default to working directory = install directory; force to refresh only.
      * => {cwd => $plugin_install_dir,} + $install_exec + {refreshonly => true,},
    }
    if defined(Git::Repo["moodle-${moodle_install_dir}-${name}"]) {
      Git::Repo["moodle-${moodle_install_dir}-${name}"] ~> Exec["moodle-plugin-${name}-exec"]
    }
    if defined(Vcsrepo["moodle-${moodle_install_dir}-${name}"]) {
      Vcsrepo["moodle-${moodle_install_dir}-${name}"] ~> Exec["moodle-plugin-${name}-exec"]
    }
  }

}
