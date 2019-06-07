#
define moodle::app (
  $install_dir,
  $install_provider,
  $download_url,
  $moodle_version,
  $default_lang,
  $wwwrooturl,
  $www_owner,
  $www_group,
  $dataroot,
  $dbtype,
  $dbhost,
  $dbname,
  $dbuser,
  $dbpass,
  $dbport,
  $dbsocket,
  $prefix,
  $fullname,
  $shortname,
  $summary,
  $adminuser,
  $adminpass,
  $adminemail,
  Hash $plugins      = {},
) {

  $install_dir_clean = regsubst($install_dir, /\//, '_', 'G')

  if !($install_dir =~ /\/moodle$/) {
    fail("${install_dir} is not valid... install_dir must end with /moodle")
  }

  # manage the moodle data directory
  file { $dataroot:
    ensure  => directory,
    owner   => $www_owner,
    group   => $www_group,
    mode    => '0755',
    seltype => 'httpd_sys_rw_content_t',
  }

  case $install_provider {
    'http': {
      fail('Moodle http install not supported at this time.')
    # # manage the staging class
    # class { 'staging':
    #   path  => '/var/staging',
    # }
    #
    # # download the staged file
    # staging::file { 'moodle.tgz':
    #   source => $download_url,
    # }
    #
    # # ensure that the directory
    # if !defined(File[$install_dir]) {
    #   file { $install_dir:
    #     ensure => directory,
    #     owner  => $www_owner,
    #     group  => $www_group,
    #     mode   => '0755',
    #   }
    # }
    #
    # # get the parent directory... the moodle distribution
    # # gets extracted to a 'moodle' directory
    # $install_parent = getparent($install_dir)
    #
    # staging::extract { 'moodle.tgz':
    #   target  => $install_parent,
    #   user    => $www_owner,
    #   group   => $www_group,
    #   creates => "${install_dir}/install.php",
    #   require => [Staging::File['moodle.tgz'],File[$install_dir, $dataroot]],
    # }
    }
    'git': {
      $stripped_version = $moodle_version.split('\.')[0,2].join()
      $git_branch = "MOODLE_${stripped_version}_STABLE"
      git::repo { "moodle-${install_dir}":
        target => $install_dir,
        source => $download_url,
        user   => $www_owner,
        group  => $www_group,
        mode   => '0755',
        args   => "-b ${git_branch} --depth 2",
      }
      concat { "git-exclude-${install_dir}":
        path           => "${install_dir}/.git/info/exclude",
        ensure_newline => true,
        owner          => $www_owner,
        group          => $www_group,
        mode           => '0644',
        warn           => "# This file is managed by Puppet. DO NOT EDIT.\n",
      }
      concat::fragment { "git-exclude-${install_dir}-${title}":
        target  => "git-exclude-${install_dir}",
        content => "\n# Directories of installed plugins",
        order   => '09',
      }
      $plugin_defaults = {
        'install_provider'   => 'git',
        'moodle_install_dir' => $install_dir,
        'plugin_version'     => $moodle_version,
        'www_owner'          => $www_owner,
        'www_group'          => $www_group,
      }
      $plugins.each |$plugname, $plugparams| {
        moodle::plugin { "moodle-${install_dir}-${plugname}":
          name => $plugname,
          tag  => ["moodle-${install_dir_clean}"],
          *    => $plugin_defaults + $plugparams,
        }
      }
    }
  }

  # run the moodle cli installer in non-interactive mode. the parameters for the installer
  # are configured in the template install_cmd.erb (to make variable substitution easier)
  exec { 'run-installer':  # This name should be unique per instance.
    command   => template('moodle/install_cmd.erb'),
    user      => $www_owner,
    group     => $www_group,
    logoutput => true,
    path      => '/usr/bin:/usr/local/bin',
    creates   => "${install_dir}/config.php",
  }

  cron { "moodle-${install_dir}":
    command     => '/usr/bin/php /var/www/moodle/admin/cli/cron.php',
    user        => $www_owner,
  }

  Git::Repo["moodle-${install_dir}"]                         ->
  Moodle::Plugin <| tag == "moodle-${install_dir_clean}" |>  ->
  Exec['run-installer']                                      ->
  Cron["moodle-${install_dir}"]
}
