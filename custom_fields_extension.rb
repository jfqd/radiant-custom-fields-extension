# Uncomment this if you reference any of your controllers in activate
require_dependency 'application_controller'
require 'radiant-custom_fields-extension'

class CustomFieldsExtension < Radiant::Extension
  version     RadiantCustomFieldsExtension::VERSION
  description RadiantCustomFieldsExtension::DESCRIPTION
  url         RadiantCustomFieldsExtension::URL
  
  def activate
    Page.send(:include, CustomFields::PageExtensions)
    Page.send(:include, CustomFields::CustomFieldsTags)
    
    admin.page.edit.add :part_controls, "show_custom_fields"
    admin.page.edit.add :popups, "custom_fields_popup"
  end
  
  def deactivate
  end
end
