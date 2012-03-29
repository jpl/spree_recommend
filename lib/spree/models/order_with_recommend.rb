module Spree::Models::OrderWithRecommend
	def recommendations(limit = 4)
		logger.debug "recommendation start"
		@recommender ||= ProductRecommender.new

		product_ids = self.line_items.map{|li| li.product.id.to_i}

		suggested_items = product_ids.inject([]) {|memo, p_id| memo.concat @recommender.for(p_id); memo}
		suggested_items = suggested_items.select{|item| !product_ids.include?(item.item_id.to_i)}

		products = Product.active.all(:conditions => {:id => suggested_items.map(&:item_id)})

		by_pids = suggested_items.inject({}) {|memo, item| memo[item.item_id.to_i] = item.similarity; memo}

		sorted = products.sort{|x, y| by_pids[y.id.to_i] <=> by_pids[x.id.to_i]}

		sorted.take(limit)
	end
end