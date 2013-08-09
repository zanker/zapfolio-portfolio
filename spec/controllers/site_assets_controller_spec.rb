require "spec_helper"

describe SiteAssetsController do
  render_views

  before :all do
    @user = create(:flickr_user)
    @website = create(:website, :user => @user, :seo_paid => true)
    @other_site = create(:website)
  end

  it "renders the header fragment" do
    get(:fragment, {:website_id => @website._id, :fragment => "header"})
    response.code.should == "200"
    response.content_type.should == "text/css"
    response.body.blank?.should_not be_true
  end

  it "renders the footer fragment" do
    get(:fragment, {:website_id => @website._id, :fragment => "footer"})
    response.code.should == "200"
    response.content_type.should == "text/css"
    response.body.blank?.should_not be_true
  end

  it "renders a simple robots.txt" do
    get(:robots)
    response.code.should == "200"
    response.body.should == "User-agent: *\r\nSitemap: http://test.host/sitemap.xml"
  end

  it "renders a sitemap" do
    Website.should_receive(:where).with({:domain => "http://test.host"}).and_return(mock("First", :first => @website))

    valid_page = nil
    Timecop.freeze(2012, 4, 8, 10, 41, 20) do
      valid_page = create(:page, :website => @website, :user => @user, :status => Page::PUBLIC)
      create(:page, :website => @website, :user => @user, :status => Page::PRIVATE)
      create(:page, :website => @other_site, :status => Page::PUBLIC)
    end

    get(:sitemap)
    response.code.should == "200"
    response.body.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<urlset xmlns='http://www.sitemaps.org/schemas/sitemap/0.9'>\n<url>\n<loc>http://test.host/#{valid_page.slug}</loc>\n<lastmod>2012-04-08T17:41:20+00:00</lastmod>\n<priority>0.5</priority>\n</url>\n</urlset>\n"
  end

  CONFIG[:layouts].each do |layout|
    it "renders a #{layout} layout fragment" do
      get(:fragment, {:website_id => @website._id, :fragment => layout})
      response.code.should == "200"
      response.content_type.should == "text/css"
      response.body.blank?.should_not be_true
    end

    it "renders a restyled #{layout} layout fragment" do
      @website.set(:css_base_style => layout)
      get(:fragment, {:website_id => @website._id, :fragment => "restyle"})
      response.code.should == "200"
      response.content_type.should == "text/css"
      response.body.blank?.should_not be_true
    end

    it "returns the restyle data for #{layout}" do
      get(:restyled_data, {:website_id => @website._id, :layout => layout})
      response.code.should == "200"

      data = JSON.parse(response.body)
      data["css"].blank?.should_not be_true
      data["fallback_vars"].should have_at_least(1).item
      data["template_vars"].should have_at_least(1).item
    end

    it "renders an entire stylesheet" do
      get(:show, {:website_id => @website._id})
      response.code.should == "200"
      response.content_type.should == "text/css"
      response.body.blank?.should_not be_true
    end
  end

  it "errors on invalid layout" do
    get(:fragment, {:website_id => @website._id, :fragment => "foo"})
    response.code.should == "400"
  end

  it "errors on a restyled layout" do
    get(:restyled_data, {:website_id => @website._id, :layout => "foo"})
    response.code.should == "400"
  end
end