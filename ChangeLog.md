Change Log for the Setup cookbook
=================================

Version 1.1.4
-------------
 - Support 'pip' installation when clients are not in the package repo (#16)
 - Include 'cinder' client in list of OpenStack clients installed (#17)

Version 1.1.3
-------------
 - Include 'glance' client in list of OpenStack clients installed (#12)
 - Disable locale tweaking on Fedora as workaround for issue #13

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
