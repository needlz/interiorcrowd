require 'RMagick'

class PdfThumbnail
  def self.process(pdf)
    im = Magick::Image.read(pdf)
    im[0].write('111.jpg')
  end

end