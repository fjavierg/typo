# Install hook code here

directory = File.join(::Rails.root.to_s, '/vendor/plugins/easy-ckeditor/')
require "#{directory}lib/ckeditor_file_utils"
require "#{directory}lib/ckeditor_version"
require "#{directory}lib/ckeditor"

puts "** Installing Easy CKEditor Plugin version #{CkeditorVersion.current}...."

CkeditorFileUtils.destroy_and_install

puts "** Successfully installed Easy CKEditor Plugin version #{CkeditorVersion.current}"
