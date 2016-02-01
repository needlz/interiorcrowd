class SitemapsController < ApplicationController

  def sitemap
    redirect_to "https://s3.amazonaws.com/#{ ENV['S3_BUCKET_NAME'] }/sitemaps/sitemap.xml"
  end

end
