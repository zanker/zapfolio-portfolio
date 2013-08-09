class PagesController < ApplicationController
  before_filter :load_website

  def login
    @page = @website.pages.public.where(:_id => params[:page_id].to_s, :encrypted_password.exists => true).first
    unless @page
      return render "404", :status => :not_found
    end

    password = BCrypt::Password.new(@page.encrypted_password)
    if password != params[:login][:password]
      return render :password, :status => :bad_request
    end

    cookies.signed["pass_#{@page._id}"] = @page.encrypted_password
    redirect_to "/#{@page.slug}"
  end

  def show
    if params[:action] == "show"
      @page = @website.pages.public.where(:slug => CGI::unescape(params[:a]).to_s).first
    elsif @website.home_page_id?
      @page = @website.pages.public.where(:_id => @website.home_page_id).first
      # Default to a page if no home page is set
      @page = @website.pages.public.first unless @page
    else
      return redirect_to "#{CONFIG[:manager_site]}/#{@website._id}/not-setup", :status => :found
    end

    unless @page
      return render "404", :status => :not_found
    end

    # Check for caching
    response.etag = "#{@website._id}#{@website.cache_bust["js"]}#{@website.cache_bust["css"]}#{@website.cache_bust["gen"]}#{@page.updated_at}#{@page.data_updated_at}#{@page.slug}"
    response.cache_control[:public] = true
    if request.fresh?(response)
      return head :not_modified
    end

    # Passworded?
    if @page.encrypted_password?
      if cookies.signed["pass_#{@page._id}"] != @page.encrypted_password
        @login_required = true
        return render :password
      end
    end

    # Pure static page that the user can configure
    if @page.instance_of?(StaticPage)
      render :static
    # Album page with media
    elsif @page.kind_of?(MediaPage)
      render "media_#{@page.display_type}"
    # Static page with a fancy image attached
    elsif @page.instance_of?(AboutPage)
      render :about
    # Contact page with some static text
    elsif @page.instance_of?(ContactPage)
      render :contact
    # Simple redirect to a predefined page
    elsif @page.instance_of?(RedirectPage)
      redirect_to @page.location, :status => :moved_permanently
    end
  end

  alias home show
end
