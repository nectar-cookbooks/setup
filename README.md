Overview
========

This cookbook contains some recipes for basic configuration of NeCTAR virtuals

The "setup" recipe and its child recipes have been tested on virtuals running NeCTAR CentOS 6.4 and Ubuntu 13.04 images.  There is an expectation that they will also work on other recent RHEL / CentOS / Scientific Linux and Ubuntu / Debian distros.

The "mount_rdsi_collections" recipe is QCloud / QRISCloud specific.  I don't have details about how RDSI Collection mounts would be implemented on other Nodes.

Recipe - "setup"
================

The "qcloud::setup" recipe does some simple configuration that typically needs to be done for a new NeCTAR virtual:

* setting the hostname and creating /etc/hosts entries
* setting the timezone and locale,
* configuring a root mail aliases and relaying,
* configuring automatic patching
* configuring logfile scanning
* configuring anti-virus software and scanning
* install OpenStack clients and configure credentials

Attributes:
-----------

* `node['qcloud']['tz']` - The required timezone; e.g. "Australia/Brisbane".  If unset (or 'nil') the timezone is not altered.
* `node['qcloud']['set_fqdn']` - The required FQDN.  If "*", the virtual's hostname is determined by a reverse DNS lookup of the IP address.  (On a NeCTAR node, that should give an address of the form "vm-<num>-<num>-<num>-<num>.<cell>.nectar.org.au".) If unset (or 'nil') the hostname is not altered.
* `node['qcloud']['root_email']` - An array of email addresses that root email should be redirected to.  If unset (or 'nil') the root email alias is not altered.  If '[]' then the root mail alias (if any) is removed.
* `node['qcloud']['mail_relay'] - If set, configure the system to relay outgoing email via the the host given by the attribute.
* `node['qcloud']['logwatch']` - If true, run the standard Opscode logwatch recipe.  Refer to https://github.com/opscode-cookbooks/logwatch for details of the attributes.
* `node['qcloud']['apply_patches']` - This determines whether / how we configure auto-patching.  The standard values are "all", "security" and "none".  The default is "all".  (See the "autopatching" documentation below.)
* `node['qcloud']['antivirus']` - This determines whether or not we configure ClamAV for virus checking.  If the attribute is truthy, "clamav" recipe (described below) is run.  The default is false.
* `node['qcloud']['openstack_clients']` - This determines whether or not we install OpenStack clients and credentials.  The default is false.

Note: some "funky things" happen when a NeCTAR node is provisioned which may leave your virtual in a state where DHCP says the hostname is the name of the NeCTAR project ... which doesn't resolve as a DNS name.

Recipe - "mount_rdsi_collections"
=================================

The "qcloud::mount_rdsi_collections" recipe allows you to NFS mount your RDSI collections on a QCloud virtual.  The recipe configures access to the private network that hosts the NFS server, configures automounting using "autofs" and optionally creates local users and groups to match the default uids used on a RDSI collection filesystem as provisioned by QCIF.

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

* `node['qcloud']['mount_dir']` - the directory in which the collections will be automounted.  The defaults to "/data".

* `node['qcloud']['nfs_server']` - the address of the NFS server.  You should not need to change this.

* `node['qcloud']['store_ids']` - an array (list) of store ids for RDSI collections.  These are (currently) of the form "Qnn" or "Qnnnn".  Defaults to an empty list ... so you need to override this; e.g. by adding something like the following to your "node.json" file.

```json
  "qcloud": {
    "store_ids": [ "Q0031" ]
  },

```

* `node['qcloud']['create_users']` - if true, the recipe will create local users and groups to match the uid/gid numbers you would expect to see on the collection.  Defaults to true.

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

* `node['qcloud']['clamav']['scans']` - This gives a hash that describes the clamscan runs; see below.  (The default is `{'/' => {'action' => 'notify', 'exclude_dir' => '^/sys|^/dev|^/proc'}}` which says to scan starting from the root directory, exclude certain directories, and (just) report infected files.
* `node['qcloud']['clamav']['schedule']` - This says when the scanning job should be started.  The value should be an array of 5 strings corresponfing to the first 5 fields of a crontab spec.  (The default is `['10', '2', '*', '*', '*']` which says to start the job at 2:10am every day.)
* `node['qcloud']['clamav']['args']` - This gives additional arguments to be passed to the `clamscan` command.  (The default is `'--quiet -r'`.)

The 'scans' hash maps from a directory name, to sub-hash containing attributes for scanning that directory.  The following entries in the sub-hash are currently recognized:

* `'action'` says what to do when a virus is encountered.  The possible values are `'notify'`, `'copy'`, `'move'` and `'remove'`.
* `'to_dir'` gives the name of a directory to which infected files are to be moved or copied.
* `'exclude_dir'` gives a regex for directory subtrees to be excluded from scanning.

Recipe - autopatching
=====================

This recipe configures automatic patching, depending on the platform.

Attributes:
----------

* `node['qcloud']['apply_patches']` - This determines whether / how we configure auto-patching.  The standard values are "all", "security" and "none".  The default is "all".  

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

* `node['qcloud']['openstack_tenant_name']` - The name of the tenancy.
* `node['qcloud']['openstack_tenant_id']` - The id for the tenancy.
* `node['qcloud']['openstack_auth_url']` - The URL to use for authenticating. Defaults to "https://keystone.rc.nectar.org.au:5000/v2.0/".
* `node['qcloud']['openstack_username']` - The NeCTAR username for authenticating.
* `node['qcloud']['openstack_password']` - The OpenStack password for authenticating.
* `node['qcloud']['openstack_rc_path']` - Pathname for the credentials script.  Defaults to "/etc/openstack/authrc.sh".

If the 'openstack_tenant_name' attribute is defined and non-empty, then a 
credentials file will be generated containing the details.


TO-DO LIST
==========

* Turn clunky recipes into clunky resources
* Support EC2 authentication in the openstack_clients recipe.
* Support multiple tenants for the usecase where you are installing openstack
  clients on desktop / laptop PC.
