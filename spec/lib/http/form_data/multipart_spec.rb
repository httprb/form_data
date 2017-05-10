# frozen_string_literal: true

RSpec.describe HTTP::FormData::Multipart do
  let(:file)          { HTTP::FormData::File.new fixture "the-http-gem.info" }
  let(:params)        { { :foo => :bar, :baz => file } }
  let(:boundary)      { /-{21}[a-f0-9]{42}/ }
  subject(:form_data) { HTTP::FormData::Multipart.new params }

  describe "#to_s" do
    def disposition(params)
      params = params.map { |k, v| "#{k}=#{v.inspect}" }.join("; ")
      "Content-Disposition: form-data; #{params}"
    end

    let(:crlf) { "\r\n" }

    it "properly generates multipart data" do
      boundary_value = form_data.content_type[/(#{boundary})$/, 1]

      expect(form_data.to_s).to eq [
        "--#{boundary_value}#{crlf}",
        "#{disposition 'name' => 'foo'}#{crlf}",
        "#{crlf}bar#{crlf}",
        "--#{boundary_value}#{crlf}",
        "#{disposition 'name' => 'baz', 'filename' => file.filename}#{crlf}",
        "Content-Type: #{file.content_type}#{crlf}",
        "#{crlf}#{file}#{crlf}",
        "--#{boundary_value}--"
      ].join("")
    end

    context "with filename set to nil" do
      let(:part) { HTTP::FormData::Part.new("s", :content_type => "mime/type") }
      let(:form_data) { HTTP::FormData::Multipart.new(:foo => part) }

      it "doesn't include a filename" do
        boundary_value = form_data.content_type[/(#{boundary})$/, 1]

        expect(form_data.to_s).to eq [
          "--#{boundary_value}#{crlf}",
          "#{disposition 'name' => 'foo'}#{crlf}",
          "Content-Type: #{part.content_type}#{crlf}",
          "#{crlf}s#{crlf}",
          "--#{boundary_value}--"
        ].join("")
      end
    end

    context "with content type set to nil" do
      let(:part) { HTTP::FormData::Part.new("s") }
      let(:form_data) { HTTP::FormData::Multipart.new(:foo => part) }

      it "doesn't include a filename" do
        boundary_value = form_data.content_type[/(#{boundary})$/, 1]

        expect(form_data.to_s).to eq [
          "--#{boundary_value}#{crlf}",
          "#{disposition 'name' => 'foo'}#{crlf}",
          "#{crlf}s#{crlf}",
          "--#{boundary_value}--"
        ].join("")
      end
    end
  end

  describe "#size" do
    it "returns bytesize of multipart data" do
      expect(form_data.size).to eq form_data.to_s.bytesize
    end
  end

  describe "#read" do
    it "returns multipart data" do
      expect(form_data.read).to eq form_data.to_s
    end
  end

  describe "#rewind" do
    it "rewinds the multipart data IO" do
      form_data.read
      form_data.rewind
      expect(form_data.read).to eq form_data.to_s
    end
  end

  describe "#content_type" do
    subject { form_data.content_type }

    let(:content_type) { %r{^multipart\/form-data; boundary=#{boundary}$} }

    it { is_expected.to match(content_type) }
  end

  describe "#content_length" do
    subject { form_data.content_length }
    it { is_expected.to eq form_data.to_s.bytesize }
  end

  describe "#boundary" do
    subject { form_data.boundary }
    it { is_expected.not_to be_empty }

    it "is included in content type" do
      expect(form_data.content_type).to end_with(form_data.boundary)
    end
  end
end
