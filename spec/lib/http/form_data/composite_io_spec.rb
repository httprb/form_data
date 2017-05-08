# frozen_string_literal: true

RSpec.describe HTTP::FormData::CompositeIO do
  let(:ios) { ["Hello", " ", "", "world", "!"].map { |s| StringIO.new(s) } }
  subject(:composite_io) { HTTP::FormData::CompositeIO.new(ios) }

  describe "#initialize" do
    it "accepts IOs and strings" do
      composite_io = HTTP::FormData::CompositeIO.new ["Hello ", StringIO.new("world!")]
      expect(composite_io.read).to eq "Hello world!"
    end

    it "fails if an IO is neither a String nor an IO" do
      expect { HTTP::FormData::CompositeIO.new [:hello, :world] }
        .to raise_error(ArgumentError)
    end
  end

  describe "#read" do
    it "reads all data" do
      expect(composite_io.read).to eq "Hello world!"
    end

    it "reads partial data" do
      expect(composite_io.read(3)).to eq "Hel"
      expect(composite_io.read(2)).to eq "lo"
      expect(composite_io.read(1)).to eq " "
      expect(composite_io.read(6)).to eq "world!"
    end

    it "returns empty string when no data was retrieved" do
      composite_io.read
      expect(composite_io.read).to eq ""
    end

    it "returns nil when no partial data was retrieved" do
      composite_io.read
      expect(composite_io.read(3)).to eq nil
    end

    it "reads partial data with a buffer" do
      outbuf = String.new
      expect(composite_io.read(3, outbuf)).to eq "Hel"
      expect(composite_io.read(2, outbuf)).to eq "lo"
      expect(composite_io.read(1, outbuf)).to eq " "
      expect(composite_io.read(6, outbuf)).to eq "world!"
    end

    it "fills the buffer with retrieved content" do
      outbuf = String.new
      composite_io.read(3, outbuf)
      expect(outbuf).to eq "Hel"
      composite_io.read(2, outbuf)
      expect(outbuf).to eq "lo"
      composite_io.read(1, outbuf)
      expect(outbuf).to eq " "
      composite_io.read(6, outbuf)
      expect(outbuf).to eq "world!"
    end

    it "returns nil when no partial data was retrieved with a buffer" do
      outbuf = String.new("content")
      composite_io.read
      expect(composite_io.read(3, outbuf)).to eq nil
      expect(outbuf).to eq ""
    end
  end

  describe "#rewind" do
    it "rewinds all IOs" do
      composite_io.read
      composite_io.rewind
      expect(composite_io.read).to eq "Hello world!"
    end
  end

  describe "#size" do
    it "returns sum of all IO sizes" do
      expect(composite_io.size).to eq 12
    end

    it "returns 0 when there are no IOs" do
      empty_composite_io = HTTP::FormData::CompositeIO.new []
      expect(empty_composite_io.size).to eq 0
    end
  end
end
