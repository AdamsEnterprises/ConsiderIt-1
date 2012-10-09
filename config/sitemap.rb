

Account.all.each do |accnt|

  subdomain = accnt.identifier  
# Set the host name for URL creation
  SitemapGenerator::Sitemap.default_host = "https://#{subdomain}.livingvotersguide.org"
  SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/#{subdomain}"

  SitemapGenerator::Sitemap.create do
    # Put links creation logic here.
    #
    # The root path '/' and sitemap index file are added automatically for you.
    # Links are added to the Sitemap in the order they are specified.
    #
    # Usage: add(path, options={})
    #        (default options are used if you don't specify)
    #
    # Defaults: :priority => 0.5, :changefreq => 'weekly',
    #           :lastmod => Time.now, :host => default_host
    #
    # Examples:
    #
    # Add '/articles'
    #
    #   add articles_path, :priority => 0.7, :changefreq => 'daily'
    #
    # Add all articles:
    #
    #   Article.find_each do |article|
    #     add article_path(article), :lastmod => article.updated_at
    #   end  

    accnt.proposals.where(:active => true).each do |prop|
      add new_proposal_position_path(prop.long_id), {:priority => 0.7, :changefreq => 'daily'}
      add proposal_path(prop.long_id), {:priority => 0.4, :changefreq => 'daily'}
    end

    add '/home/media', {:priority => 0.2, :changefreq => 'weekly'}

    accnt.proposals.where(:active => false).each do |prop|
      add new_proposal_position_path(prop.long_id), {:priority => 0.1, :changefreq => 'yearly'}
      add proposal_path(prop.long_id), {:priority => 0.1, :changefreq => 'yearly'}
    end

  end

end