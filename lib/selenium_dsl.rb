require 'selenium-webdriver'
require 'selenium_dsl/commands'
require 'selenium_dsl/engines'
require 'selenium_dsl/modules'
require 'selenium_dsl/macros'
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
      @r_eng   = [/^(mock|debug|chrome|firefox|remote|visit|wait|quit|if)/]
      @r_mcr   = [/^\$[\-\w]+ *\=/,/^\$[\-\w]+[^\=]/]
      @r_cmd   = [/^(\>*([\-\w]*(\.[.\[\]\-\d\w]+|[#:][\-\d\w]+)|[\d\w]+)|\/\w+)(\[\d+\])*/,/^[~]\w+/]
      @r_mod   = [/^(def +|end)/]
      @r_fnc   = [/^ *\w+.*/]
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
      @opt = opt.strip
      puts "OPT: #{@opt}" if @opt!=''
      codes = codes.split(/\n/)
      @code[@path] = 
      {
        :macro => {},
        :code  => codes,
        :vars  => {},
        :line  => 0  
      }
      
      while (line = _line_)
        stx = parse_mod(line)
        stx = parse_mcr(line) if !stx
        stx = parse_eng(line) if !stx
        stx = parse_cmd(line) if !stx
        stx = parse_fnc(line) if !stx
      end
      print "\n"
    end

    private

    def _code_
      @code[@path]
    end

    def _line_
      while (@path.scan('/')!=[])
        c = @code[@path]
        l = c[:line]
        break if c[:code][l]
        @path.sub!(/\/\w+$/,'')
      end
      c = @code[@path]
      l = c[:line]
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
