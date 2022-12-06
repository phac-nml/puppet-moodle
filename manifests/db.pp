define moodle::db (
  Boolean $create_db,
  Boolean $create_db_user,
  String $dbname,
  String $dbhost,
  String $dbuser,
  String $dbpass,
) {
  ## Set up DB using puppetlabs-mysql defined type
  if $create_db {
    mysql_database { "${dbhost}/${dbname}":
      name    => $dbname,
      charset => 'utf8mb4',
      collate => 'utf8mb4_unicode_ci',
    }
  }
  if $create_db_user {
    mysql_user { "${dbuser}@${dbhost}":
      password_hash => mysql_password($dbpass),
    }
    mysql_grant { "${dbuser}@${dbhost}/${dbname}.*":
      table      => "${dbname}.*",
      user       => "${dbuser}@${dbhost}",
      privileges => ['ALL'],
    }
  }
}
