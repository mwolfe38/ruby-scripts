##
# check_tmobile_minutes.rb
# This script will determine how many minutes are left on a t-mobile cell phone
# plan. This scripts works as of 10/10/2009
# It will only work in linux because the messages are reported with zenity
# (not sure if windows has a zenity port and i really don't care)
#
##

require 'rubygems'
require 'mechanize'
def get_usage_page(phone_number, password)
  a = WWW::Mechanize.new
  a.user_agent_alias = 'Mac Safari'
  login_url = 'https://my.t-mobile.com'
  usage_url = 'https://my.t-mobile.com/PartnerServices.aspx?service=eBill&link=MonthlyUsage';
  page = a.get(login_url)
  form = page.form('Form1')
  form['Login1:txtMSISDN'] = phone_number
  form['Login1:txtPassword'] = password
  form.add_field!('__EVENTTARGET','Login1$btnLogin')
  form.add_field!('__EVENTARGUMENT', '')
  newpage=a.submit(form)  
  a.get(usage_url)
end

phone_number='8057096943'
password = 'mattym38'
usage_page = get_usage_page(phone_number,password)
#usage_page = Nokogiri::HTML(File.open('usage.html', "r"))

minutes = usage_page.search('/html/body/div[2]/div[2]/div/div[3]/div/div/div[2]/div/div[3]/div/h3/span/text()')
if (minutes != nil && minutes[0] != nil && minutes[2] != nil)
  used = minutes[1].to_s.delete(':').strip.to_i
  total = minutes[2].to_s.delete('/').strip.to_i
  usage_percent = used.to_f/total.to_f
  msg = "you have used #{used} of #{total} minutes"
  if (usage_percent < 0.85)
    level = "--info"
  elsif (usage_percent >= 0.85 && usage_percent < 1.0)
    msg = "CAREFUL - Your minutes are almost up\n" + msg
    level = "--warning"
  else
    msg = "STOP USING YOUR PHONE, YOUR MINUTES ARE BEING BILLED at \\$0.45 per minute\n" +msg
    level = "--error"
  end
   
  puts "Usage percent is: " + usage_percent.to_s
else
  msg = "Unable to get t-mobile phone usage data"
  level = "--error"  
end
 puts msg + "\n"
`zenity #{level} --text="#{msg}"`