module CustomFields
  module PageExtensions
    def self.included(base)
      base.class_eval do
        has_many :custom_fields, :dependent => :destroy
      end
    end
  end
end