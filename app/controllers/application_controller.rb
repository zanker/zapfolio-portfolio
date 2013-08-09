class ApplicationController < ActionController::Base
  protect_from_forgery

  if Rails.env.production?
    rescue_from ActionController::MethodNotAllowed do |r| redirect_to "/" end
    rescue_from Exception, :with => :server_error
  end

  private
  def server_error(exception)
    notify_airbrake(exception)

    if @website
      render "pages/500", :formats => [:html], :status => :server_error
    else
      render "public/500", :formats => [:html], :status => :server_error, :layout => false
    end
  end

  # Find which website is theirs and do any redirects needed
  def load_website
    host = request.host_with_port

    # Load by subdomain
    if host =~ /(.+?)\.#{CONFIG[:regexp_domain]}/i
      @website = Website.where(:subdomain => $1.to_s).first
      if @website and @website.domain? and @website.domain_paid? and !request.ssl?
        return redirect_to @website.domain
      end

    # Load by domain
    else
      @website = Website.where(:domain => "http://#{host}").first

      # Domain expired, redirect them to the subdomain
      if @website and !@website.domain_paid?
        return redirect_to "http://#{@website.subdomain}.#{CONFIG[:domain]}", :status => :found
      end
    end

    unless @website
      # If the host isn't set, or it's not a Zapfolio subdomain, or it's a chained subdomain (a.b.zapfol.io)
      # we redirect to the blank page and not the upsell one.
      if host.blank? or host !~ /#{CONFIG[:regexp_domain]}/i or host =~ /.+?\..+?\.#{CONFIG[:regexp_domain]}/i
        return redirect_to "#{CONFIG[:manager_site]}/no-site", :status => :found
      else
        return redirect_to "#{CONFIG[:manager_site]}/no-site?url=#{CGI::escape(host.to_s)}", :status => :found
      end
    end

    # Switch into editor mode
    if params[:editing] and @website.edit_key == params[:editing]
      @editor_mode = true
    # Don't allow SSL requests if we aren't in editor mode
    elsif request.ssl?
      return redirect_to @website.full_url, :status => host =~ /(.+?)\.#{CONFIG[:regexp_domain]}/i ? :found : :moved_permanently
    end
  end
end
