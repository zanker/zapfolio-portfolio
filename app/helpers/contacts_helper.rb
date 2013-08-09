module ContactsHelper
  def render_contact_field(args)
    html = label_tag("#{args[:parent]}_#{args[:key]}", args[:text])
    if args[:required]
      html += content_tag(:span, "*", :class => :required)
    end

    html = content_tag(:div, html, :class => :text)

    klasses = [:row]
    klasses.push(:spacer) if args[:type] == :text_area_tag

    value = nil
    if params[args[:parent]]
      if !params[args[:parent]][args[:key]].blank?
        unless args[:type] == :password_field_tag
          value = params[args[:parent]][args[:key]]
        end
      elsif args[:required]
        klasses.push(:missing)
      end
    end

    html += content_tag(:div, send(args[:type], "#{args[:parent]}[#{args[:key]}]", value, :placeholder => args[:placeholder]), :class => :element)

    content_tag(:div, html, :class => klasses)
  end
end