require 'spec_helper'
describe 'group_allow' do

  context 'with defaults for all parameters' do
    it { should contain_class('group_allow') }
  end
end
