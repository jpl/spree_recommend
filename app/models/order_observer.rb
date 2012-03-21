class OrderObserver < ActiveRecord::Observer
	def after_save(o)
		return if !o.completed_at_changed?
		return if o.completed_at.blank?

		OrderObserver.recommend(o.id, o.line_items.map{|i| i.product.id})
		OrderObserver.process
	end

	def self.recommend(order_id, product_ids)
		@@recommender ||= ProductRecommender.new
		@@recommender.order_items.add_set(order_id, product_ids)
	end

	def self.process
		@@recommender.process!
	end

	def self.all_recommendations
		@@recommender ||= ProductRecommender.new
		@@recommender.all_items.each do |p_id|
			recs = @@recommender.for(p_id)
			next if recs.empty?
			puts "#{p_id} : #{recs.map(&:item_id).join(', ')}"
		end
	end
end