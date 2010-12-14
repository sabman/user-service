describe 'client' do
  before(:each) do
    User.base_url = "http://localhost:3000"
  end

  it "should get a user" do
    user = User.find_by_name('shoaib')
    user['name'].should == 'shoaib'
    user['email'].should == 'shoaib@nomad-labs.com'
    user['bio'].should == 'spatial dude'
  end

  it "should return nil for a user not found" do
    User.find_by_name('gosling').should be_nil
  end

  it "should create a user" do
    user = User.create({:name => 'trotter', :email => 'no spam', :password => 'whatever'})
    user['name'].should == 'trotter'
    user['email'].should == 'no spam'
    User.find_by_name('trotter').should == user
  end
end
