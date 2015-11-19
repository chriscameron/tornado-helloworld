require 'serverspec'
# Set backend type
set :backend, :exec

describe port(80) do
  it { should be_listening }
end

describe port(8000) do
  it { should be_listening }
end

describe command('curl http://localhost') do
  its(:stdout) { should include "Hello world!" }
end

describe service('helloworld.py') do
  it { should be_running }
end
