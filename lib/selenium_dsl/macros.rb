class SeleniumDsl
  module Commands
    def parse_mcr(line)
      arr = match_line(@r_mcr,line.strip,'mcr')

      m_set,m_run,prm = arr
      if (m_set!=[] || m_run!=[]) && !@mock
        puts "#{@path}>mcr: #{arr.inspect}" if opt_v
        @return  = nil
        c = _code_
        if m_set!=[]
          key = m_set[0].split('=')[0].strip
          c[:macro][key] = prm
        else
          m = c[:macro][m_run[0]]
          prm.split(',').each_with_index do |row,idx|
            m.gsub!("$#{idx}",row)
          end
          l = c[:line]- 1
          c[:line]    = l 
          c[:code][l] = m
        end
        true
      else
        false
      end
    end
  end
end