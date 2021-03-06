require 'selenium-webdriver'
require 'selenium_dsl/commands'
require 'selenium_dsl/engines'
require 'selenium_dsl/modules'
require 'selenium_dsl/macros'
require 'pry' if ARGV[1]=~/\-.*[d]/

require 'term/ansicolor'
include Term::ANSIColor

class SeleniumDsl
  class << self
    include Commands
    include Engines
    include Modules

    def init
      nodes    = /^(\>*([\-\w]*(\.[.\[\]\-\d\w]+|[#:][\-\d\w]+)|\w+(\[\w+\=[\d\w"]+\])*)|\/[\w@"=\[\]]+)(\[\d+\])*/
      action   = /^[~@]\w+(\:\w+)*/
      @driver  = nil
      @nodes   = nil
      @return  = nil
      @mock    = false 
      @code    = {}
      @path    = '~'
      @opt     = []
      @r_eng   = [/^(debug|chrome|firefox|phantomjs|remote|resize|visit|wait|quit|if|screenshot|sleep)/] #mock|debug|
      @r_mcr   = [/^\$[\-\w]+ *\=/,/^\$[\-\w]+[^\=]/]
      @r_cmd   = [nodes, action]
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
      @opt  = opt
      codes = codes.split(/\n/)
      puts "OPT: #{@opt}" if opt
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
      @driver.quit if opt_q && @driver
      print "\n"
    end

    private

    def opt_d
      (opt=@opt.select{|x|x=~/\-\w*[d]/})==[] ? nil : opt[0]
    end

    def opt_m
      (opt=@opt.select{|x|x=~/\-\w*[m]/})==[] ? nil : opt[0]
    end

    def opt_q
      (opt=@opt.select{|x|x=~/\-\w*[q]/})==[] ? nil : opt[0]
    end

    def opt_r
      (opt=@opt.select{|x|x=~/\-\w*[r]/})==[] ? nil : opt[0]
    end

    def opt_s
      (opt=@opt.select{|x|x=~/\-\w*[s]/})==[] ? nil : opt[0]
    end

    def opt_t
      (opt=@opt.select{|x|x=~/\-\w*[t]/})==[] ? nil : opt[0]
    end

    def opt_v
      (opt=@opt.select{|x|x=~/\-\w*[v]/})==[] ? nil : opt[0]
    end

    def _code_
      @code[@path]
    end

    # try to the next line of code
    def _line_
      # change path up if eol of code
      while (@path.scan('/')!=[])
        c = @code[@path]
        l = c[:line]
        break if c[:code][l]
        @path.sub!(/\/\w+$/,'')
      end
      c = @code[@path]
      l = c[:line]
      while c[:code][l] && c[:code][l].to_s.strip=='' #next line should not empty
        l= (c[:line]+=1)
        p "L: #{l}"
      end
      if c[:code][l] # not eol?
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

    def failed
      print (opt_m ? 'F' : 'F'.red) if !opt_v
      c = _code_
      l = c[:line]
      r = c[:code]
      y = 2
      e = "\n=====>>>>ASSERT FAILED!!!<<<<====="
      puts (opt_m ? e : e.yellow)
      y.times do |idx|
        no = (l-y)+idx
        tx = "#{r[no]}#{idx<(y-1) ? '' : ' ...Error'}"
        tx = (idx<(y-1) ? tx.green : tx.red) if !opt_m
        puts "#{no+1}. #{tx}"
      end
      puts "#{l+1}. #{r[l]}" if r[l]
      if (opt=opt_s)
        if (arr=opt.split(':',2)).length>1
          @driver.save_screenshot("#{arr[1]}.png") 
        else
          @driver.save_screenshot("#{ARGV[0]}-error_#{l}.png")
        end
      end
      @driver.quit if opt_q && @driver
      puts caller if opt_t
      Kernel.exit(1)
    end
  end
end
