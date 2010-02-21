require 'net/http'
require 'uri'
require 'hpricot'

def print_matches(page)
   body = Hpricot.parse((Net::HTTP.get_response URI.parse(page)).body)
   (body/:blockquote/:p).each do | entry |
      match = /.*carpinteria.*/i.match(entry.inner_text)
      if (match != nil) 
         print (match.to_s + "\n")
      end
   end
end
total_pages=3
static_pages = ['http://santabarbara.craigslist.org/apa/']

static_pages.each do | url |
   print "Page 1:\n"
   print_matches url
   for i in [100,200,300,400,500] 
      print "Page " + ((i/100)+1).to_s + ":\n"
      print_matches (url + "index" + i.to_s + ".html")      
   end
end
