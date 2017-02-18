require 'rails_helper'

RSpec.describe Post, type: :model do

  describe :validation do
    describe :subject do
      subject{ build :post, subject: s }

      context :nil do
        let(:s){ nil }
        it{ expect(subject).not_to be_valid }
      end

      context :present do
        let(:s){ "some text" }
        it{ expect(subject).to be_valid }
      end
    end
  end

  describe :index_errors do
    describe :failure do
      subject{ create :post }
      before do
        subject.comments.create body: "some body"
        subject.comments.create body: "some body"
      end

      describe "before monkey patch" do
        let(:error_hash){ subject.errors.to_h }

        before do
          subject.comments[target_index].body = ""
          subject.save
        end

        context "if the first comment has errors.." do
          let(:target_index){ 0 }
          it{ expect(error_hash).to eq({:"comments[0].body"=>"can't be blank"}) }
        end

        context "if the second comment has errors.." do
          let(:target_index){ 1 }
                            # this should be index 1, but 0
          it{ expect(error_hash).to eq({:"comments[1].body"=>"can't be blank"}) }
        end
      end
    end

    describe :success do
      subject{ create :post }

      before do
        eval <<-PATCH
        module ActiveRecord
          module AutosaveAssociation
            private
              def validate_collection_association(reflection)
                if association = association_instance_get(reflection.name)
                  if records = associated_records_to_validate_or_save(association, new_record?, reflection.options[:autosave])

                    association.target.collect.with_index do |record_from_target, index_from_target|
                      next unless record = records.find{|record| record == record_from_target }

                      [record, index_from_target]
                    end.compact.each { |record, index| association_valid?(reflection, record, index) }
                  end
                end
              end
          end
        end
        PATCH

        subject.comments.create! body: "some body"
        subject.comments.create! body: "some body"
        subject.reload
      end

      context "monkey patched" do
        let(:target_index){ 1 }
        let(:error_hash){ subject.errors.to_h }

        before do
          subject.comments[target_index].body = ""
          subject.save
        end

        it{ expect(error_hash).to eq({:"comments[1].body"=>"can't be blank"}) }
      end

    end
  end
end
