class ContactsController < ApplicationController
  before_filter :load_website

  def create
    @page = ContactPage.public.where(:website_id => @website._id, :_id => params[:page_id].to_s).first
    return redirect_to "/" unless @page

    queue = {:fields => {}, :from => params[:contact][:email], :message => params[:contact][:message]}

    # Who we're sending this to
    user = User.where(:_id => @website.user_id).only(:full_name, :email).first
    if @page.send_to?
      queue[:receiver] = "#{user.full_name} <#{@page.send_to}>".strip
    else
      queue[:receiver] = "#{user.full_name} <#{user.email}>".strip
    end

    # Validate everything
    error = params[:contact][:email].blank?

    @page.fields.each do |field|
      if field.required and params[:contact][field._id.to_s].blank?
        error = true
        break
      else
        queue[:fields][field.name] = params[:contact][field._id.to_s]
      end
    end

    if error
      render "pages/contact"
    else
      Resque.enqueue(Jobs::Mailer, queue)
      redirect_to "/#{@page.slug}", :notice => :queued
    end
  end
end
