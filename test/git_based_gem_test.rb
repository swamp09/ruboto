require File.expand_path('test_helper', File.dirname(__FILE__))
require 'bigdecimal'
require 'test/app_test_methods'

class GitBasedGemTest < Test::Unit::TestCase
  def setup
    generate_app
    Dir.chdir APP_DIR do
      File.open('Gemfile.apk', 'w') do |f|
        f << "source 'https://rubygems.org/'\n\n"
        f << "gem 'gosu_android', :git => 'https://github.com/Garoe/gosu-android.git'"
      end
    end
  end

  def teardown
    cleanup_app
  end

  def test_gosu
    Dir.chdir APP_DIR do
      File.open('src/ruboto_test_app_activity.rb', 'w') { |f| f << <<EOF }
require 'ruboto/widget'
require 'gosu'

ruboto_import_widgets :LinearLayout, :ListView, :TextView

class RubotoTestAppActivity
  def onCreate(bundle)
    super
    setTitle 'Gosu loaded OK!'

    self.content_view =
        linear_layout :orientation => :vertical, :gravity => :center do
          text_view :id => 42, :text => title, :text_size => 48.0, :gravity => :center
        end
  end
end
EOF

      File.open('test/src/ruboto_test_app_activity_test.rb', 'w') { |f| f << <<EOF }
activity Java::org.ruboto.test_app.RubotoTestAppActivity

setup do |activity|
  start = Time.now
  loop do
    @text_view = activity.findViewById(42)
    break if @text_view || (Time.now - start > 60)
    sleep 1
  end
  assert @text_view
end

test("activity starts") do |activity|
  assert_equal 'Gosu loaded OK!', @text_view.text.to_s
end
EOF

    end

    run_app_tests
  end

end
