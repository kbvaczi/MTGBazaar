module FormsHelper
  def link_to_remove_fields(options)
  options = {:name => 'Add a field', :form => nil, :association => nil}.merge(options)    
   options[:form].hidden_field(:_destroy) + link_to_function(options[:name], "remove_fields(this)", :class => options[:class])
  end
  
  def link_to_add_fields(options)
    options = {:name => 'Add a field', :form => nil, :association => nil}.merge(options)
    new_object = options[:form].object.class.reflect_on_association(options[:association].to_sym).klass.new
    fields = options[:form].fields_for(options[:association].to_sym, new_object, :child_index => "new_#{options[:association].to_sym}") do |builder|
      render(options[:association].singularize + "_fields", :f => builder, :parent_form => options[:form])
    end
    link_to_function(options[:name], "add_fields(this, \"#{options[:association].to_sym}\", \"#{escape_javascript(fields)}\")", :class => options[:class])
  end
end