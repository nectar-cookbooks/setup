Overview
========

This cookbook contains some recipes for QCloud specific configuration.

Recipe - "setup"
================

The "qcloud::setup" recipe does some simple configuration that typically needs to be done for a new NeCTAR virtual; e.g. setting the timezone.

Attributes:
-----------

* `node['tz']` - The required timezone; e.g. "Australia/Brisbane".  If no timezone is specified, the timezone is not changed.

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

TO-DO LIST
==========

* Turn clunky recipes into clunky resources

