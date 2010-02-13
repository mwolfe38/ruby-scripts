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
require 'logger'
require 'json'

LOGIN_URL='https://my.t-mobile.com/Login/MyTMobileLogin.aspx'
USAGE_URL='https://my.t-mobile.com/Services/account/accountservice.svc/GetAccountUseData'
CYCLE_URL='https://my.t-mobile.com/Billing/Services/BillingService.svc/GetAccountActivityData'
def get_usage_page(agent, phone_number, password)
  FileUtils.rm(['login_page.html', 'after_submit.html', 'usage_page.html'], :force=> true)
  agent.user_agent_alias = 'Linux Mozilla' 
  page = agent.get(LOGIN_URL)
  File.open('login_page.html', 'w') {|f| f.write(page.body)}
  form = page.form('Form1')
  if (!form || !form.has_field?('Login1:txtMSISDN'))
    puts 'Error, No phone number field in page'
    puts page.body
    exit
  end
  form['Login1:txtMSISDN'] = phone_number
  form['Login1:txtPassword'] = password
  form['__EVENTTARGET'] = 'Login1$btnLogin'  
  newpage=agent.submit(form)
  File.open('after_submit.html', 'w') {|f| f.write(newpage.body)}  
  agent.get_file(USAGE_URL)
end

def get_cycle_page(agent)   
   agent.get_file(CYCLE_URL)
end

def usage
  puts "Usage: ruby #{__FILE__} {t-mobile-password}"
end


phone_number='8057096943'
if (!ARGV[0])
  usage()
  exit
end
password = ARGV[0]

agent = WWW::Mechanize.new { |a| 
  a.log = Logger.new(STDERR)    
}


usage_json = get_usage_page(agent, phone_number,password)
usage = JSON.parse(usage_json)
pp usage

used = usage['UsedMins']
total= usage['TotalMins']
cycle_page = get_cycle_page(agent)
cycle = JSON.parse(cycle_page)
from = Date.strptime(cycle['BillCycleStartDate'], '%m/%d/%Y')
to = Date.strptime(cycle['BillCycleEndDate'], '%m/%d/%Y')
now = Date.today

billing_period_message =  'Billing Period: ' + from.to_s + ' to: ' + to.to_s
now = Date.today

usage_percent = ((used.to_f/total.to_f) * 100.0).round()
diff_to_end =  to - now
diff_from_start = now - from
diff_total = to - from
alert_message = ""
  days_used_percent = ((diff_from_start.to_f / diff_total.to_f) * 100).round()
  
  usage_message = "Usage: #{used} of #{total} minutes"

  if (usage_percent < 85)
    level = "--info"    
  elsif (usage_percent >= 85 && usage_percent < 100)
    alert_message = "CAREFUL - Your minutes are almost up\n"
    level = "--warning"
  else
    alert_message = "STOP USING YOUR PHONE, YOUR MINUTES ARE BEING BILLED at \\$0.45 per minute\n" 
    level = "--error"
  end   

  if (usage_percent > days_used_percent)
    usage_percent_message = "You are using minutes too fast, slow down."
    usage_percent_message += "\nWe are #{days_used_percent}% into month and you've used #{usage_percent}% of your minutes" 
    level = "--warning"
  else 
    usage_percent_message = "You are using your minutes at an acceptable rate."
  end

 msg = alert_message + "\n" + usage_message + "\n" + billing_period_message + "\n" + usage_percent_message + "\n"
puts msg
`zenity #{level} --text="#{msg}"`
