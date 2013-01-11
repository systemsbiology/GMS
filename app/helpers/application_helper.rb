module ApplicationHelper


def wrapIt(text, width=80, string="<wbr />")
  text.midsub(%r{(\A|</pre>)(.*?)(\Z|<pre(?: .+?)?>)}im) do |outside_pre|  # Not inside <pre></pre>
    outside_pre.midsub(%r{(\A|>)(.*?)(\Z|<)}m) do |outside_tags|  # Not inside < >, either
      outside_tags.gsub(/(\S{#{width}})(?=\S)/) { "#$1#{string}" }
    end
  end
end

end
