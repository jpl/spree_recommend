namespace :spree do
  namespace :extensions do
    namespace :spree_recommend do
      desc "Copies public assets of the Spree Recommend to the instance public/ directory."
      task :update => :environment do
        is_svn_git_or_dir = proc {|path| path =~ /\.svn/ || path =~ /\.git/ || File.directory?(path) }
        Dir[SpreeRecommendExtension.root + "/public/**/*"].reject(&is_svn_git_or_dir).each do |file|
          path = file.sub(SpreeRecommendExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end 

      desc "Process initial recommendation"
      task :process_recommend => :environment do
        @search = Order.search
        @search.completed_at_not_null

        @recommender = ProductRecommender.new

        @search.each do |o|
          puts "Adding order #{o.number} with #{o.line_items.size}"
          @recommender.order_items.add_set(o.id, o.line_items.map{|i| i.product.id})
        end

        @recommender.process!        
      end

    end
  end
end