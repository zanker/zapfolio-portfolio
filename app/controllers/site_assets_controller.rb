class SiteAssetsController < ApplicationController
  layout false
  before_filter :quick_load_website, :except => [:robots, :sitemap]
  before_filter :load_website, :only => :sitemap

  def fragment
    if Rails.env.production? and @website.cache_bust["css"]
      response.etag = "#{@website._id}#{@website.cache_bust["css"]}#{params[:fragment]}"
      if request.fresh?(response)
        return head :not_modified
      end
    end

    # Just the header
    if params[:fragment] == "header"
      css = render_css(:layout => true, :footer => true)
    # Just the footer
    elsif params[:fragment] == "footer"
      css = render_css(:header => true, :layout => true)
    # Load the restyled layout
    elsif params[:fragment] == "restyle"
      css = render_restyled_layout(@website.css_base_layout)
    # Load a pure layout
    elsif CONFIG[:layouts].include?(params[:fragment])
      css = load_sass_file("layout_#{File.basename(params[:fragment])}")
    else
      return render :text => "", :status => :bad_request
    end

    render :content_type => "text/css", :text => css
  end

  def restyled_data
    unless CONFIG[:layouts].include?(params[:layout])
      return render :text => "", :status => :bad_request
    end

    # The variables for the layout we want to base our changes off of
    layout_variables = Rails.cache.fetch(rev_cache_key("css/vars/#{params[:layout]}"), :expires_in => 11.days) do
      sass = Rails.cache.fetch(rev_cache_key("css/raw/#{params[:layout]}", :css), :expires_in => 8.days) do
        File.read(Rails.root.join("app", "assets", "stylesheets", "layouts", "#{params[:layout]}.sass"))
      end.dup

      vars = {}

      # To allow the layouts to use Sass color helpers, we have to do a fake parse of the layout
      # and then manually go through and resolve all the variables to make sure we get the final values
      env = Sass::Environment.new

      engine = Sass::Engine.new(sass, ZapfolioPortfolio::Application.config.sass)
      engine.to_tree.children.each do |child|
        next unless child.is_a?(Sass::Tree::VariableNode)
        val = child.expr.perform(env)

        env.set_var(child.name, val)
        vars[child.name] = val.to_s
      end

      vars
    end

    # Parse the light template and convert it into a generic template we can gsub our variables into
    template = Rails.cache.fetch(rev_cache_key("css/templatedata", :css), :expires_in => 9.days) do
      sass = Rails.cache.fetch(rev_cache_key("css/raw/light", :css), :expires_in => 10.days) do
        File.read(Rails.root.join("app", "assets", "stylesheets", "layouts", "light.sass"))
      end.dup

      data = {"vars" => {}}

      index = 0
      sass.scan(/(\$([a-z_]+): .+)/).each do |line, key|
        var = "rgba(166,132,#{121 + (index += 1)},0.013)"

        sass.gsub!(line, "$#{key}: #{var}")
        data["vars"][key] = Regexp.escape(var)
      end

      data["css"] = Sass::Engine.new(sass, ZapfolioPortfolio::Application.config.sass.merge(:style => :compressed)).render
      data
    end

    render :json => {:fallback_vars => layout_variables, :template_vars => template["vars"], :css => template["css"]}
  end

  # Unfortunately, sitemap has to be absolute path, so this has to be dynamic
  def robots
    if request.host_with_port =~ /^demo\-([0-9]+).#{CONFIG[:regexp_domain]}/i
      render :text => "# Demo accounts cannot be spidered.\r\nUser-agent: *\r\nDisallow: /"
    else
      render :text => "User-agent: *\r\nSitemap: #{request.scheme}://#{request.host_with_port}/sitemap.xml"
    end
  end

  def sitemap
    if @website.demo? or !@website.seo_paid?
      return render :text => "", :status => :not_found
    end

    if Rails.env.production? and @website.cache_bust["gen"]
      response.etag = "#{@website._id}#{@website.cache_bust["gen"]}gen"
      response.cache_control[:public] = true
      if request.fresh?(response)
        return head :not_modified
      end
    end

    render :formats => :xml
  end

  def show
    if Rails.env.production? and @website.cache_bust["css"]
      response.etag = "#{@website._id}#{@website.cache_bust["css"]}show"
      expires_in 1.year, :public => true

      if request.fresh?(response)
        return head :not_modified
      end
    end

    render :content_type => "text/css", :text => render_css
  end

  private
  def quick_load_website
    @website = Website.where(:_id => params[:website_id].to_s).only(:cache_bust, :active_style, :custom_css, :css_tags, :css_layout, :width, :width_unit).first
    unless @website
      return render "pages/404", :status => :not_found
    end
  end

  def render_restyled_layout(layout)
    # Grab the variable file for the layout source
    sass = Rails.cache.fetch(rev_cache_key("css/raw/#{layout}", :css), :expires_in => 1.week) do
      File.read(Rails.root.join("app", "assets", "stylesheets", "layouts", "#{layout}.sass"))
    end.dup

    # Pull out all the variables for the layout
    sass.scan(/(\$([a-z_]+): .+)/).each do |line, key|
      next if @website.css_tags[key].blank?
      # Extra security check to make sure the tag we're putting is a hextag
      unless @website.css_tags[key] =~  /^(#([0-9a-z]{3}|[0-9a-z]{6})|rgba\([0-9]{1,3},[0-9]{1,3},[0-9]{1,3},[0-9]+(\.[0-9]+)?\))$/i
        next
      end

      sass.gsub!(line, "$#{key}: #{@website.css_tags[key]}")
    end

    Sass::Engine.new(sass, ZapfolioPortfolio::Application.config.sass).render
  end

  def render_css(skip={})
    contents = ""

    unless skip[:header]
      # CSS Reset
      contents << load_sass_file("reset")

      # The full width of the site
      contents << "#wrapper { max-width: #{@website.width}#{@website.width_unit}; }"
    end

    # Layout
    unless skip[:layout]
      if @website.active_style == Website::CUSTOM
        contents << @website.custom_css if @website.custom_css?
      elsif @website.active_style == Website::RESTYLE
        contents << render_restyled_layout(@website.css_base_layout)
      else
        contents << load_sass_file("layout_#{@website.css_layout}")
      end
    end

    unless skip[:footer]
      contents << load_sass_file("core_pages", true)
      contents << load_css_files("jquery.fancybox", "jquery.fancybox-thumbs")
    end

    contents
  end

  def load_css_files(*files)
    Rails.cache.fetch(rev_cache_key("css/#{files.join("/")}", :css), :expires_in => 6.days) do
      css = ""

      files.each do |file|
        if Rails.env.production?
          css << File.read(Rails.root.join("public", "assets", "libraries", "#{file}.css"))
        else
          css << File.read(Rails.root.join("app", "assets", "stylesheets", "libraries", "#{file}.css"))
        end
      end

      css
    end
  end

  def load_sass_file(file, dynamic=false)
    Rails.cache.fetch(rev_cache_key("sass/#{file}", :css), :expires_in => 12.days) do
      # Serve up the file we already have
      if Rails.env.production?
        File.read(Rails.root.join("public", "assets", "#{file}.css"))

      # Dynamic so we need to run it through ERB first
      elsif dynamic
        css = ERB.new(File.read(Rails.root.join("app", "assets", "stylesheets", "#{file}.sass.erb"))).result(binding)
        Sass::Engine.new(css, ZapfolioPortfolio::Application.config.sass).render

      # Nice and easy
      else
        if file =~ /^layout_([a-z]+)$/
          file.gsub!(/^layout_/, "layouts/")
        else
          file = File.basename(file)
        end

        Sass::Engine.new(File.read(Rails.root.join("app", "assets", "stylesheets", "#{file}.sass")), ZapfolioPortfolio::Application.config.sass).render
      end
    end
  end
end
