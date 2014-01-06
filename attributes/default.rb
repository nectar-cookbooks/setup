node.default['qcloud']['create_users'] = true
node.default['qcloud']['mount_dir'] = '/data'
node.default['qcloud']['store_ids'] = [] 
node.default['qcloud']['nfs_server'] = '10.255.100.50'

node.default['qcloud']['tz'] = nil
node.default['qcloud']['set_fqdn'] = nil
node.default['qcloud']['root_email'] = nil
node.default['qcloud']['mail_relay'] = nil
node.default['qcloud']['apply_patches'] = 'all'
node.default['qcloud']['openstack_clients'] = false
node.default['qcloud']['antivirus'] = false

node.default['qcloud']['clamscan']['args'] = '--quiet -r'  
node.default['qcloud']['clamscan']['scans'] = 
  {'/' => {
    'action' => 'notify',
    'exclude_dir' => '^/sys|^/proc|^/dev' 
  }
}
node.default['qcloud']['clamscan']['schedule'] = ['10', '2', '*', '*', '*']

node.normal['clamav']['clamd']['enabled'] = true
node.normal['clamav']['freshclam']['enabled'] = true

node.default['qcloud']['openstack_rc_path'] = '/etc/openstack/authrc.sh'
node.default['qcloud']['openstack_auth_url'] =
  'https://keystone.rc.nectar.org.au:5000/v2.0/'

node.normal['chef-server']['version'] = 'latest'
