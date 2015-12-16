class VhostAndGlobalizeSupport < ActiveRecord::Migration
  def self.up
    add_column    :custom_fields, :field_type, :string
    add_column    :custom_fields, :locale,     :string
    add_column    :custom_fields, :site_id,    :integer
  end

  def self.down
    remove_column :custom_fields, :field_type
    remove_column :custom_fields, :locale
    remove_column :custom_fields, :site_id
  end
end
