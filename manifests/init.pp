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
	$name_comment = 'absent',
	$uid = 'absent',
	$gid = 'absent',
	$home_dir = 'absent',
	$ssh_key = 'absent',
	$shell = 'absent'
	){

	$real_home_dir = $home_dir ? {
		'absent' => "/home/$name",
		default => $home_dir
	}

	$real_name_comment = $name_comment ? {
		'absent' => $name,
		default => $name_comment,	
	}

	$real_shell = $shell ? {
		'absent' =>  $operatingsystem ? {
                       	  openbsd => "/usr/local/bin/bash",
                          default => "/bin/bash",
                	},
		default => $shell,
	}

	user { $name:
		allowdupe => false,
        comment => "$real_name_comment",
        ensure => present,
		home => $real_home_dir,
		shell => $real_shell,
	}

    case $uid {
        'absent': { notice("Not defining a uid for user $name") }
        default: {
            User[$name]{
                uid => $uid,
            }
        }
    }

    case $gid {
        'absent': { notice("Not defining a gid for user $name") }
        default: {
            User[$name]{
                gid => $gid,
            }
        }
    }

	case $name {
		root: {}
		default: {
			group { $name:
 				allowdupe => false,
				ensure => present,
			}
            case $gid {
                'absent': { notice("not defining a gid for group $name") }
                default: {
                    Group[$name]{
                        gid => $gid,
                    }
                }
		    }
	    }
    }

	file {$real_home_dir:
  			ensure => directory,
			owner => $name, mode => 0750;
	}

    case $gid {
        'absent': { notice("no gid defined for user $name") }
        default: { 
            File[$real_home_dir]{
                group => $gid,
            }
        }
    }

	case $ssh_key {
		'absent': { notice("no ssh key define for user $name") }
		default: {
			sshd::deploy_auth_key{"user_sshkey_${name}": source => $ssh_key, user => $name, target_dir => '', group => $name}
		}
	}
}
