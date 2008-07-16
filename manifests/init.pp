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
	$homedir = 'absent',
    $managehome = 'true',
	$sshkey = 'absent',
	$shell = 'absent'
	){

	$real_homedir = $homedir ? {
		'absent' => "/home/$name",
		default => $homedir
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
		home => $real_homedir,
        managehome => $managehome,
		shell => $real_shell,
	}

    case $uid {
        'absent': { info("Not defining a uid for user $name") }
        default: {
            User[$name]{
                uid => $uid,
            }
        }
    }

    case $gid {
        'absent': { info("Not defining a gid for user $name") }
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
                require => User[$name],
			}
            case $gid {
                'absent': { info("not defining a gid for group $name") }
                default: {
                    Group[$name]{
                        gid => $gid,
                    }
                }
		    }
	    }
    }

    case $gid {
        'absent': { info("no gid defined for user $name") }
        default: { 
            File[$real_homedir]{
                group => $gid,
            }
        }
    }

	case $sshkey {
		'absent': { info("no ssh key define for user $name") }
		default: {
			sshd::deploy_auth_key{"user_sshkey_${name}": source => $sshkey, user => $name, target_dir => '', group => $name}
		}
	}
}
