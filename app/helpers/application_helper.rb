module ApplicationHelper
  def page_title(skip_name=false)
    if response.code == "500"
      return "Server Error (500)"
    end

    if response.code == "404"
      title = t("titles.404").dup
    elsif @login_required
      title = t("titles.login_required").dup
    elsif @page and @page.title?
      title = @page.title

      if params[:page]
        title << " " << t("titles.page", :page => params[:page])
      end
    end

    title ||= t("titles.portfolio")
    if @website.name? and !skip_name
      title << " - " << @website.name
    end

    title
  end

  def linkify_text(text, *args)
    text.scan(/(\{(.+?)\})/).each do |match|
      text.gsub!(match.first, link_to(match.last, *args.shift))
    end

    text
  end

  def website_asset_url(site, args={})
    action = args[:fragment] ? :fragment : :show

    if Rails.env.production?
      "#{CONFIG[:cdn]}#{url_for(args.merge(:controller => :site_assets, :action => action, :modified => site.cache_bust["css"], :website_id => site._id))}"
    else
      url_for(args.merge(:controller => :site_assets, :action => action, :website_id => site._id, :only_path => true))
    end
  end

  def website_slug(slug)
    if slug.nil?
      "#"
    elsif !@editor_mode
      "/#{slug}"
    else
      "/#{slug}?editing=#{params[:editing]}"
    end
  end

  def build_menu(site, open_page)
    full_html, mobile_html = "", ""

    site.menus.each do |menu|
      # Determine if the menu is opened via being a parent or the actual window
      opened, selected = nil, nil
      if open_page
        if menu.page_id == open_page._id
          opened, selected = true, true
        elsif menu.child_page_ids[open_page._id.to_s]
          opened = true
        end
      end

      # Parents
      slug = website_slug(menu.slug)
      if menu.sub_menus.empty?
        content = link_to(menu.name, slug, :class => slug == "#" ? "noclick" : "")
      else
        content = link_to("#{menu.name} #{content_tag(:div, nil, :class => :arrow)}".html_safe, slug, :class => "has-children#{slug == "#" ? " noclick" : ""}")
      end

      if menu.slug?
        mobile_html << content_tag(:option, menu.name, :value => website_slug(menu.slug), :selected => selected)
      else
        mobile_html << "<optgroup label='#{menu.name}'>"
      end

      # Any children
      unless menu.sub_menus.empty?
        sub_menu = ""
        menu.sub_menus.each do |child|
          sub_menu << content_tag(:li, link_to(child.name, website_slug(child.slug)), :class => open_page && open_page._id == child.page_id ? "active" : nil)
          mobile_html << content_tag(:option, "#{menu.slug? ? "-- " : ""}#{child.name}".html_safe, :value => website_slug(child.slug), :selected => open_page && open_page._id == child.page_id)
        end

        content << content_tag(:ul, sub_menu.html_safe, :class => "sub-menu")
      end

      unless menu.slug?
        mobile_html << "</optgroup>"
      end

      # Now actually add the parent
      full_html << content_tag(:li, content, :class => "menu#{(opened || menu.opened?) ? " opened" : ""}#{selected ? " active" : ""}")
    end

    content_tag(:ul, full_html.html_safe, :id => "menu-nav", :class => :pure) << content_tag(:select, mobile_html.html_safe, :onchange => "if( document.getElementById('mobile-menu-nav').value != '#' ) window.location.href = document.getElementById('mobile-menu-nav').value;", :id => "mobile-menu-nav")
  end

  def block_partial(partial, locals={}, &block)
    render :partial => partial, :locals => locals.merge(:body => capture_haml(&block))
  end
end