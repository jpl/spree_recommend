# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class SpreeRecommendExtension < Spree::Extension
  version "1.0"
  description "Spree Recommend"
  url "http://yourwebsite.com/spree_recommend"

  # Please use spree_recommend/config/routes.rb instead for extension routes.

  def self.require_gems(config)
    config.gem "recommendify", :version => '0.3.1'
    config.gem "redis", :version => '2.2.2'
  end
  
  def activate

    # make your helper avaliable in all views
    # Spree::BaseController.class_eval do
    #   helper YourHelper
    # end
  end
end
