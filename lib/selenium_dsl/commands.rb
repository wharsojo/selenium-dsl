class SeleniumDsl
  module Commands
    def commands
      SeleniumDsl::Commands.private_instance_methods.collect do |x|
        "#{x[1,99]}"
      end
    end

    def in_commands?(cmd)
      if cmd[0]
        c = cmd[0][1,99]
        commands.index(c) ? c : nil
      else
        nil
      end
    end

    def find_element(typ,el)
      wait = Selenium::WebDriver::Wait.new(:timeout => 10) 
      wait.until { @nodes = @nodes.find_element(typ, el) }
      print '.'.green if !opt_v
    rescue Exception => e
      print 'F'.red if !opt_v
      @driver.execute_script("return alert(arguments[0]+'')", e.message)
    end

    def find_elements(typ,el,idx)
      wait = Selenium::WebDriver::Wait.new(:timeout => 10) 
      wait.until { @nodes = @nodes.find_elements(typ, el)[idx-1] }
      print '.'.green if !opt_v
    rescue Exception => e
      print 'F'.red if !opt_v
      @driver.execute_script("return alert(arguments[0]+'')", e.message)
    end

    def parse_cmd(line)
      arr = match_line(@r_cmd,line.strip,'cmd')

      query,cmd,prm = arr
      if query!=[] && !(cmd==[] && prm=='') && !@mock
        puts "#{@path}>cmd: #{arr.inspect}" if opt_v
        @return  = nil
        @nodes = @driver #.find_element(:css, 'html')

        query.each do |el|
          if el[0]==":"
            find_element(:name, el[1,99])
          elsif el[0]=="/"
            find_element(:xpath,"/#{el}")
          else
            idx = el[/\[(\d+)\]/,1].to_i
            el.sub!(/\[(\d+)\]/,'')
            if el[0]==">"
              if idx>0
                # binding.pry
                find_elements(:css, el[1,99],idx)
              else
                find_element(:css,  el[1,99])
              end
            else
              if idx>0
                find_elements(:css, el,idx)
              else
                find_element(:css,  el)
              end
            end
          end
        end

        if cmd==[] #no command supplied
          cmd << "~val" if (value=prm[/[=]+/]) && value.length==1
        end
        if (exc = in_commands?(cmd))
          @return = send("_#{exc}",prm)
        end
        true
      else
        false
      end
    end

    private

    def _val(prm)
      # p "TAG: #{@nodes.tag_name}"
      if !(@nodes.attribute("type")=='file' || 
           @nodes.tag_name=="select")
        @nodes.clear
      end
      @nodes.send_keys(prm[1,99])
    end

    def _click(prm)
      @nodes.click
      if prm[0]=='|'
        prm = prm[1,99]
        splt = prm[/(<|>|=)=|(=|!)~/]
        line = prm.strip.split(splt,2)
        if line.length==2
          if (parse_cmd(line[0]) && eval("\"#{@return}\" #{splt} /#{line[1]}/"))
            print '.'.green if !opt_v
          else
            print 'F'.red if !opt_v
          end
        end
      end
    rescue Exception => e
      @driver.execute_script("return alert(arguments[0]+'')", e.message)
    end

    def _text(prm)
      @nodes.text
    end

    def _html(prm)
      # @driver.get(url)
    end
  end
end
