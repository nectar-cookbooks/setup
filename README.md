Overview
========

This cookbook contains some recipes for basic configuration of NeCTAR virtuals

The "setup" recipe and its child recipes have been tested on virtuals running NeCTAR CentOS 6.4 and Ubuntu 13.04 images.  There is an expectation that they will also work on other recent RHEL / CentOS / Scientific Linux and Ubuntu / Debian distros.

The "mount_rdsi_collections" recipe is QCloud / QRISCloud specific.  (I don't have details about how RDSI Collection mounts would be implemented on other Nodes.)

Recipe - "default"
================

The "setup::default" recipe does some simple configuration that typically needs to be done for a new NeCTAR virtual:

* setting the hostname and creating /etc/hosts entries
* setting the timezone and locale,
* configure privileged user accounts and the sudoers file,
* configuring a root mail aliases and relaying,
* configuring automatic patching
* configuring logfile scanning
* configuring anti-virus software and scanning
* installing OpenStack clients and configure credentials

Attributes:
-----------

* `node['setup']['tz']` - The required timezone; e.g. "Australia/Brisbane".  If unset (or 'nil') the timezone is not altered.
* `node['setup']['set_fqdn']` - The required FQDN.  If "*", the virtual's hostname is determined by a reverse DNS lookup of the IP address.  (On a NeCTAR node, that should be a DNS name of the form "vm-xxx-xxx-xxx-xxx.&lt;cell&gt;.nectar.org.au".) If unset (or 'nil') the hostname is not altered.
* `node['setup']['accounts']['generate_sudoers']` - This determines whether the "/etc/sudoers" file will be (re-)generated.  It defaults to false  (See the "accounts" documentation below.)
* `node['setup']['accounts']['create_users']` - This determines whether privileged user accounts will be created from the "users" databag.  It defaults to false  (See the "accounts" documentation below.)
* `node['setup']['root_email']` - An array of email addresses that root email should be redirected to.  If unset (or 'nil') the root email alias is not altered.  If '[]' then the root mail alias (if any) is removed.  NB: redirecting root email to an off-machine address only works if 'mail_relay' is configured.
* `node['setup']['mail_relay']` - If set, configure the system to relay outgoing email via the SMTP host given by the attribute.
* `node['setup']['logwatch']` - If true, run the standard Opscode logwatch recipe.  Refer to https://github.com/opscode-cookbooks/logwatch for details of the attributes.
* `node['setup']['apply_patches']` - This determines whether / how we configure auto-patching.  The standard values are "all", "security" and "none".  The default is "all".  (See the "autopatching" documentation below.)
* `node['setup']['antivirus']` - This determines whether or not we configure ClamAV for virus checking.  If the attribute is truthy, "clamav" recipe (described below) is run.  The default is false.
* `node['setup']['openstack_clients']` - This determines whether or not we install OpenStack clients and credentials.  The default is false.

Note: current scheme for provisioning a NeCTAR node may leave your virtual
with an invalid hostname.  Using 'set_fqdn' with the value "*" fixes this the first time you run chef-client or chef-solo.  However, this might be "too late" for other recipes.  (The simple way to deal with this is to run just the "setup::default" recipe on a newly provisioned node before adding other recipes to the node's run-list.)

Recipe - "mount_rdsi_collections"
=================================

The "setup::mount_rdsi_collections" recipe allows you to NFS mount your RDSI collections on a QCloud virtual.  The recipe configures access to the private network that hosts the NFS server, configures automounting using "autofs" and optionally creates local users and groups to match the default uids used on a RDSI collection filesystem as provisioned by QCIF.

Prerequisites:
--------------

The owner of the collection(s) needs to send an email to "<qcloud-support@uq.edu.au>" requesting that they configure the permissions to allow it / them to be mounted on the virtual.  You can request access for a specific the IP address or addresses explicitly, or you can request that any virtual in a NeCTAR project can mount it.  Given that IP addresses are volatile (and may be reallocated to an unrelated project) the latter is preferable.

Limitations:
------------

* This recipe is limitted to RDSI collections that are stored at the Queensland RDSI node, and virtuals that are hosted in QCloud.  (A private network is used for the NFS mounts.)
* This recipe supports only Ubuntu and RHEL-based Linux.

Attributes:
-----------

The recipe is controlled by the following attributes.

* `node['setup']['mount_dir']` - the directory in which the collections will be automounted.  The defaults to "/data".
* `node['setup']['nfs_server']` - the address of the NFS server.  You should not need to change this.
* `node['setup']['store_ids']` - an array (list) of store ids for RDSI collections.  These are (currently) of the form "Qnn" or "Qnnnn".  Defaults to an empty list ... so you need to override this; e.g. by adding something like the following to your "node.json" file.

```json
  "setup": {
    "store_ids": [ "Q0031" ]
  },

```

* `node['setup']['create_users']` - if true, the recipe will create local users and groups to match the uid/gid numbers you would expect to see on the collection.  Defaults to true.

Recipe - accounts
=================

This recipe does (can do) the following things:

* It can regenerate the "/etc/sudoers" file.
* It can create user accounts for privileged users from the contents of 
  the "users" databag.   The user account details can include SSH keys, 
  encrypted passwords and group membership.

WARNING: a problem in regenerating the "/etc/sudoers" file has the potential
to take away your ability to administer your virtual.  As a 
precaution, we recommend starting a separate SSH session with a root 
shell BEFORE you do a Chef run that will regenerate the "sudoers" file.  
If something goes wrong, you can then use the root shell to restore the 
original "/etc/sudoers" file from "/var/chef/backups".  (It might be 
possible to fix the damage other ways, but it would be a difficult proposition.)

Attributes for "sudoers" regeneration
-------------------------------------

* `node['setup']['accounts']['generate_sudoers']` - This determines whether 
  the "/etc/sudoers" file will be (re-)generated.  It defaults to false.  
  (You noted the WARNING above ... I hope.)
* `node['setup']['accounts']['admin_user']` - This gives the account name for
  the admin user.  If unset, the recipe tries various platform specific 
  defaults to identify the account.  The account must already exist, as this
  recipe won't create it.  
* `node['setup']['accounts']['sysadmin_group_sudo']` - This determines whether
  group-based sudo is enabled.  It defaults to false.  (The group is 'sysadmin'
  on all platforms apart for Mac OSX.)
* `node['setup']['accounts']['sysadmin_group_id']` - If specified, this gives 
  the group id for the 'sysadmin' group.
  on all platforms apart for Mac OSX.)
* `node['setup']['accounts']['passwordless_sudo']` - This determines whether 
  group-based sudo requires a password.  This defaults to false.  (If you 
  set it to true, the relevant accounts need to have a password set for 
  "sudo" to work.)

Notes:

1. The generated "sudoers" file does not contain the distro-specific 
   "Default" settings from your system's original sudoer's file.  If you
   want to add these, you will need to do this via the "sudo" cookbook's
   `node['authorization']['sudo']['sudoers_defaults']` attribute; see
   that cookbook's documentation for examples.
2. The Opscode "sudo" recipe that we use will automatically create
   a group sudo entry for a group called "sysadmin".  The corresponding
   group doesn't exist by default, and setting 'group_sudo' causes the
   group to be created if required.  (But so does 'create_users'!)
3. The 'passwordless_sudo' attribute does not affect the admin user account.
   If sudo access is enabled from the admin account, it is always passwordless.
4. You can disable sudo access for the admin account by setting 'admin_user'
   to "none".  (Do this if you don't want passwordless sudo on the admin
   account ... but be aware that you MUST have group-base sudo working 
   properly or you risk locking yourself out!)
5. The "accounts" recipe implement the sudo access for the admin account
   by creating a file in "/etc/sudoers.d".  However, if you change your mind
   the recipe does not have the ability to remove this file.  You will need
   to remove the file by hand.

Attributes for privileged user creation
---------------------------------------

* `node['setup']['accounts']['create_users']` - This determines whether user 
  accounts will be created from the "users" databag.  It defaults to false.

The default for NeCTAR images is to only allow key-based authentication over
SSH.  This part of the "accounts" recipe supports that, and allows you to
create accounts with pre-installed public keys.  You can also supply password
hashes, but these are only used by "sudo" and other utilities that require
extra authentication.

We use the Opscode "user_manage" resource from the "users" cookbook to 
implement admin user creation for the "sysadmin" group.  That recipe 
will automatically create both the user accounts and the "sysadmin" group
if required.  (Note the relationship between creation of the "sysadmin"
group and group-based sudo access; see above!)

The "data-bags/example-users/" directory contains some examples of the
syntax of a "users" data-bag entry.  Refer to the Opscode "users" cookbook
documentation for more information, including descriptions of how to lock
and remove accounts.

There is one "gotcha" in the behaviour of "user_manage".  You would imagine
that the "groups" attribute behaves like the "groups" attribute on the
"user" resource, and the user is added to all of those groups.  In fact, the
"user_manage" resource only adds the newly created user to the group we are
selecting; i.e. "sysadmin".

Recipe - logwatch
=================

Configures monitoring of system logs using the logwatch utility.  This is based on the Chef Community "logwatch" recipe.

Recipe - mail_relay
===================

Configures the mail relay.  The current implementation is hard-wired to uses Postfix. See above for other details.

Recipe - rootmail
=================

Add or remove a mail alias for the "root" mail address. See above for details.

Recipe - set_hostname
=====================

Set the hostname to a specified FQDN.  See above for details.

Recipe - clamav
===============

Configure the clamav daemon and freshclam to download AV updates.  Then 
create a cron job to perform file system scans.

Attributes
----------

The details of the installation and configuration of clamav and freshclam 
are controlled by attributes defined by the standard "clamav" recipe; see
 
    https://github.com/RoboticCheese/clamav/blob/master/README.md

The following attributes defined by this recipe:

* `node['setup']['clamav']['scans']` - This gives a hash that describes the clamscan runs; see below.  (The default is `{'/' => {'action' => 'notify', 'exclude_dir' => '^/sys|^/dev|^/proc'}}` which says to scan starting from the root directory, exclude certain directories, and (just) report infected files.
* `node['setup']['clamav']['schedule']` - This says when the scanning job should be started.  The value should be an array of 5 strings corresponfing to the first 5 fields of a crontab spec.  (The default is `['10', '2', '*', '*', '*']` which says to start the job at 2:10am every day.)
* `node['setup']['clamav']['args']` - This gives additional arguments to be passed to the `clamscan` command.  (The default is `'--quiet -r'`.)

The 'scans' hash maps from a directory name, to sub-hash containing attributes for scanning that directory.  The following entries in the sub-hash are currently recognized:

* `'action'` says what to do when a virus is encountered.  The possible values are `'notify'`, `'copy'`, `'move'` and `'remove'`.
* `'to_dir'` gives the name of a directory to which infected files are to be moved or copied.
* `'exclude_dir'` gives a regex for directory subtrees to be excluded from scanning.

Recipe - autopatching
=====================

This recipe configures automatic patching, depending on the platform.

Attributes:
----------

* `node['setup']['apply_patches']` - This determines whether / how we configure auto-patching.  The standard values are "all", "security" and "none".  The default is "all".  

Behaviour:
---------

For Ubuntu / Debian, we install and configure the "unattended-upgrades" 
package.  The "apply_patches" value is interpretted as follows:
  * `security` means use the distro's "security" origin
  * `all` means use the distro's "security" origin AND the "updates" and / or 
    "stable" origins.
Note that we only enable / disable recognized origins that are already in the 
`50unattended-updates` provided by the package (or the user).

For RHEL-based distros, we install and configure "yum-cron".  Only the "all"
option is supported at this time.  (Handling security-only updates on SL and
CentOS is tricky because of infrastructure issues.)

For Fedora distros, we install and configure "yum-cron".  This uses a more 
recent version of "yum-cron" than on RHEL 6.x.  
  * `all` means the "yum upgrade"
  * `security` means "yum --security upgrade"
  * other values are available as documented in the "yum-cron.conf" file.

In all cases, we configure the updating to send email to root.  Where 
possible we configure auto-rebooting when needed.

The timing and frequency of auto-updating is distro specific.

Recipe - openstack_clients
==========================

This recipe installs some commonly used OpenStack clients, and optionally
configures an RC file containing credentials for this system's NeCTAR
tenancy.  Currently, we install "nova", "swift" and "keystone".

The intention is to install and configure clients appropriate for the 
current NeCTAR platform.

Attributes
----------

* `node['setup']['openstack_tenant_name']` - The name of the tenancy.
* `node['setup']['openstack_tenant_id']` - The id for the tenancy.
* `node['setup']['openstack_auth_url']` - The URL to use for authenticating. Defaults to "https://keystone.rc.nectar.org.au:5000/v2.0/".
* `node['setup']['openstack_username']` - The NeCTAR username for authenticating.
* `node['setup']['openstack_password']` - The OpenStack password for authenticating.
* `node['setup']['openstack_rc_path']` - Pathname for the credentials script.  Defaults to "/etc/openstack/authrc.sh".
* `node['setup']['openstack_rc_user']` - The owner of the credentials script.  Defaults to 'root'.
* `node['setup']['openstack_rc_group']` - The owner of the credentials script.  Defaults to 'root'.
* `node['setup']['openstack_try_pip']` - If true, try to install clients from Pypy, using pip.  Defaults to true.
* `node['setup']['openstack_try_distro']` - If true, try to install clients from the distro's repository.  Defaults to false.
* `node['setup']['openstack_use_rdo']` - If true, try to use the Fedora "RDO" repository in preference to the distro's.  Defaults to false.

If the 'openstack_tenant_name' attribute is defined and non-empty, then a 
credentials file will be generated containing the details.

The 'openstack_try_pip' and 'openstack_try_distro' attributes allow you to
say where to install clients from.  Installing from both places is somewhat
risky, since you can get interoperability issues.  (For example on Ubuntu
Precise, there is no Swift client in the package repo, and the Pypy version
of the Swift client in incompatible with the Ubuntu precise version of the
Keystone client.) 

The RDO repos are maintained by the RDO community 
(http://openstack.redhat.com/Main_Page) and aim to provide up-to-date 
builds of OpenStack related "stuff" for Fedora and RHEL-based systems.
Unfortunately, they don't provide complete coverage, so the 'openstack_clients'
recipe is designed to try to use an RDO repo if it exists, and fall back to
the standard distro (with a WARN log message).

The credentials script is created with permissions `0550`, and defaults to 
having "root:root" ownership.

TO-DO LIST
==========

* Turn clunky recipes into clunky resources
* Support EC2 authentication in the openstack_clients recipe.
* Support multiple tenants for the usecase where you are installing openstack
  clients on desktop / laptop PC.

