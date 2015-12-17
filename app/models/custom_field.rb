class CustomField < ActiveRecord::Base
  belongs_to :page

  validates_presence_of       :name
  validates_uniqueness_of     :name, :scope => :page_id
  validates_presence_of       :value
  validates_presence_of       :page_id
  validates_presence_of       :site_id, :if => :vhost_extension?
  validates_presence_of       :locale,  :if => :globalize2_extension?
  
  def self.find_assignable_custom_fields(page_id)
    all = find(:all, :group => "name").map(&:name)
    assigned = find(:all, :conditions => {:page_id => page_id}, :group => "name").map(&:name)
    all - assigned
  end
  
  private
  
  def vhost_extension?
    defined?(VhostExtension)
  end
  
  def globalize2_extension?
    defined?(Globalize2Extension)
  end

end
