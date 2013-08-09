module AlbumsHelper
  def browser_capabilities
    browser_type, retina_browser = :desktop, nil
    if request.env["HTTP_USER_AGENT"] =~ /ipad|kindle|tablet|gt\-p1000|sgh\-t849|shw\-m180s|xoom|playbook/i
      browser_type = :tablet
      #retina_browser = request.env["HTTP_USER_AGENT"] =~ /ipad/i
    elsif request.env["HTTP_USER_AGENT"] =~ /iphone|ipod|android|blackberry|mobile|windows ce|webos|nokia|phone|palm/i
      browser_type = :mobile
      #retina_browser = request.env["HTTP_USER_AGENT"] =~ /iphone|ipod/i
    end

    return browser_type, retina_browser
  end

  # CAROUSEL
  def generate_carousel_media(page, criteria)
    browser_type, retina_browser = browser_capabilities

    target_size = browser_type == :mobile && 350 || browser_type == :tablet && 500 || nil
    if page.max_size > 0 and ( target_size.nil? or target_size > page.max_size )
      target_size = page.max_size
    end

    smallest = nil

    list = criteria.map do |media|
      if !smallest or smallest > media.height
        smallest = media.height
      end

      {:media => media}
    end

    return [] if list.empty?

    if !target_size or target_size > smallest
      target_size = smallest
    end

    list.each do |data|
      data[:title] = data[:media].title if data[:media].title?

      url, width, height = data[:media].image_url(:height, target_size, true, retina_browser)
      data[:o], data[:ow], data[:oh] = url, width, height

      url, width, height = data[:media].image_url(:height, 75, false, retina_browser)
      data[:s], data[:sw], data[:sh] = url, width, height

      data.delete(:media)
    end

    # Randomize the list
    if page.randomize?
      list.sort_by! { rand }
    end

    list
  end

  # GRID
  def generate_grid_media(page, criteria)
    browser_type, retina_browser = browser_capabilities

    target_size = browser_type == :mobile && 75 || browser_type == :tablet && 250 || 300
    if page.max_size > 0 and ( target_size.nil? or target_size > page.max_size )
      target_size = page.max_size
    end

    smallest = nil

    list = criteria.map do |media|
      if !smallest or smallest > media.width
        smallest = media.width
      end

      {:media => media}
    end

    return [], "" if list.empty?

    if !target_size or target_size > smallest
      target_size = smallest
    end

    list.each do |data|
      data[:title] = data[:media].title if data[:media].title?

      url, width, height = data[:media].image_url(:width, target_size, true, retina_browser)
      data[:o], data[:ow], data[:oh] = url, width, height

      data[:bo], _, _ = data[:media].image_url

      data.delete(:media)
    end

    # Add pagination
    if page.max_media?
      total = criteria.count
      if total >= page.max_media
        num_pages = (page.max_media.to_f / page.per_page).ceil
      else
        num_pages = (total.to_f / page.per_page).ceil
      end
    end

    return list, paginate(criteria, :current_page => (criteria[:skip] / page.per_page) + 1, :num_pages => num_pages || criteria.num_pages, :per_page => page.per_page)
  end

  # ROW
  def generate_row_media(page, criteria)
    browser_type, retina_browser = browser_capabilities

    target_size = browser_type == :mobile && 350 || browser_type == :tablet && 500 || nil
    if page.max_size > 0 and ( target_size.nil? or target_size > page.max_size )
      target_size = page.max_size
    end

    list = criteria.map do |media|
      {:media => media}
    end

    return [], "" if list.empty?

    list.each do |data|
      data[:title] = data[:media].title if data[:media].title?

      url, width, height = data[:media].image_url(:width, target_size, true, retina_browser)
      data[:o], data[:ow], data[:oh] = url, width, height

      data.delete(:media)
    end

    # Add pagination
    if page.max_media?
      total = criteria.count
      if total >= page.max_media
        num_pages = (page.max_media.to_f / page.per_page).ceil
      else
        num_pages = (total.to_f / page.per_page).ceil
      end
    end

    return list, paginate(criteria, :current_page => (criteria[:skip] / page.per_page) + 1, :num_pages => num_pages || criteria.num_pages, :per_page => page.per_page, )
  end
end