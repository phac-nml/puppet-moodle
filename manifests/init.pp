# Class: moodle
# ===========================
#
# Full description of class moodle here.
#
# Authors
# -------
#
# Alan Petersen <alan@alanpetersen.net>
#
# Copyright
# ---------
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class moodle (
  $install_dir      = $moodle::params::install_dir,
  $install_provider = $moodle::params::install_provider,
  $download_base    = $moodle::params::download_base,
  $moodle_version   = $moodle::params::moodle_version,
  $default_lang     = $moodle::params::default_lang,
  $wwwrooturl       = $moodle::params::wwwrooturl,
  $www_owner        = $moodle::params::www_owner,
  $www_group        = $moodle::params::www_group,
  $dataroot         = $moodle::params::dataroot,
  $create_db        = $moodle::params::create_db,
  $create_db_user   = $moodle::params::create_db_user,
  $dbtype           = $moodle::params::dbtype,
  $dbhost           = $moodle::params::dbhost,
  $dbname           = $moodle::params::dbname,
  $dbuser           = $moodle::params::dbuser,
  $dbpass           = $moodle::params::dbpass,
  $dbport           = $moodle::params::dbport,
  $dbsocket         = $moodle::params::dbsocket,
  $prefix           = $moodle::params::prefix,
  $fullname         = $moodle::params::fullname,
  $shortname        = $moodle::params::shortname,
  $summary          = $moodle::params::summary,
  $adminuser        = $moodle::params::adminuser,
  $adminpass        = $moodle::params::adminpass,
  $adminemail       = $moodle::params::adminemail,
  Hash $plugins     = {},
) inherits moodle::params {

  # construct the download URL
  $download_url = $install_provider ? {
    'http' => "${download_base}/moodle-${moodle_version}.tgz",
    'git'  => "${download_base}",
  }

  moodle::instance { $install_dir:
    install_dir      => $install_dir,
    install_provider => $install_provider,
    download_url     => $download_url,
    moodle_version   => $moodle_version,
    default_lang     => $default_lang,
    wwwrooturl       => $wwwrooturl,
    www_owner        => $www_owner,
    www_group        => $www_group,
    dataroot         => $dataroot,
    create_db        => $create_db,
    create_db_user   => $create_db_user,
    dbtype           => $dbtype,
    dbhost           => $dbhost,
    dbname           => $dbname,
    dbuser           => $dbuser,
    dbpass           => $dbpass,
    dbport           => $dbport,
    dbsocket         => $dbsocket,
    prefix           => $prefix,
    fullname         => $fullname,
    shortname        => $shortname,
    summary          => $summary,
    adminuser        => $adminuser,
    adminpass        => $adminpass,
    adminemail       => $adminemail,
    plugins          => $plugins,
  }

}
