require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe :validation do
    describe :body do
      subject{ build :comment, body: body }

      context :nil do
        let(:body){ nil }
        it{ expect(subject).not_to be_valid }
      end

      context :present do
        let(:body){ "some body" }
        it{ expect(subject).to be_valid }
      end
    end
  end
end
