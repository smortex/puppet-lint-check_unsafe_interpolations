require 'spec_helper'

describe 'check_unsafe_interpolations' do
  let(:msg){ "unsafe interpolation of variable 'foo' in exec command" }
  context 'with fix disabled' do
    context 'code with unsafe interpolation' do
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
        expect(problems).to have(1).problems
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg)
      end
    end

    context 'code with no problems' do
      let(:code) do
        <<-PUPPET
        class foo {

          exec { 'bar':
            command => "echo foo",
          }

        }
        PUPPET
      end

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end
  end
end
