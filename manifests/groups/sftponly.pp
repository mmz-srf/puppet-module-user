class user::groups::sftp_only {
  group{'sftponly':
    ensure => present,
    gid => 10000,
  }
}
