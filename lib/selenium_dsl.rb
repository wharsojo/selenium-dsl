require 'selenium-webdriver'
require 'selenium_dsl/commands'
require 'selenium_dsl/engines'
require 'selenium_dsl/modules'
require 'pry'

require 'term/ansicolor'
include Term::ANSIColor

class SeleniumDsl
  class << self
    include Commands
    include Engines
    include Modules

    def init
      @driver  = nil
      @nodes   = nil
      @return  = nil
      @mock    = false 
      @code    = {}
      @path    = '~'
      @opt     = ''
      # @r_cmd   = [/^(\w+|\>([#.:]\w+|\w+)|[#.:])\w+|\/\w+(\[\d+\])*/,/[~]\w+/]
      # @r_cmd   = [/^(\>*([#.:]\w+|\w+)|\/\w+(\[\d+\])*)/,/[~]\w+/]
      # @r_cmd   = [/^(\>*([#.:]\w+|\w+)|\/\w+)(\[\d+\])*/,/[~]\w+/]
      @r_eng   = [/^(mock|debug|chrome|firefox|remote|visit|wait|quit|if)/]
      @r_cmd   = [/^(\>*([\-a-zA-z]*(\.[.\-a-zA-z]+|[#:]\w+)|\w+)|\/\w+)(\[\d+\])*/,/^[~]\w+/]
      @r_mod   = [/^(def +|end)/]
      @r_fnc   = [/^ *\w+.*/] #/^(\w+|\w+ .*)$/
    end

    def match_line(rgx,str,id='')
      str2 = str
      arr = rgx.collect do |r|
        rtn = []
        while (x=str[r]) 
          str = str[x.length,255].strip
          rtn << x.strip
        end
        rtn
      end << str
      arr
    end

    def parser(codes, opt='')
      init if !@driver
      @opt = opt
      puts "OPT: #{@opt}"
      codes = codes.split(/\n/)
      @code[@path] = 
      {
        :code => codes,
        :vars => {},
        :line => 0  
      }
      
      while (line = _line_)
        stx = parse_mod(line)
        stx = parse_eng(line) if !stx
        stx = parse_cmd(line) if !stx
        stx = parse_fnc(line) if !stx
      end
      print "\n"
    end

    private

    def _line_
      while (@path.scan('/')!=[])
        c = @code[@path]
        l = c[:line]
        break if c[:code][l]
        @path.sub!(/\/\w+$/,'')
      end
      # p "PAAAAATH: #{@path}"
      c = @code[@path]
      l = c[:line]
      # binding.pry
      if c[:code][l]
        while c[:code][l].to_s.strip==''
          l= (c[:line]+=1)
        end
        c[:line]+=1
        c = Marshal.load( Marshal.dump(c) )
        @line = c
        v = c[:vars]
        r = c[:code][l]
        v.each do |k,v|
          r.gsub!("&#{k}",v)
        end
        r
      else
        nil
      end
    end

    def opt_v
      @opt=~/\-[v]/
    end

  end
end
# codes = <<EOD
# def searching q=selenium web driver
#   visit http://google.com
#   :q=&q
#   :btnG~click
#   wait &q
# end
# searching
# searching dodol/garut
# EOD
# SeleniumDsl.parser(codes)
# if title~text=~MAP
# end
# searching
# li.g>a~click
# wait Selenium
# #q=css
# #submit~click

# codes.split(/\n/).each do |line|
#   stx = SeleniumDsl.match_line(r_eng,line.strip)
#   stx = SeleniumDsl.match_line(r_cmd,line.strip)if !stx[1][0]
#   puts stx.inspect
# end

# :login       = wowo kereen
# :password    = password01
# .s.b#s~click
# .wow.kereen~value=123
# if .wow~html==dodol
#   .wow~html=123
# else
#   .wow~html=3
# end

# driver = Selenium::WebDriver.for :firefox
# driver.get "http://google.com"

# element = driver.find_element :name => "q"
# element.send_keys "Cheese!"
# element.submit

# puts "Page title is #{driver.title}"

# wait = Selenium::WebDriver::Wait.new(:timeout => 10)
# wait.until { driver.title.downcase.start_with? "cheese!" }

# puts "Page title is #{driver.title}"
# driver.quit
