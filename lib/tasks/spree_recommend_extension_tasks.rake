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
        user_items = Hash.new{ |h,k| h[k]=[] }

        Order.all(:conditions => "completed_at is not null").each do |o|
          p_ids = o.line_items.select{|i| i.variant.product.has_stock?}.map{|i| i.variant.product.id}
          user_items[o.user_id].concat(p_ids)
        end

        user_items.each do |u_id, product_ids|
          puts "Adding user_id #{u_id} with #{product_ids.size}"
          OrderObserver.recommend(u_id, product_ids)
        end

        OrderObserver.process
      end
    end
  end
end