WRITABLE_TEMP_DIR = 'tmp/'
FOG_SITEMAPS_DIR = 'sitemaps/'

SitemapGenerator::Sitemap.default_host = root_url(host: Settings.app_host)
SitemapGenerator::Sitemap.adapter = SitemapGenerator::S3Adapter.new(fog_provider: 'AWS',
                                                                    fog_directory: ENV['S3_BUCKET_NAME'],
                                                                    aws_access_key_id: ENV['AWS_ACCESS_KEY'],
                                                                    aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'])
SitemapGenerator::Sitemap.public_path = WRITABLE_TEMP_DIR
SitemapGenerator::Sitemap.sitemaps_path = FOG_SITEMAPS_DIR
SitemapGenerator::Sitemap.sitemaps_host = "http://#{ENV['S3_BUCKET_NAME']}.s3.amazonaws.com/"

BLOG_SITEMAPS = %w[post-sitemap.xml
page-sitemap.xml
tribe_events-sitemap.xml
category-sitemap.xml
post_tag-sitemap.xml
bne-testimonials-taxonomy-sitemap.xml]

SitemapGenerator::Sitemap.create_index = true
SitemapGenerator::Sitemap.compress = false

module BlogSitemapsHelper

  def self.include_blog_sitemap(filename)
    response = ::Blog::PageFetcher.new(url: Settings.external_urls.blog.url + '/' + filename,
                          params: {},
                          env: {},
                          method: 'get',
                          session: {},
                          blog_path: Rails.application.routes.url_helpers.blog_page_url(blog_page_path: '',
                                                                                        host: Settings.app_host),
                          request: {}).get_response.body

    normalized_response = response.gsub(Blog::PageParser::BLOG_REGEX, Blog::PageParser::BLOG_PATH_REPLACEMENT)

    s3 = AWS::S3.new
    bucket = s3.buckets[Settings.aws.bucket_name]
    s3_object = AWS::S3::S3Object.new(bucket, "#{ SitemapGenerator::Sitemap.sitemaps_path }#{ filename }")
    s3_object.write(normalized_response, acl: :public_read)
  end

end

SitemapGenerator::Sitemap.create do
  add '/', changefreq: 'yearly', priority: 1.0
  add '/about_us', changefreq: 'yearly', priority: 0.9
  add '/how_it_works', changefreq: 'yearly', priority: 0.9
  add '/terms_of_service', changefreq: 'yearly', priority: 0.8
  add '/privacy_policy', changefreq: 'yearly', priority: 0.8
  add '/designer_submission', changefreq: 'yearly', priority: 0.8
  add '/contests/design_brief', changefreq: 'yearly', priority: 0.8
  add '/blog', changefreq: 'yearly', priority: 0.8
  add '/faq', changefreq: 'yearly', priority: 0.8

  add '/sessions/designer_login', changefreq: 'yearly', priority: 0.7
  add '/sessions/client_login', changefreq: 'yearly', priority: 0.7
  add '/justines_story', changefreq: 'yearly', priority: 0.7
  add '/sfar', changefreq: 'yearly', priority: 0.9
  add '/giftcards', changefreq: 'yearly', priority: 0.7
  add '/realtor_contacts', changefreq: 'yearly', priority: 0.9

  BLOG_SITEMAPS.each do |blog_sitemap_file|
    BlogSitemapsHelper.include_blog_sitemap(blog_sitemap_file)
    add_to_index SitemapGenerator::Sitemap.sitemaps_path + blog_sitemap_file
  end
end
