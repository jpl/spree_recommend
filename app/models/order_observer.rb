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
end