require 'spec_helper'

class String
  # Helper function for cleaning up HEREDOCs intended for use with HAML/SASS,
  # turning "    %h1\n      Hi" into "%h1\n  Hi".
  def fix_indent
    gsub /^#{lines.first[/^ */]}/, ""
  end
end

describe "haml-server" do
  let(:app) { Sinatra::Application }

  around :each do |example|
    Dir.mktmpdir do |temp_dir|
      Dir.chdir temp_dir do
        set :public_folder, temp_dir
        set :views, temp_dir

        example.run
      end
    end
  end

  it "routes '/' to '/index.haml'" do
    file "index.haml", "%h1 Hello world!"

    get '/'

    last_response.body.should include("<h1>Hello world!</h1>")
  end

  it "renders nested paths" do
    file "deeply/nested/path.haml", "Hi!"

    get '/deeply/nested/path'

    last_response.body.should include("Hi!")
  end

  it "automatically renders 'layout.haml'" do
    file "howdy.haml", "%h2 Howdy"
    file "layout.haml", <<-HAML
      %h1 Hello world!
      = yield
    HAML

    get '/howdy'

    last_response.body.should include("<h2>Howdy</h2>")
    last_response.body.should include("<h1>Hello world!</h1>")
  end

  it "throw execption for bad HAML" do
    file "bad.haml", "%"

    expect {
      get '/bad'
    }.to raise_error(Haml::SyntaxError)

    # will be handled and displayed via Rack
  end

  it "renders static files" do
    file "test.html", "<h1>Hi</h1>"

    get '/test.html'

    last_response.body.should include("<h1>Hi</h1>")
  end

  it "routes '/screen.css' to '/screen.sass'" do
    file "screen.sass", <<-SASS
      .content
        display: block
    SASS

    get '/screen.css'

    last_response.body.should == <<-CSS.fix_indent
      .content {
        display: block; }
    CSS
  end

  it "prints SASS compilation errors in the response" do
    file "bad.sass", <<-SASS
      bad(
    SASS

    get '/bad.css'

    last_response.status.should eq(502)
    last_response.body.should include('Sass::SyntaxError')
  end

  context "helpers" do
    before do
      file "helpers.haml", "= link_to 'test', '/test'"
      file "helpers.rb", <<-RUBY
      def link_to(text, uri)
        %Q(<a href="\#{uri}">\#{text}</a>)
      end
      RUBY
    end

    it "loads helper methods" do
      get '/helpers'
      last_response.body.should include(%q(<a href="/test">test</a>))
    end

    it "reloads helper methods" do
      get '/helpers'
      last_response.body.should include(%q(<a href="/test">test</a>))

      file "helpers.rb", <<-RUBY
      def link_to(text, uri)
        %Q(<a class="button" href="\#{uri}">\#{text}</a>)
      end
      RUBY

      get '/helpers'
      last_response.body.should include(%q(<a class="button" href="/test">test</a>))
    end

    it "cleans up old helper methods" do
      get '/helpers'
      last_response.body.should include(%q(<a href="/test">test</a>))

      file "helpers.rb", <<-RUBY
      def other_helper() end
      RUBY

      lambda { get '/helpers' }.should raise_exception(NoMethodError)
    end
  end

  def file(name, content)
    FileUtils.mkdir_p File.dirname(name)

    File.open name, "w" do |f|
      f.write content.fix_indent
    end
  end
end
