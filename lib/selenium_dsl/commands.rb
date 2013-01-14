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
      wait = Selenium::WebDriver::Wait.new(:timeout => 5) 
      wait.until do
        try=5
        begin
          nodes = @nodes.find_element(typ, el) 
        rescue Exception => e
          if e.class == Selenium::WebDriver::Error::NoSuchWindowError ||
             e.class == Selenium::WebDriver::Error::NoSuchElementError
            puts "switch: #{@driver.window_handle} to #{@driver.window_handles.inspect}" if opt_v
            @driver.switch_to.window @driver.window_handles[0]
            sleep 1
            try-= 1
            try>0 ? retry : raise(e.class,e.to_s)
          else
            puts "~>err: #{e.to_s}"
            failed
          end
        end
        @nodes = nodes if nodes
        nodes
      end
      print (opt_m ? '.' : '.'.green) if !opt_v
    rescue Exception => e
      failed
    end

    def find_elements(typ,el,idx)
      wait = Selenium::WebDriver::Wait.new(:timeout => 5) 
      wait.until do
        try=5
        begin
          # binding.pry
          nodes = @nodes.find_elements(typ, el)[idx-1]
        rescue Exception => e
          if e.class == Selenium::WebDriver::Error::NoSuchWindowError ||
             e.class == Selenium::WebDriver::Error::NoSuchElementError
            puts "switch: #{@driver.window_handle} to #{@driver.window_handles.inspect}" if opt_v
            @driver.switch_to.window @driver.window_handles[0]
            sleep 1
            try-= 1
            try>0 ? retry : raise(e.class,e.to_s)
          else
            puts "~>err: #{e.to_s}"
            failed
          end
        end
        @nodes = nodes if nodes
        # puts "func : #{el} #{idx}" if opt_v
        # puts "TAG : #{@nodes.tag_name}" if opt_v
        # puts "TEXT: #{@nodes.text}" if opt_v
        nodes
      end
      print (opt_m ? '.' : '.'.green) if !opt_v
    rescue Exception => e
        # puts "TAG : #{@nodes.tag_name}" if opt_v
        # puts @nodes.text if opt_v
      failed
    end

    def parse_cmd(line)
      arr = match_line(@r_cmd,line.strip,'cmd')
      query,cmd,prm = arr
      @nodes = @driver 
      if query!=[] && !(cmd==[] && prm=='') && !@mock
        puts "#{@path}>cmd: #{arr.inspect}" if opt_v

        query.each do |el|
          idx = el[/\[([\w\d=]+)\]/,1].to_i
          el.sub!(/\[(\d+)\]/,'') if idx>0
          if el[0]==":"
            if idx>0
              find_elements(:name, el[1,99],idx)
            else
              find_element(:name, el[1,99])
            end
          elsif el[0]=="/"
            if idx>0
              find_elements(:xpath, "/#{el}",idx)
            else
              find_element(:xpath, "/#{el}")
            end
          else
            if el[0]==">"
              if idx>0
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
          cmd << "~val" if (str=prm[/[=~]+/]) && str.length==1
        end
        if cmd[0][0]=="@"
          @return = @nodes.attribute(cmd[0][1,99])
          assert(prm)
        else
          c1,c2 = cmd[0].split(':',2)
          if (exc = in_commands?(c1))
            @return = nil
            send("_#{exc}",prm,c2)
          end
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
            print (opt_m ? '.' : '.'.green) if !opt_v
          else
            failed #print (opt_m ? 'F' : 'F'.red) if !opt_v
          end
        end
      end
    rescue Exception => e
      puts "~>err: #{e.to_s}"
      failed
    end

    def _text(prm,c2='')
      @return = @nodes.text
      assert(prm)
    end

    protected

    def assert(prm)
      if prm[0,2]=='=~'
        if @return =~ /#{prm[2,99].strip}/
          print (opt_m ? '.' : '.'.green) if !opt_v
        else
          puts "#{@return} =~ /#{prm[2,99].strip}/" if opt_t
          failed
        end
      end
    end
  end
end
