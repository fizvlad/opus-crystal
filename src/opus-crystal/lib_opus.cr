@[Link("opus")]
lib LibOpus
  enum Code : LibC::Int
    OK               = 0
    BAD_ARG          = -1
    BUFFER_TOO_SMALL = -2
    INTERNAL_ERROR   = -3
    INVALID_PACKET   = -4
    UNIMPLEMENTED    = -5
    INVALID_STATE    = -6
    ALLOC_FAIL       = -7
  end

  enum Application : LibC::Int
    VOIP                = 2048
    AUDIO               = 2049
    RESTRICTED_LOWDELAY = 2051
  end

  enum Signal : LibC::Int
    VOICE = 3001
    MUSIC = 3002
  end

  enum CTL : LibC::Int
    SET_BITRATE = 4002
    SET_VBR     = 4006
    RESET_STATE = 4028
  end

  # TODO: Probably it is possible to properly define both Encoder and Decoder
  #       as structs here, but I will mess it up.
  #       > Come back when you are a little MMMMMM experiencer.

  type Encoder = Void
  fun encoder_get_size = opus_encoder_get_size(channels : LibC::Int) : LibC::Int
  fun encoder_create = opus_encoder_create(sampling_rate : Int32, channels : LibC::Int, application : Application, error : Code*) : Encoder*
  fun encoder_init = opus_encoder_init(state : Encoder*, sampling_rate : Int32, channels : LibC::Int, application : Application) : Code
  fun encode = opus_encode(state : Encoder*, pcm : Int16*, frame_size : LibC::Int, data : UInt8*, max_data_bytes : Int32) : Int32
  fun encode_float = opus_encode_float(state : Encoder*, pcm : LibC::Float*, frame_size : LibC::Int, data : UInt8*, max_data_bytes : Int32) : Int32
  fun encoder_destroy = opus_encoder_destroy(state : Encoder*) : Void
  fun encoder_ctl = opus_encoder_ctl(state : Encoder*, request : CTL, ...) : LibC::Int

  type Decoder = Void
  fun decoder_get_size = opus_decoder_get_size(channels : LibC::Int) : LibC::Int
  fun decoder_create = opus_decoder_create(sampling_rate : Int32, channels : LibC::Int, error : Code*) : Decoder*
  fun decoder_init = opus_decoder_init(state : Decoder*, sampling_rate : Int32, channels : LibC::Int) : Code
  fun decode = opus_decode(state : Decoder*, data : UInt8*, length : Int32, pcm : Int16*, frame_size : LibC::Int, decode_fec : LibC::Int) : LibC::Int
  fun decode_float = opus_decode_float(state : Decoder*, data : UInt8*, length : Int32, pcm : LibC::Float*, frame_size : LibC::Int, decode_fec : LibC::Int) : LibC::Int
  fun decoder_destroy = opus_decoder_destroy(state : Decoder*) : Void
  fun decoder_ctl = opus_decoder_ctl(state : Decoder*, request : CTL, ...) : LibC::Int
end
