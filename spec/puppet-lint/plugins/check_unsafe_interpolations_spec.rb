require 'spec_helper'

describe 'check_unsafe_interpolations' do
  let(:code) do
    <<-PUPPET
    class foo {

      exec { 'bar':
        command => "echo ${foo}",
      }

    }
    PUPPET
  end

  it 'detects an unsafe exec command argument' do
    expect(problems).to have(1).problem
    expect(problems).to contain_warning("unsafe interpolation of variable 'foo' in exec command")
  end
end
