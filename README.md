# group_allow

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with group_allow](#setup)
    * [What group_allow affects](#what-group_allow-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with group_allow](#beginning-with-group_allow)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module's purpose in life is to take the members of a group defined
in an LDAP directory and ensure that  they are allowed to login to an AIX
server.

This is to support AIX in LDAP environments where the directory service
does not allow AIX to be fully managed from the directory.

This module will gather the list of users in a group, gather a list of users
from /etc/security/user and then compare the two.

Any users in the group list which are not on the system already will be added
if ensure is set to 'present.'  The users home directory will be created
if it does not already exist, /etc/security/.profile will be copied to it,
permission set to the user and the mode set to 750.

## Setup

Add this to your puppet installations modules directory and sync your agents.

### What group_allow affects **OPTIONAL**

This module will gather the list of users in a group, gather a list of users
from /etc/security/user and then compare the two.

Any users in the group list which are not on the system already will be added
if ensure is set to 'present.'  The users home directory will be created
if it does not already exist, /etc/security/.profile will be copied to it,
permission set to the user and the mode set to 750.

### Beginning with group_allow

It will only add users who are not already allowed to login.

Valid parameters are:
ensure:   It is ensurable, but it does not remove users.  

## Usage

Example:

    group_allow { 'appusers':
      ensure => present
    }

## Reference

This module was built to explicitly use the AIX commands lsgroup, lsuser and chsec.

## Limitations

This module can only add users.  Even though it is ensurable, it won't do anything
if you set ensure => absent.  The problem here is that a user can be a member of 
more than one group and/or a user may have been added as a one-off.  This module 
just simplifies and automates getting users onto the server.

## Development

This was written specifically to support AIX with functionality that Windows and
even Linux enjoy.  I don't konw if there is a need for this anywhere else, but if 
there is feel free to embrace and extend.

