require 'rails_helper'

RSpec.describe ActivityPub::Activity::Reject do
  let(:sender)    { Fabricate(:account) }
  let(:recipient) { Fabricate(:account) }

  let(:json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'foo',
      type: 'Reject',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      object: {
        id: 'bar',
        type: 'Follow',
        actor: ActivityPub::TagManager.instance.uri_for(recipient),
        object: ActivityPub::TagManager.instance.uri_for(sender),
      },
    }.with_indifferent_access
  end

  describe '#perform' do
    subject { described_class.new(json, sender) }

    before do
      Fabricate(:follow_request, account: recipient, target_account: sender)
      subject.perform
    end

    it 'does not create a follow relationship' do
      expect(recipient.following?(sender)).to be false
    end

    it 'removes the follow request' do
      expect(recipient.requested?(sender)).to be false
    end
  end
end
