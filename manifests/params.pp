#
class moodle::params {
  $install_dir      = '/opt/moodle'
  $install_provider = 'git' # 'git' or 'http'
  $download_base    = $install_provider ? {
    'http' => 'https://download.moodle.org/download.php/direct/stable30',
    'git'  => 'https://github.com/moodle/moodle.git'
  }
  $moodle_version   = '3.6'
  $default_lang     = 'en'
  $wwwrooturl       = "http://${::fqdn}"
  $dataroot         = '/opt/moodledata'
  $create_db        = true
  $create_db_user   = true
  $dbtype           = 'mysqli'
  $dbhost           = 'localhost'
  $dbname           = 'moodle'
  $dbuser           = 'root'
  $dbpass           = ''
  $dbport           = 3306
  $dbsocket         = 1
  $prefix           = 'mdl_'
  $fullname         = 'moodle site'
  $shortname        = 'moodle site'
  $summary          = 'summary of moodle site'
  $adminuser        = 'admin'
  $adminpass        = 'adminpass'
  $adminemail       = 'admin@example.com'

  case $::osfamily {
    'debian': {
      $www_owner = 'www-data'
      $www_group = 'www-data'
    }
    default: {
      $www_owner = 'root'
      $www_group = 'root'
    }
  }
}
