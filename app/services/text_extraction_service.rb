class TextExtractionService
  def initialize(file)
    @file = file
  end

  def extract_text
    return unless @file.attached?
    file_path = ActiveStorage::Blob.service.send(:path_for, @file.key)
    require 'mini_magick'
    require 'rtesseract'
    text = ''
    if @file.content_type == 'application/pdf'
      require 'tmpdir'
      Dir.mktmpdir do |dir|
        MiniMagick::Tool::Convert.new do |convert|
          convert.density(300)
          convert.background('white')
          convert.alpha('remove')
          convert << file_path
          convert << File.join(dir, 'page-%03d.png')
        end
        Dir[File.join(dir, 'page-*.png')].sort.each do |img_path|
          text << RTesseract.new(img_path).to_s
        end
      end
    elsif @file.content_type.start_with?('image/')
      text = RTesseract.new(file_path).to_s
    end
    text
  end
end
