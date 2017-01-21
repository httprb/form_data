# frozen_string_literal: true

RSpec.describe HTTP::FormData::Part do
  let(:body) { "" }
  let(:opts) { {} }

  describe "#size" do
    subject { described_class.new(body, opts).size }

    context "when body given as a String" do
      let(:body) { "привет мир!" }
      it { is_expected.to eq 20 }
    end
  end

  describe "#to_s" do
    subject { described_class.new(body, opts).to_s }

    context "when body given as String" do
      let(:body) { "привет мир!" }
      it { is_expected.to eq "привет мир!" }
    end
  end

  describe "#filename" do
    subject { described_class.new(body, opts).filename }

    it { is_expected.to eq nil }

    context "when it was given with options" do
      let(:opts) { { :filename => "foobar.txt" } }
      it { is_expected.to eq "foobar.txt" }
    end
  end

  describe "#mime_type" do
    subject { described_class.new(body, opts).mime_type }

    it { is_expected.to eq nil }

    context "when it was given with options" do
      let(:opts) { { :mime_type => "application/json" } }
      it { is_expected.to eq "application/json" }
    end
  end

  describe "#content_type" do
    it "should be an alias of #mime_type" do
      expect(described_class.instance_method(:content_type)).to(
        eq(described_class.instance_method(:mime_type))
      )
    end
  end
end
