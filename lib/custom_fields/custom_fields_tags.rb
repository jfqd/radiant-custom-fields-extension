module CustomFields
  module CustomFieldsTags
  
    include Radiant::Taggable
    class TagError < StandardError; end

    desc %(
      Renders the requested field from the current page. Requires a @name@ attribute.

      *Usage:*
      <pre><code><r:field name="address" /></code></pre>
    )
    tag 'field' do |tag|
      attr = tag.attr.symbolize_keys
      page = tag.locals.page
      conditions = if defined?(Globalize2Extension)
        ["locale = ? AND name = ?", I18n.locale.to_s, attr[:name]]
      else
        ["name = ?", attr[:name]]
      end
      content = page.custom_fields.find(:first, :conditions => conditions).try(:value)
      if content.blank?
        ""
      elsif attr[:as] == "unordered-list" || attr[:as] == "ordered-list"
        seperator = attr[:seperator] || ","
        element = attr[:as] == "unordered-list" ? :ul : :ol
        o = "<#{element}>"
        content.split(seperator).compact.each do |entry|
          o << "<li>#{entry.strip}</li>"
        end
        o << "</#{html_escape(element)}>"
        o
      elsif attr[:as] == "link"
        link_text = attr[:link_text] || content
        "<a href=\"#{html_escape(content)}\">#{html_escape(link_text)}</a>"
      elsif attr[:as] == "email"
        if defined?(EnkoderTagsExtension)
          # encrypt email
          # default to using the email address as the link_text
          link_text = attr[:link_text] || content

          attrs = tag.attr.dup
          attrs.delete('as')
          attrs.delete('name')
          attrs.delete('email')
          attrs.delete('title_text')
          attrs.delete('subject')
          attrs.delete('link_text')

          Enkoder.new.enkode_mailto(
            html_escape(content), link_text, attr[:title_text], attr[:subject], attrs
          )
        else
          link_text = attr[:link_text] || content
          "<a href=\"mailto:#{html_escape(content)}\">#{html_escape(link_text)}</a>"
        end
      else
        html_escape content
      end
    end

    desc %(
      Renders the contained elements if the field given in the @name@ attribute
      exists. The tag also takes an optional @matches@ attribute;
      it will expand the tag if the field's content matches the
      given string or regex.

      *Usage:*
      <pre><code><r:if_field name="author" [matches="John"]>...</r:if_field></code></pre>
    )
    tag 'if_field' do |tag|
      raise TagError.new("`if_field' tag must contain a `name' attribute.") unless tag.attr.has_key?('name')
      attr = tag.attr.symbolize_keys
      page = tag.locals.page
      conditions = if defined?(Globalize2Extension)
        ["locale = ? AND name = ?", I18n.locale.to_s, attr[:name]]
      else
        ["name = ?", attr[:name]]
      end
      content = page.custom_fields.find(:first, :conditions => conditions).try(:value)
      if page.present? && content.present?
        if attr[:matches].present?
          regexp = build_regexp_for(tag, 'matches')
          unless content.match(regexp).nil?
             tag.expand
          end
        else
          tag.expand
        end
      end
    end

    desc %(
      The opposite of @if_field@. Renders the contained elements unless the field
      given in the @name@ attribute exists. The tag also takes an optional
      @matches@ attribute; it will expand the tag unless the
      field's content matches the given string or regex.

      *Usage:*
      <pre><code><r:unless_field name="author" [matches="John"]>...</r:unless_field></code></pre>
    )
    tag 'unless_field' do |tag|
      raise TagError.new("`unless_field' tag must contain a `name' attribute.") unless tag.attr.has_key?('name')
      attr = tag.attr.symbolize_keys
      page = tag.locals.page
      conditions = if defined?(Globalize2Extension)
        ["locale = ? AND name = ?", I18n.locale.to_s, attr[:name]]
      else
        ["name = ?", attr[:name]]
      end
      content = page.custom_fields.find(:first, :conditions => conditions).try(:value)
      if attr[:matches].present?
        regexp = build_regexp_for(tag, 'matches')
        if content.match(regexp).nil?
           tag.expand
        end
      else
        tag.expand if page.present? && content.blank?
      end
    end

  end
end
