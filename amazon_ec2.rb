require 'chef/provisioning/aws_driver'
require 'retryable'

with_driver 'aws::us-east-1'

aws_key_pair 'ref-key-pair-eni'

aws_dhcp_options 'ref-dhcp-options-eni'

with_chef_server "http://localhost:8889"

aws_vpc 'ref-vpc-eni' do
  cidr_block '10.0.0.0/24'
  internet_gateway true
  main_routes '0.0.0.0/0' => :internet_gateway
  dhcp_options 'ref-dhcp-options-eni'
end

aws_security_group 'ref-sg1-eni' do
  vpc 'ref-vpc-eni'
  inbound_rules '0.0.0.0/0' => [22,80]
end

aws_security_group 'ref-sg2-eni' do
  vpc 'ref-vpc-eni'
  inbound_rules '0.0.0.0/0' => 22
end

aws_route_table 'ref-public-eni' do
  vpc 'ref-vpc-eni'
  routes '0.0.0.0/0' => :internet_gateway
end

aws_subnet 'ref-subnet-eni' do
  vpc 'ref-vpc-eni'
  map_public_ip_on_launch true
  route_table 'ref-public-eni'
end

with_machine_options :bootstrap_options => {
    image_id: "ami-d05e75b8",
    instance_type: "t2.micro",
    :subnet_id => 'ref-subnet-eni',
    key_name: "ref-key-pair-eni",
    :security_group_ids => ['ref-sg1-eni']
  }

machine_batch do
  action :setup
  machines 'web1'
end

machine 'web1' do
  chef_server(:chef_server_url => 'http://localhost:8889')
  role 'tornado-webserver'
  chef_environment 'production'
  retries 4
  converge true
end

ruby_block "print out public IP" do
  block do
   web1 = search(:node, "name:web1").first
   puts "\n\n============================\n"
   puts "\e[1mTornado server available at \e[33mhttp://#{web1['ec2']['public_ipv4']}"
   puts "\n============================"
 end
end

