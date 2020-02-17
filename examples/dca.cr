require "json"
require "../src/opus-crystal"

# This executable turns audio file into DCA format: https://github.com/bwmarrin/dca#dca
# Use of this executable requires installed ffmpeg (besides opus ofc).

# Module with DCA methods.
module DCA
  # Method which writes DCA metadata to provided `IO`.
  # TODO: Add ability to change metadata.
  def self.metadata(io : IO) : Nil
    json = JSON.build(io) do |json|
      json.object do
        # [REQUIRED] General information about this particular DCA file
        json.field "dca" do
          json.object do
            # [REQUIRED] The version of the metadata and audio format. Changes in this version will always be backwards-compatible
            json.field "version", 1
            # [REQUIRED] Information about the tool used to encode the file
            json.field "tool" do
              json.object do
                # [REQUIRED] Name of the tool, can be any string
                json.field "name", "dca-cr"
                # [REQUIRED] The version of the tool used
                json.field "version", "1.0.0"
                # URL where to find the tool at
                json.field "url", "https://github.com/fizvlad/opus-crystal/blob/master/examples/dca.cr"
                # Author of the tool
                json.field "author", "fizvlad"
              end
            end
          end
        end
        # [REQUIRED] Information about the parameters the audio packets are encoded with
        json.field "opus" do
          json.object do
            # [REQUIRED] The opus mode, also called application - "voip", "music", or "lowdelay"
            json.field "mode", "voip"
            # [REQUIRED] The sample rate in Hz
            json.field "sample_rate", 48000
            # [REQUIRED] The frame size in bytes
            json.field "frame_size", 960
            # [REQUIRED] The resulting audio bitrate in bits per second, or null if the default has not been changed
            json.field "abr", nil
            # [REQUIRED] Whether variable bitrate encoding has been used (true/false)
            json.field "vbr", true
            # [REQUIRED] The resulting number of audio channels
            json.field "channels", 2
          end
        end
        # Information about the audio track. This attribute is optional but it is highly recommended to add whenever possible
        json.field "info" do
          json.object do
            # Title of the track
            json.field "title", ""
            # Artist who made the track
            json.field "artist", ""
            # Album the track is released in
            json.field "album", ""
            # Genre the track is classified under
            json.field "genre", ""
            # Any comments about the track
            json.field "comments", ""
            # The cover image of the album/track. See footnote [1] for information about this
            json.field "cover", nil
          end
        end
        # Information about where the audio data came from
        json.field "origin" do
          json.object do
            # The type of source that was converted to DCA. See footnote [2] for information about this
            json.field "source", "file"
            # Source bitrate in bits per second
            json.field "abr", nil
            # Number of channels in the source data
            json.field "channels", 2
            # Source encoding
            json.field "encoding", nil
            # The URL the source can be found at, or omitted if it wasn't downloaded from the network. Do not put a file path in here, it should be reserved for remote URLs only
            json.field "url", ""
          end
        end
        # [REQUIRED] A field to put other arbitrary data into. It can be assumed that it always exists, but may be empty. DCA will never use this field internally
        json.field "extra" do
          json.object { }
        end
      end
      # Footnotes for the metadata:
      # The cover image will be a base64-encoded JPEG or PNG image. DCA1 will not
      #   do any differentiation between the two, it is up to the user to read the
      #   respective magic bytes. The image has no size limit, if necessary it can
      #   fill the entire space provided by the maximum length mandated by the metadata
      #   header. If there is no image available, it can be null or the attribute
      #   can be omitted entirely.
      # The source can be any string, but it is suggested to use file if the source
      #   is a local or remote file, and generated if the file has not been converted
      #   in any way but has been generated from scratch using a tool.
    end
  end

  # Method which returnes string with DCA metadata.
  # TODO: Add ability to change metadata.
  def self.metadata : String
    String.build do |str|
      self.metadata(str)
    end
  end

  # Reads data from provided `IO` object and print encoded data to output `IO`.
  def self.encode(input : IO, output : IO) : Nil
    # Metadata
    output.print("DCA1")
    # TODO: Provide following data as options and pass it to metadata
    sample_rate = 48000
    frame_size = 960
    channels = 2
    meta = self.metadata
    output.write_bytes(meta.size.as(Int32), IO::ByteFormat::LittleEndian)
    output.print(meta)

    # Audio data
    opus = Opus::Encoder.new(sample_rate, frame_size, channels)
    encoded_data = IO::Memory.new # TODO: Might be useful to set some default size
    Process.run("ffmpeg", ["-loglevel 0 -f s16le -ar #{sample_rate} -ac #{channels}"], input: input, output: encoded_data)

    buffer = Slice(UInt8).new(frame_size)
    until encoded_data.read(buffer).zero?
      # TODO: Sometime actual size of read data is less than frame_size

      # TODO: Write opus data
      # opus_encoded_data = opus.encode(temp_buff.to_a)
      # output.write_bytes(opus_encoded_data.size.as(Int16), IO::ByteFormat::LittleEndian)
      # output.write(opus_encoded_data)
    end
  end
end

DCA.encode(STDIN, STDOUT)
