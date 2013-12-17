node.default['qcloud']['create_users'] = true
node.default['qcloud']['mount_dir'] = '/data'
node.default['qcloud']['store_ids'] = [] 
node.default['qcloud']['nfs_server'] = '10.255.100.50'

node.default['qcloud']['tz'] = nil
node.default['qcloud']['set_fqdn'] = nil
node.default['qcloud']['root_email'] = nil
node.default['qcloud']['mail_relay'] = nil
node.default['qcloud']['apply_patches'] = 'all'
node.default['qcloud']['antivirus'] = false

node.default['qcloud']['clamscan']['args'] = '--quiet -r'  
node.default['qcloud']['clamscan']['scans'] = 
  {'/' => {
    'action' => 'notify',
    'exclude_dir' => '^/sys|^/proc|^/dev' 
  }
}
node.default['qcloud']['clamscan']['schedule'] = ['10', '2', '*', '*', '*']
