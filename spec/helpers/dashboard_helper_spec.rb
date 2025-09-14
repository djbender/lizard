require 'rails_helper'

RSpec.describe DashboardHelper, type: :helper do
  describe "#coverage_status" do
    it "returns excellent for high coverage (90-100%)" do
      aggregate_failures do
        expect(helper.coverage_status(100)).to eq("excellent")
        expect(helper.coverage_status(95)).to eq("excellent")
        expect(helper.coverage_status(90)).to eq("excellent")
      end
    end

    it "returns good for medium coverage (70-89%)" do
      aggregate_failures do
        expect(helper.coverage_status(89)).to eq("good")
        expect(helper.coverage_status(75)).to eq("good")
        expect(helper.coverage_status(70)).to eq("good")
      end
    end

    it "returns needs-improvement for low coverage (below 70%)" do
      aggregate_failures do
        expect(helper.coverage_status(69)).to eq("needs-improvement")
        expect(helper.coverage_status(50)).to eq("needs-improvement")
        expect(helper.coverage_status(0)).to eq("needs-improvement")
      end
    end
  end

  describe "#coverage_color" do
    it "returns green for high coverage (90-100%)" do
      aggregate_failures do
        expect(helper.coverage_color(100)).to eq("green")
        expect(helper.coverage_color(95)).to eq("green")
        expect(helper.coverage_color(90)).to eq("green")
      end
    end

    it "returns orange for medium coverage (70-89%)" do
      aggregate_failures do
        expect(helper.coverage_color(89)).to eq("orange")
        expect(helper.coverage_color(75)).to eq("orange")
        expect(helper.coverage_color(70)).to eq("orange")
      end
    end

    it "returns red for low coverage (below 70%)" do
      aggregate_failures do
        expect(helper.coverage_color(69)).to eq("red")
        expect(helper.coverage_color(50)).to eq("red")
        expect(helper.coverage_color(0)).to eq("red")
      end
    end
  end
end