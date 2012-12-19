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
      profile = Selenium::WebDriver::Chrome::Profile.new
      @driver = Selenium::WebDriver.for :chrome, :profile => profile 
      if (opr=opt_r) && opr=~/[:]/
        res = opr.sub(/.*[:]/,'').split('x',2).collect{|x|x.to_i}
        @driver.manage.window.size=Selenium::WebDriver::Dimension.new(*res)
      end
    end

    def _firefox(prm)
      profile = Selenium::WebDriver::Firefox::Profile.new
      profile['browser.cache.disk.enable']       = false
      @driver = Selenium::WebDriver.for :firefox, :profile => profile 
      if (opr=opt_r) && opr=~/[:]/
        res = opr.sub(/.*[:]/,'').split('x',2).collect{|x|x.to_i}
        @driver.manage.window.size=Selenium::WebDriver::Dimension.new(*res)
      end
    end

    def _phantomjs(prm)
      prm = "http://localhost:8080" if prm==''
      @driver = Selenium::WebDriver.for(:remote, :url => prm)
    end

    def _remote(prm)
      prm = "http://localhost:4444/wd/hub/" if prm==''
      @driver = Selenium::WebDriver.for(:remote, :url => prm)
    end

    def _resize(prm)
      res = prm.split('x',2).collect{|x|x.to_i}
      @driver.manage.window.size=Selenium::WebDriver::Dimension.new(*res)
    end

    def _screenshot(prm)
      @driver.save_screenshot(prm)
    end

    def _mock(prm)
      @mock = true
    end

if ARGV[1]=~/\-.*[d]/
    def _debug(prm)
      binding.pry
    end
end

    def _visit(prm)
      _firefox('') if !@driver
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
