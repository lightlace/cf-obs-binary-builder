require_relative "../spec_helper"

describe CfObsBinaryBuilder::ObsPackage do
  subject { described_class.new("foo") }

  describe "#obs_project" do
    context "when OBS_PROJECT env variable is not set" do
      before(:each) do
        ENV.delete "OBS_PROJECT"
      end

      it "exits with error" do
        expect{ subject.obs_project }.to raise_error(RuntimeError, "no OBS_PROJECT environment variable set")
      end
    end

    context "when OBS_PROJECT env variable is not set" do
      before(:each) do
        ENV["OBS_PROJECT"] = "home:ObsUser"
      end

      it "returns the correct value" do
        expect(subject.obs_project).to eq("home:ObsUser")
      end
    end
  end
end
