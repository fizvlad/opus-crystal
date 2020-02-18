module Opus
  class Encoder
    @sample_rate : Int32         # Sampling rate of input signal (Hz). This must be one of 8000, 12000, 16000, 24000, or 48000.
    @frame_size : Int32          # Number of samples per channel in the input signal. For example, at 48 kHz the permitted values are 120, 240, 480, 960, 1920, and 2880. Passing in a duration of less than 10 ms (480 samples at 48 kHz) will prevent the encoder from using the LPC or hybrid modes.
    @channels : Int32            # Number of channels (1 or 2) in input signal.
    @encoder : LibOpus::Encoder* # Pointer to memory where encoder is stored.
    @vbr_rate : Int32?           # Variable bitrate or `nil` if it is disabled.
    @bitrate : Int32?            # Bits per second.

    # Allocates memory for new encoder and initialize it.
    def initialize(@sample_rate, @frame_size, @channels)
      error = LibOpus::Code::OK
      @encoder = LibOpus.encoder_create(@sample_rate, @channels, LibOpus::Application::AUDIO, pointerof(error))
      if error != LibOpus::Code::OK
        raise OpusError.new("Failed to create Opus encoder. Error code: #{error}")
      end
    end

    # Cleans up memory after encoder.
    def finalize : Nil
      LibOpus.encoder_destroy(@encoder)
    end

    # Resets the codec state.
    def reset : Nil
      LibOpus.encoder_ctl(@encoder, LibOpus::CTL::RESET_STATE)
    end

    # Enables variable bitrate for encoder.
    def vbr_rate=(value : Int32) : Int32
      @vbr_rate = value
      Opus.encoder_ctl(@encoder, LibOpus::CTL::SET_VBR, @vbr_rate)
      @vbr_rate
    end

    # Configure bitrate.
    def bitrate=(value : Int32) : Int32
      @bitrate = value
      Opus.encoder_ctl(@encoder, LibOpus::CTL::SET_BITRATE, @bitrate)
      @bitrate
    end

    # Encode data.
    def encode(data : Bytes) : Bytes
      expected_length = @frame_size * @channels
      if data.size != expected_length
        raise OpusError.new("Unexpected slice size! (Expected #{expected_length}, got #{data.size})")
      end

      buffer = Bytes.new(expected_length) # Temporary buffer. Actual data will require less memory.
      out_length = LibOpus.encode(@encoder, data.to_unsafe.as(Int16*), @frame_size, buffer, buffer.size)
      Bytes.new(out_length) { |i| buffer[i] }
    end
  end
end
