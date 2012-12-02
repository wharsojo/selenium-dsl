class SeleniumDsl
  module Commands
    def commands
      SeleniumDsl::Commands.private_instance_methods.collect do |x|
        "#{x[1,99]}"
      end
    end

    def in_commands?(cmd)
      if cmd
        c = cmd[1,99]
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
      failed
    end

    def find_elements(typ,el,idx)
      wait = Selenium::WebDriver::Wait.new(:timeout => 10) 
      wait.until { @nodes = @nodes.find_elements(typ, el)[idx-1] }
      print '.'.green if !opt_v
    rescue Exception => e
      failed
    end

    def parse_cmd(line)
      arr = match_line(@r_cmd,line.strip,'cmd')

      query,cmd,prm = arr
      if query!=[] && !(cmd==[] && prm=='') && !@mock
        puts "#{@path}>cmd: #{arr.inspect}" if opt_v
        @nodes = @driver 

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
        c1,c2 = cmd[0].split(':',2)
        if (exc = in_commands?(c1))
          @return = nil
          send("_#{exc}",prm,c2)
        end
        true
      else
        false
      end
    end

    private

    def _attr(prm,c2='')
      @return = @nodes.attribute(c2)
      assert(prm)
    end

    def _val(prm,c2='')
      if !(@nodes.attribute("type")=='file' || 
           @nodes.tag_name=="select")
        @nodes.clear
      end
      @return = @nodes.send_keys(prm[1,99])
    end

    def _click(prm,c2='')
      @return = @nodes.click
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
      failed
    end

    def _text(prm,c2='')
      @return = @nodes.text
      assert(prm)
    end

    protected

    def assert(prm)
      if prm[0,2]=='->'
        if @return =~ /#{prm[2,99]}/
          print '.'.green if !opt_v
        else
          failed
        end
      end
    end
  end
end
