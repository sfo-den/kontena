require 'spec_helper'

describe 'vpn remove' do
  before(:each) do
    # Due to async nature of stack/service removals, need to wait until possible previous vpn containers have gone
    wait_until_container_gone('vpn.server-1')
  end

  after(:each) do
    run 'kontena stack rm --force vpn'
  end

  it 'removes the vpn stack' do
    run 'kontena vpn create'
    k = run 'kontena stack rm --force vpn'
    expect(k.code).to eq(0)
    k = run 'kontena stack show vpn'
    expect(k.code).not_to eq(0)
  end

  it 'returns error if vpn does not exist' do
    k = run 'kontena vpn remove --force'
    expect(k.code).not_to eq(0)
  end

  it 'prompts without --force' do
    k = kommando 'kontena vpn remove', timeout: 5
    k.out.on "Are you sure?" do
      k.in << "y\r"
    end
    k.run
    expect(k.out.include?("does not exist"))
  end
end
