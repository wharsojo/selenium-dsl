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

    def parse_cmd(line)
      arr = match_line(@r_cmd,line.strip,'cmd')
      # binding.pry
      query,cmd,prm = arr
      if query!=[] && !(cmd==[] && prm=='') && !@mock
        puts "#{@path}>cmd: #{arr.inspect}" if @opt=~/[-v]/
        @return  = nil
        @nodes = @driver.find_element(:css, 'html')
        # comb = []
        # query.each do |el|
        #   lst = comb[-1]
        #   rgx = /^\>\.|\./
        #   if lst && (lst=~rgx && el=~rgx)
        #     comb[-1] = "#{lst}#{el}"
        #   else
        #     comb << el 
        #   end
        # end
        query.each do |el|
          if el[0]==":"
            @nodes = @nodes.find_element(:name, el[1,99])
          elsif el[0]=="/"
            @nodes = @nodes.find_element(:xpath,"/#{el}")
          else
            idx = el[/\[(\d+)\]/,1].to_i
            el.sub!(/\[(\d+)\]/,'')
            if el[0]==">"
              if idx>0
                # binding.pry
                @nodes = @nodes.find_elements(:css, el[1,99])[idx-1]
              else
                @nodes = @nodes.find_element(:css,  el[1,99])
              end
            else
              if idx>0
                @nodes = @nodes.find_elements(:css, el)[idx-1]
              else
                @nodes = @nodes.find_element(:css,  el)
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
    rescue Exception => e
      @driver.execute_script("return alert(arguments[0]+'')", e.message)
    end

    def _click(prm)
      @nodes.click
      if prm[0]=='|'
        prm = prm[1,99]
        splt = prm[/(<|>|=)=|(=|!)~/]
        line = prm.strip.split(splt,2)
        if line.length==2
          if (parse_cmd(line[0]) && eval("\"#{@return}\" #{splt} /#{line[1]}/"))
            print '.'.green
          else
            print 'F'.red
          end
        end
      end
    end

    def _text(prm)
      @nodes.text
    end

    def _html(prm)
      # @driver.get(url)
    end
  end
end
