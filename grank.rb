#!/usr/bin/ruby
require 'rubygems'
require 'open-uri'
require 'hpricot'

search = URI.escape("slide out shelves")
search_for_domain = "wolfehomeservices.com"
found = false
page_num = 0
max_pages = 20
while found == false and page_num < max_pages
   result_num = page_num * 10
   elements = Hpricot.parse(open("http://www.google.com/search?q=#{search}&start=#{result_num}&sa=N")).search("ol li.g h3.r a")
   elements.each do | el |
     host = URI.parse(el.attributes['href']).host
     if (host.include?(search_for_domain) or search_for_domain.include?(host))
         found = true
         break
     end
   end
   if (found)
     puts "Found on page #{page_num}"
   end
   page_num += 1
end
puts "search #{search} was not found within #{max_pages}"
