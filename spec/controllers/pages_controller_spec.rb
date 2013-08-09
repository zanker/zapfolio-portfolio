require "spec_helper"

describe PagesController do
  render_views

  before :all do
    @user = create(:flickr_user)
    @website = create(:website, :user => @user)
  end

  context "login" do
    before :all do
      @page = create(:static_page, :user => @user, :website => @website, :password => "123123", :password_confirmation => "123123")
    end

    it "attempts to login and fails" do
      Website.should_receive(:where).with({:domain => "http://test.host"}).and_return(mock("First", :first => @website))

      post(:login, {:page_id => @page._id, :login => {:password => "foobar"}})
      response.code.should == "400"
      response.should render_template("pages/password")
    end

    it "logins to the page" do
      Website.should_receive(:where).with({:domain => "http://test.host"}).and_return(mock("First", :first => @website))

      post(:login, {:page_id => @page._id, :login => {:password => "123123"}})
      response.should redirect_to("/#{@page.slug}")

      auth_cookie = response.cookies["pass_#{@page._id}"]
      auth_cookie.should_not be_nil

      auth_cookie = Base64.decode64(auth_cookie.split("--").first)
      Marshal.load(auth_cookie).should == @page.encrypted_password
    end

    it "renders a password protected page" do
      Website.should_receive(:where).with({:domain => "http://test.host"}).and_return(mock("First", :first => @website))

      get(:show, {:a => @page.slug})
      response.code.should == "200"
      response.should render_template("pages/password")
    end
  end

  it "renders a redirect page" do
    Website.should_receive(:where).with({:domain => "http://test.host"}).and_return(mock("First", :first => @website))

    page = create(:redirect_page, :user => @user, :website => @website)
    get(:show, {:a => page.slug})
    response.code.should == "301"
    response.should redirect_to(page.location)
  end

  it "renders a static page" do
    Website.should_receive(:where).with({:domain => "http://test.host"}).and_return(mock("First", :first => @website))

    page = create(:static_page, :user => @user, :website => @website)
    get(:show, {:a => page.slug})
    response.code.should == "200"
    response.should render_template("pages/static")
  end

  it "renders a contact page" do
    Website.should_receive(:where).with({:domain => "http://test.host"}).and_return(mock("First", :first => @website))

    page = create(:contact_page, :user => @user, :website => @website, :send_to => "foo@zapfol.io")
    get(:show, {:a => page.slug})
    response.code.should == "200"
    response.should render_template("pages/contact")
  end

  it "renders an about page" do
    Website.should_receive(:where).with({:domain => "http://test.host"}).and_return(mock("First", :first => @website))

    page = create(:about_page, :user => @user, :website => @website, :pic_side => AboutPage::RIGHT, :picture => File.new(Rails.root.join("app", "assets", "images", "lightbox", "blank.gif")))
    get(:show, {:a => page.slug})
    response.code.should == "200"
    response.should render_template("pages/about")
  end

  context "renders a media" do
    before :all do
      @album = create(:flickr_album, :user => @user)
      create(:flickr_photo, :user => @user, :album_ids => [@album._id])
    end

    it "carousel page" do
      Website.should_receive(:where).with({:domain => "http://test.host"}).and_return(mock("First", :first => @website))

      page = create(:media_carousel_page, :user => @user, :website => @website, :album_ids => [@album._id])
      get(:show, {:a => page.slug})
      response.code.should == "200"
      response.should render_template("pages/media_carousel")
    end

    it "grid page" do
      Website.should_receive(:where).with({:domain => "http://test.host"}).and_return(mock("First", :first => @website))

      page = create(:media_grid_page, :user => @user, :website => @website, :album_ids => [@album._id])
      get(:show, {:a => page.slug})
      response.code.should == "200"
      response.should render_template("pages/media_grid")
    end

    it "horizontal row page" do
      Website.should_receive(:where).with({:domain => "http://test.host"}).and_return(mock("First", :first => @website))

      page = create(:media_row_page, :user => @user, :website => @website, :album_ids => [@album._id], :grow_in => MediaRowPage::HORIZONTAL)
      get(:show, {:a => page.slug})
      response.code.should == "200"
      response.should render_template("pages/media_row")
    end

    it "vertical row page" do
      Website.should_receive(:where).with({:domain => "http://test.host"}).and_return(mock("First", :first => @website))

      page = create(:media_row_page, :user => @user, :website => @website, :album_ids => [@album._id], :grow_in => MediaRowPage::VERTICAL)
      get(:show, {:a => page.slug})
      response.code.should == "200"
      response.should render_template("pages/media_row")
    end
  end
end