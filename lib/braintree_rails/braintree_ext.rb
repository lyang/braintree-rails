[Braintree::Plan, Braintree::Modification].each do |model|
  model.class_eval do
   def self.find(id)
     all.find {|plan| plan.id == id}
   end
  end
end
