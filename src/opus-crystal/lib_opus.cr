@[Link("opus")]
lib LibOpus
  enum Code
    OK               = 0
    BAD_ARG          = -1
    BUFFER_TOO_SMALL = -2
    INTERNAL_ERROR   = -3
    INVALID_PACKET   = -4
    UNIMPLEMENTED    = -5
    INVALID_STATE    = -6
    ALLOC_FAIL       = -7
  end

  enum Application
    VOIP                = 2048
    AUDIO               = 2049
    RESTRICTED_LOWDELAY = 2051
  end

  enum Signal
    VOICE = 3001
    MUSIC = 3002
  end

  enum CTL
    SET_BITRATE = 4002
    SET_VBR     = 4006
    RESET_STATE = 4028
  end

  # TODO: Probably it is possible to properly define both Encoder and Decoder
  #       as structs here, but I will mess it up.
  #       > Come back when you are a little MMMMMM experiencer.

  alias PEncoder = UInt8*
  fun opus_encoder_get_size(channels : Int32) : Int32
  fun opus_encoder_create(sampling_rate : Int32, channels : Int32, application : Application, error : Code*) : PEncoder
  fun opus_encoder_init(state : PEncoder, sampling_rate : Int32, channels : Int32, application : Application) : Code
  fun opus_encode(state : PEncoder, pcm : Int16*, frame_size : Int32, data : UInt8*, max_data_bytes : Int32) : Int32
  fun opus_encode_float(state : PEncoder, pcm : Float32*, frame_size : Int32, data : UInt8*, max_data_bytes : Int32) : Int32
  fun opus_encoder_destroy(state : PEncoder) : Void
  fun opus_encoder_ctl(state : PEncoder, request : CTL, ...) : Int32

  alias PDecoder = UInt8*
  fun opus_decoder_get_size(channels : Int32) : Int32
  fun opus_decoder_create(sampling_rate : Int32, channels : Int32, error : Code*) : PDecoder
  fun opus_decoder_init(state : PDecoder, sampling_rate : Int32, channels : Int32) : Code
  fun opus_decode(state : PDecoder, data : UInt8*, length : Int32, pcm : Int16*, frame_size : Int32, decode_fec : Int32) : Int32
  fun opus_decode_float(state : PDecoder, data : UInt8*, length : Int32, pcm : Float32*, frame_size : Int32, decode_fec : Int32) : Int32
  fun opus_decoder_destroy(state : PDecoder) : Void
  fun opus_decoder_ctl(state : PDecoder, request : CTL, ...) : Int32
end
