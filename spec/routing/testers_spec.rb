require 'rails_helper'

describe 'Testers Routing' do
  it 'should not allow a memory_load route' do
    expect(:get => "/memory_load").not_to be_routable
  end
end
