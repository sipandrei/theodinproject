require 'rails_helper'

RSpec.describe ResetProgressJob do
  subject(:job) { described_class.new }

  describe '#perform' do
    let!(:foundations_path) { create(:path, default_path: true) }
    let(:user) { create(:user, id: 1234) }

    before do
      allow(User).to receive(:find_by).with({ id: 1234 }).and_return(user)
      allow(user.lesson_completions).to receive(:destroy_all)
    end

    context 'when path is the default path' do
      before do
        allow(user).to receive(:path).and_return(foundations_path)
        allow(user).to receive(:update)
        job.perform(user.id)
      end

      it 'deletes all lesson completions' do
        expect(user.lesson_completions).to have_received(:destroy_all)
      end

      it 'does not update path' do
        expect(user).not_to have_received(:update)
      end
    end

    context 'when path is not the default path' do
      let!(:rails_path) { create(:path) }

      before do
        allow(user).to receive(:path).and_return(rails_path)
        allow(Path).to receive(:default_path).and_return(foundations_path)
        allow(user).to receive(:update).with({ path: foundations_path })
        job.perform(user.id)
      end

      it 'deletes all lesson completions' do
        expect(user.lesson_completions).to have_received(:destroy_all)
      end

      it 'updates path to default path' do
        expect(user).to have_received(:update).with({ path: foundations_path })
      end
    end
  end
end
