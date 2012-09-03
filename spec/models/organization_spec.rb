require 'spec_helper'

describe Organization do
  subject { FactoryGirl.create(:organization) }
  it { should have_many(:users) }
  it { should accept_nested_attributes_for(:users) }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should respond_to(:status) }

  context "Logic" do
    it "checks if the organization is approved or not" do
      org = FactoryGirl.create(:organization)
      org.should_not be_approved
      org.status = Organization::Status::APPROVED
      org.should be_approved
    end

    it "checks if the organization is rejected or not" do
      org = FactoryGirl.create(:organization)
      org.should_not be_rejected
      org.status = Organization::Status::REJECTED
      org.should be_rejected
    end
  end

  context "status change" do
    it "allows a new organization to be approved" do
      org = FactoryGirl.create(:organization, :status => Organization::Status::PENDING)
      org.approve!.should be_true
      org.reload.status.should eq Organization::Status::APPROVED
    end

    it "does not allow to approve an already rejected organization" do
      rejected_org = FactoryGirl.create(:organization, :status => Organization::Status::REJECTED)
      lambda{
        rejected_org.approve!
      }.should raise_error(StandardError, "A rejected organization cannot be approved")
      rejected_org.reload.status.should eq Organization::Status::REJECTED
    end

    it "does not allow to approve an already rejected organization" do
      rejected_org = FactoryGirl.create(:organization, :status => Organization::Status::APPROVED)
      lambda{
        rejected_org.reject!
      }.should raise_error(StandardError, "A approved organization cannot be rejected")
      rejected_org.reload.status.should eq Organization::Status::APPROVED
    end

    it "allows to reject a new organization" do
      org = FactoryGirl.create(:organization, :status => Organization::Status::PENDING)
      org.reject!.should be_true
      org.reload.status.should eq Organization::Status::REJECTED
    end
  end
end
