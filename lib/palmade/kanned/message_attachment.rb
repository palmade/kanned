module Palmade::Kanned
  class MessageAttachment
    include Constants

    DEFAULT_PARAMS = {
      :original_filename => 'stream.bin',
      :size => nil
    }

    def initialize(tempfile, params = { })
      @tempfile = tempfile
      @params = params

      unless @params.include?(:content_type)
        @params[:content_type] = determine_content_type
      end
    end

    def content_type
      @params[:content_type]
    end

    def size
      @params[:size]
    end

    def original_filename
      @params[:original_filename]
    end

    def method_missing(method_name, *args, &block) #:nodoc:
      @tempfile.__send__(method_name, *args, &block)
    end

    def to_tempfile
      @tempfile
    end

    protected

    def determine_content_type
      ext = File.extname(original_filename)
      ext = ext[1..-1] unless ext.nil?

      case ext
      when 'mp4'
        'video/mp4'
      when 'mp3'
        'audio/mpeg'
      when 'ogg'
        'audio/ogg'
      when 'json'
        'application/json'
      when /jp(e|g|eg)/
        'image/jpeg'
      when /tiff?/
        'image/tiff'
      when 'png', 'gif', 'bmp'
        'image/%s' % ext
      when 'txt'
        'text/plain'
      when /html?/
        'text/html'
      when 'js'
        'application/js'
      when 'csv', 'xml', 'css'
        'text/%s' % ext
      when 'smil'
        'application/smil'
      else
        'application/octet-stream'
      end
    end
  end
end
