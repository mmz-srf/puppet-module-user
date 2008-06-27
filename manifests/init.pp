#
# user module
#
# Copyright (C) 2007 admin@immerda.ch
# Copyright 2008, Puzzle ITC
# Marcel Härry haerry+puppet(at)puzzle.ch
# Simon Josi josi+puppet(at)puzzle.ch
#
# This program is free software; you can redistribute 
# it and/or modify it under the terms of the GNU 
# General Public License version 3 as published by 
# the Free Software Foundation.
#
#modules_dir { "user": }

class user {}

define user::define_user(
	$name,
	$name_comment = '',
	$uid,
	$gid,
	$home_dir = '',
	$ssh_key = '',
	$shell = ''
	){

	$real_home_dir = $home_dir ? {
		'' => "/home/$name",
		default => $home_dir
	}

	$real_name_comment = $name_comment ? {
		'' => $name,
		default => $name_comment,	
	}

	$real_shell = $shell ? {
		'' =>  $operatingsystem ? {
                       	  openbsd => "/usr/local/bin/bash",
                          default => "/bin/bash",
                	},
		default => $shell,
	}

	user { $name:
		allowdupe => false,
                comment => "$real_name_comment",
                ensure => present,
                gid => $gid,
		home => $real_home_dir,
		shell => $real_shell,
		uid => $uid,
	}

	case $name {
		root: {}
		default: {
			group { $name:
 				allowdupe => false,
				ensure => present,
				gid => $gid
			}
		}
	}

	file {$real_home_dir:
  			ensure => directory,
			mode => 0750, owner => $name, group => $gid;
	}

	case $ssh_key {
		'': {}
		default: {
			sshd::deploy_auth_key{"user_sshkey_${name}": source => $ssh_key, user => $name, target_dir => '', group => $name}
		}
	}
}
