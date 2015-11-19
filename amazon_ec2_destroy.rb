require 'chef/provisioning/aws_driver'
require 'retryable'

with_driver 'aws::us-east-1'

aws_key_pair 'ref-key-pair-eni'

aws_network_interface 'ref-eni-1' do
  action :destroy
end

machine_batch do
  action :destroy
  machines 'web1'
end

aws_subnet 'ref-subnet-eni' do
  action :destroy
end

aws_route_table 'ref-public-eni' do
  action :destroy
end

aws_security_group 'ref-sg2-eni' do
  action :destroy
end

aws_security_group 'ref-sg1-eni' do
  action :destroy
end

aws_vpc 'ref-vpc-eni' do
  action :destroy
end

aws_dhcp_options 'ref-dhcp-options-eni' do
  action :destroy
end
