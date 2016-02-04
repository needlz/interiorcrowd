class SitemapsController < ApplicationController

  def sitemap_index
    render text: open("https://s3.amazonaws.com/#{ ENV['S3_BUCKET_NAME'] }/sitemaps/sitemap.xml").read, content_type: 'application/xml'
  end

  def sitemap
    sitemap_name = params[:sitemap_file]
    render text: open("https://s3.amazonaws.com/#{ ENV['S3_BUCKET_NAME'] }/sitemaps/#{ sitemap_name }").read, content_type: 'application/xml'
  end

end
