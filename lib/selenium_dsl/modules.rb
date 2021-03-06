class SeleniumDsl
  module Modules

    def modules
      SeleniumDsl::Modules.private_instance_methods.collect do |x|
        "#{x[1,99]}"
      end
    end

    def in_modules?(cmd)
      modules.index(cmd) ? cmd : nil
    end

    def parse_mod(line)
      arr = match_line(@r_mod,line.strip,'mod')
      cmd,prm = arr
      if (exc = in_modules?(cmd[0]))
        send("_#{exc}",prm) if !@mock
        true
      else
        false
      end
    end

    # the regex @r_fnc will return with value in 
    # the first array, so it need to split for prm
    def parse_fnc(line)
      arr = match_line(@r_fnc,line.strip,'mod')
      return false if arr[0]==[] #[/^ *\w+.*/] - :code=123 - [[], ":code=123"]
      cmd,prm = arr[0][0].split(/ +/,2)
      npath = "#{@path}/#{cmd}"
      if @code.keys.index("~/#{cmd}")
        puts "#{@path}>mod: #{arr.inspect}" if opt_v
        prm   = prm.to_s.split(',')
        @path = npath

        @code[@path] = @code["~/#{cmd}"] if !@code[@path]
        @code[@path][:line] = 0

        p = []
        parm = @code[@path][:parm] 
        if parm && parm!=[]
          parm.each_with_index do |v,i|
            var    = v.clone
            var[1] = prm[i] if prm[i]
            p << var
          end
        end
        vars = Hash[p]
        @code[@path][:vars] = vars
        puts ">>vars: #{vars}" if opt_v
        true
      else
        false
      end
    end

    private

    def _def(prm)
      # k,v = prm.split(/\(/,2)
      # k.strip!
      # v.sub!(/\)/,'') if v
      k,v = prm.split(/ +/,2)
      k.strip!
      if v
        v=v.split(',').collect do |x|
          x.split(':')
        end
        puts ">>parm: #{v}" if opt_v
      end
      nest  = 0
      codes = []
      while (line = _line_)
        nest += 1 if line.strip =~ /^if/
        if line.strip =~ /^end$/
          break if nest==0
          nest -=1
        end
        puts ">>#{line.inspect}" if opt_v
        codes << line 
      end
      @code["#{@path}/#{k}"] = 
      {
        :macro => {},
        :code  => codes,
        :line  => 0,
        :parm  => v
      }
    end

    def _end(prm)
      #
    end
  end
end
