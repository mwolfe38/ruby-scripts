#!/usr/bin/ruby
require 'rubygems'
require 'open-uri'
require 'hpricot'

def print_usage()
   puts "usage: " + $FILENAME + "\"search\" domain"
end
if (ARGV.length < 2) 
  print_usage()
  exit   
end
search = URI.escape(ARGV[0])
search_for_domain = ARGV[1] 
found = false
page_num = 0
max_pages = 20
while found == false and page_num < max_pages
    page_num += 1
   result_num = (page_num-1) * 10
   elements = Hpricot.parse(open("http://www.google.com/search?q=#{search}&start=#{result_num}&sa=N")).search("ol li.g h3.r a")
   elements.each do | el |
     host = URI.parse(el.attributes['href']).host rescue next 
     if (host.include?(search_for_domain) or search_for_domain.include?(host))
         found = true
         break
     end
   end
   if (found)
     puts "Found on page #{page_num}"
     exit
   end
  
end
puts "search #{search} was not found within #{max_pages}"
