# frozen_string_literal: true

RSpec.describe HTTP::FormData do
  describe ".create" do
    subject { described_class.create params }

    context "when form has no files" do
      let(:params) { { foo: :bar } }

      it { is_expected.to be_a HTTP::FormData::Urlencoded }
    end

    context "when form has at least one file param" do
      let(:file) { HTTP::FormData::File.new(fixture("the-http-gem.info").to_s) }
      let(:params) { { foo: :bar, baz: file } }

      it { is_expected.to be_a HTTP::FormData::Multipart }
    end

    context "when form has file in an array param" do
      let(:file) { HTTP::FormData::File.new(fixture("the-http-gem.info").to_s) }
      let(:params) { { foo: :bar, baz: [file] } }

      it { is_expected.to be_a HTTP::FormData::Multipart }
    end
  end

  describe ".ensure_data" do
    subject(:ensure_data) { described_class.ensure_data data }

    context "when Hash given" do
      let(:data) { { foo: :bar } }

      it { is_expected.to eq foo: :bar }
    end

    context "when Array given" do
      let(:data) { [%i[foo bar], %i[foo baz]] }

      it { is_expected.to eq [%i[foo bar], %i[foo baz]] }
    end

    context "when Enumerator given" do
      let(:data) { Enumerator.new { |y| y << %i[foo bar] } }

      it { is_expected.to be_a Enumerator }
    end

    context "when #to_h given" do
      let(:data) { double(to_h: { foo: :bar }) }

      it { is_expected.to eq foo: :bar }
    end

    context "when nil given" do
      let(:data) { nil }

      it { is_expected.to eq([]) }
    end

    context "when neither Enumerable nor #to_h given" do
      let(:data) { double }

      it "fails with HTTP::FormData::Error" do
        expect { ensure_data }.to raise_error HTTP::FormData::Error
      end
    end
  end

  describe ".ensure_hash" do
    subject(:ensure_hash) { described_class.ensure_hash data }

    context "when Hash given" do
      let(:data) { { foo: :bar } }

      it { is_expected.to eq foo: :bar }
    end

    context "when #to_h given" do
      let(:data) { double(to_h: { foo: :bar }) }

      it { is_expected.to eq foo: :bar }
    end

    context "when nil given" do
      let(:data) { nil }

      it { is_expected.to eq({}) }
    end

    context "when neither Hash nor #to_h given" do
      let(:data) { double }

      it "fails with HTTP::FormData::Error" do
        expect { ensure_hash }.to raise_error HTTP::FormData::Error
      end
    end
  end
end
