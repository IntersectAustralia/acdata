require 'digest'
def generate_secret_task
  file_name = "#{Rails.root.join('config','initializers','secret_token.rb')}"
  chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ0123456789~`!@#$%^&*()_+|}{/][;'
  password = ''
  100.times { password << chars[rand(chars.size)] }
  sha512 = Digest::SHA512.new
  sha512.update(password)
  text = File.read(file_name)
  File.open(file_name, "w") {|file| file.puts text.gsub(/REPLACE_THIS_WITH_REAL_GOOD_RANDOM_STRING/, sha512.hexdigest)}
end