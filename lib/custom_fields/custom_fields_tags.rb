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
        
        options = tag.attr.dup
        options.delete('as')
        options.delete('name')
        options.delete('link_text')
        
        attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
        attributes = " #{attributes}" unless attributes.empty?
        
        %{<a href="#{html_escape(content)}"#{attributes}>#{html_escape(link_text)}</a>}
      elsif attr[:as] == "email"
        if defined?(EnkoderTagsExtension)
          # encrypt email
          # default to using the email address as the link_text
          link_text   = attr[:link_text] || content
          js_fallback = ( attr[:js_fallback] == 'true' ? true : false )

          options = tag.attr.dup
          options.delete('as')
          options.delete('name')
          options.delete('email')
          options.delete('title_text')
          options.delete('subject')
          options.delete('link_text')
          options.delete('js_fallback')

          # enkode_mailto( email, link_text, js_fallback=false , title_text=nil, subject=nil, attrs=nil )
          Enkoder.new.enkode_mailto(
            html_escape(content),
            link_text,
            js_fallback,
            attr[:title_text],
            attr[:subject],
            options
          )
        else
          link_text = attr[:link_text] || content
          
          options = tag.attr.dup
          options.delete('as')
          options.delete('name')
          options.delete('link_text')
          
          attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
          attributes = " #{attributes}" unless attributes.empty?
          
          %{<a href="mailto:#{html_escape(content)}"#{attributes}>#{html_escape(link_text)}</a>}
        end
      elsif attr[:as] == "phone"
        link_text = attr[:link_text] || content
        country_prefix = attr[:country_prefix] || '+49'
        
        number = content.gsub(/[-_|\/\.\s]/, "")
        number = "#{country_prefix}#{number[1..-1]}" unless number[0] == "+"
        
        options = tag.attr.dup
        options.delete('as')
        options.delete('name')
        options.delete('link_text')
        options.delete('country_prefix')
        
        %{<a href="tel:#{html_escape(number)}"#{attributes}>#{html_escape(link_text)}</a>}
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
