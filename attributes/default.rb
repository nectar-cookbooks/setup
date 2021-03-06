node.default['setup']['create_users'] = true
node.default['setup']['mount_dir'] = '/data'
node.default['setup']['store_ids'] = [] 
node.default['setup']['nfs_server'] = nil

node.default['setup']['tz'] = nil
node.default['setup']['set_fqdn'] = nil
node.default['setup']['root_email'] = nil
node.default['setup']['mail_relay'] = nil
node.default['setup']['apply_patches'] = 'all'
node.default['setup']['antivirus'] = false

node.default['setup']['clamscan']['args'] = '--quiet -r'  
node.default['setup']['clamscan']['scans'] = 
  {'/' => {
    'action' => 'notify',
    'exclude_dir' => '^/sys|^/proc|^/dev' 
  }
}
node.default['setup']['clamscan']['schedule'] = ['10', '2', '*', '*', '*']

node.normal['clamav']['clamd']['enabled'] = true
node.normal['clamav']['freshclam']['enabled'] = true

node.default['setup']['openstack']['clients'] = false
node.default['setup']['openstack']['rc_path'] = '/etc/openstack/authrc.sh'
node.default['setup']['openstack']['rc_user'] = 'root'
node.default['setup']['openstack']['rc_group'] = 'root'
node.default['setup']['openstack']['auth_url'] =
  'https://keystone.rc.nectar.org.au:5000/v2.0/'
node.default['setup']['openstack']['auth_version'] = 2
node.default['setup']['openstack']['username'] = nil
node.default['setup']['openstack']['password'] = nil
node.default['setup']['openstack']['tenant_name'] = nil 
node.default['setup']['openstack']['tenant_id'] = nil
node.default['setup']['openstack']['try_pip'] = true
node.default['setup']['openstack']['try_distro'] = false
node.default['setup']['openstack']['use_rdo'] = false
node.default['setup']['openstack']['release'] = 'havana'

node.default['setup']['accounts']['generate_sudoers'] = false
node.default['setup']['accounts']['sysadmin_passwordless'] = false
node.default['setup']['accounts']['admin_user'] = nil
node.default['setup']['accounts']['sysadmin_group_sudo'] = false
node.default['setup']['accounts']['sysadmin_group_id'] = nil
node.default['setup']['accounts']['create_users'] = false

# Action values are:
#   - 'ignore' : do nothing
#   - 'override' : set the root password unconditionally
#   - 'default' : set the root password if currently unset
#   - 'disable' : disable the root password
#   - 'require_set' : fail if the root password is unset.
node.default['setup']['root_password']['action'] = 'default'

# Combined with the 'default' action, this causes the root password to
# be disabled if none is currently set.  This is safe and conventient.
node.default['setup']['root_password']['hash'] = 'X'

