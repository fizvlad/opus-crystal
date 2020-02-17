# This executable turns audio file into DCA format: https://github.com/bwmarrin/dca#dca
# Use of this executable requires installed ffmpeg (besides opus ofc).

require "../src/opus-crystal"

module DCA
  def self.metadata : String
    JSON.build do |json|
      json.object do
        # [REQUIRED] General information about this particular DCA file
        json.field "dca" do
          json.field "version", 1
          json.field "tool" do
            json.object do
              json.field "name", "dca-cr"
              json.field "version", "1.0.0"
              json.field "url", ""
              json.field "author", "fizvlad"
            end
          end
        end
        # [REQUIRED] Information about the parameters the audio packets are encoded with
        json.field "opus" do
        end
        # Information about the audio track. This attribute is optional but it is highly recommended to add whenever possible.
        json.field "info" do
        end
        # Information about where the audio data came from
        json.field "origin" do
        end
        # [REQUIRED] A field to put other arbitrary data into. It can be assumed that it always exists, but may be empty. DCA will never use this field internally.
        json.field "extra" do
          json.object { }
        end
      end
    end
  end
end
