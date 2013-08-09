module Kaminari
  module ActionViewExtension
    def paginate(scope, options = {}, &block)
      options = options.reverse_merge(:param_name => Kaminari.config.param_name, :remote => false)
      options[:current_page] ||= scope.current_page
      options[:num_pages] ||= scope.num_pages
      options[:per_page] ||= scope.limit_value

      Kaminari::Helpers::Paginator.new(self, options).to_s
    end
  end
end
