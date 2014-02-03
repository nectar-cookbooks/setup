Change Log for the Setup cookbook
=================================

Version 1.1.2
-------------
 - Workaround to get the clamav recipe to create the service user with the
   platform-appropriate name (#10)

Version 1.1.1
-------------
 - Make the owner/group of the openstack credentials file configurable (#4)

Version 1.1.0
-------------
 - Added the 'accounts' recipe for creating privileged user accounts and
   managing the sudoers file.

Version 1.0.1
-------------
 - Validate and clean up the 'mail_relay' and 'root_email' attributes.

Version 1.0.0
-------------
 - First production release.
