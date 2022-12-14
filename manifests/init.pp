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
  String $install_dir      = $moodle::params::install_dir,
  String $install_provider = $moodle::params::install_provider,
  String $download_base    = $moodle::params::download_base,
  String $moodle_version   = $moodle::params::moodle_version,
  String $default_lang     = $moodle::params::default_lang,
  String $wwwrooturl       = $moodle::params::wwwrooturl,
  String $www_owner        = $moodle::params::www_owner,
  String $www_group        = $moodle::params::www_group,
  String $dataroot         = $moodle::params::dataroot,
  Boolean $create_db        = $moodle::params::create_db,
  Boolean $create_db_user   = $moodle::params::create_db_user,
  String $dbtype           = $moodle::params::dbtype,
  String $dbhost           = $moodle::params::dbhost,
  String $dbname           = $moodle::params::dbname,
  String $dbuser           = $moodle::params::dbuser,
  String $dbpass           = $moodle::params::dbpass,
  Integer $dbport           = $moodle::params::dbport,
  Integer $dbsocket         = $moodle::params::dbsocket,
  String $prefix           = $moodle::params::prefix,
  String $fullname         = $moodle::params::fullname,
  String $shortname        = $moodle::params::shortname,
  String $summary          = $moodle::params::summary,
  String $adminuser        = $moodle::params::adminuser,
  String $adminpass        = $moodle::params::adminpass,
  String $adminemail       = $moodle::params::adminemail,
  Hash $plugins     = {},
) inherits moodle::params {
  # construct the download URL
  $download_url = $install_provider ? {
    'http' => "${download_base}/moodle-${moodle_version}.tgz",
    'git'  => $download_base,
    'github'  => $download_base,
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
