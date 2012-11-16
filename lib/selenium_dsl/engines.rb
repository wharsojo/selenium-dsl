class SeleniumDsl
  module Engines
    def engines
      SeleniumDsl::Engines.private_instance_methods.collect do |x|
        "#{x[1,99]}"
      end
    end

    def in_engines?(cmd)
      engines.index(cmd) ? cmd : nil
    end

    def parse_eng(line)
      arr = match_line(@r_eng,line.strip,'eng')
      cmd,prm = arr
      if (exc = in_engines?(cmd[0]))
        puts "#{@path}>eng: #{arr.inspect}" if opt_v
        send("_#{exc}",prm) if !@mock
        true
      else
        false
      end
    end

    private
    def _chrome(prm)
      @driver = Selenium::WebDriver.for :chrome
    end

    def _firefox(prm)
      @driver = Selenium::WebDriver.for :firefox 
    end

    def _remote(prm)
      @driver = Selenium::WebDriver.for(:remote, :url => "http://localhost:8080")
    end

    def _mock(prm)
      @mock = true
    end

    def _debug(prm)
      binding.pry
    end

    def _visit(prm)
      _init('') if !@driver
      @driver.get(prm)
    end

    def _wait(prm)
      wait = Selenium::WebDriver::Wait.new(:timeout => 10) 
      wait.until { @driver.find_element(:css,'title').text =~ /#{prm}/ }
    end

    def _quit(prm)
      @driver.quit
    end

    def _if(prm)
      splt = prm[/(<|>|=)=|(=|!)~/]
      nest = 0
      line = prm.split(splt,2)
      if line.length==2
        if !(parse_cmd(line[0]) && eval("\"#{@return}\" #{splt} /#{line[1]}/"))
          while (line = _line_)
            nest += 1 if line.strip =~ /^if/
            if (line.strip =~ /^end$/)
              break if nest==0
              nest -=1
            end
          end
        end
      end
    end

  end
end
