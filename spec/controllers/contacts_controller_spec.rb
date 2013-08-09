require "spec_helper"

describe ContactsController do
  before :all do
    @user = create(:flickr_user)
    @website = create(:website, :user => @user)
    @page = create(:contact_page, :website => @website, :user => @user, :send_to => "test@zapfol.io")
  end

  it "queues a mailer job" do
    Website.should_receive(:where).with({:domain => "http://test.host"}).and_return(mock("First", :first => @website))

    Resque.should_receive(:enqueue).once.with(Jobs::Mailer, hash_including(:fields => {"Foo" => "test", "Bar" => nil}, :receiver => "#{@user.full_name} <#{@page.send_to}>", :from => "john.doe@zapfol.io", :message => "Foo Bar Message"))

    post(:create, {:page_id => @page._id, :contact => {:message => "Foo Bar Message", :email => "john.doe@zapfol.io", @page.fields.first._id.to_s => "test"}})
    response.code.should == "302"
  end

  it "requires all fields to be filled out" do
    Website.should_receive(:where).with({:domain => "http://test.host"}).and_return(mock("First", :first => @website))

    Resque.should_not_receive(:enqueue)
    post(:create, {:page_id => @page._id, :contact => {:email => "john.doe@zapfol.io"}})
    response.code.should == "200"
    response.should render_template("pages/contact")
  end
end