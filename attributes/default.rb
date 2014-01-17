node.default['setup']['create_users'] = true
node.default['setup']['mount_dir'] = '/data'
node.default['setup']['store_ids'] = [] 
node.default['setup']['nfs_server'] = '10.255.100.50'

node.default['setup']['tz'] = nil
node.default['setup']['set_fqdn'] = nil
node.default['setup']['root_email'] = nil
node.default['setup']['mail_relay'] = nil
node.default['setup']['apply_patches'] = 'all'
node.default['setup']['openstack_clients'] = false
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

node.default['setup']['openstack_rc_path'] = '/etc/openstack/authrc.sh'
node.default['setup']['openstack_auth_url'] =
  'https://keystone.rc.nectar.org.au:5000/v2.0/'

node.default['setup']['accounts']['generate_sudoers'] = false
node.default['setup']['accounts']['sysadmin_passwordless'] = false
node.default['setup']['accounts']['admin_user'] = nil
node.default['setup']['accounts']['sysadmin_group_sudo'] = false
node.default['setup']['accounts']['sysadmin_group_id'] = nil
node.default['setup']['accounts']['create_users'] = false
