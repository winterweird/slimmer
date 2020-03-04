#!/usr/bin/env ruby
require "pp"
require "shellwords"

min_window_size, max_levenshtein_dist = ARGV.take(2).map(&:to_i)

def get_window_lev(window, other, line_a:, line_b:, maxdist:)
  w1 = window.join("\n")
  ret = []
  (0..other.length).each do |offset|
    other_slice = other.drop(offset).take(window.length)
    w2 = other_slice.join("\n")
    res = `./levenshtein #{ Shellwords.escape(w1) } #{ Shellwords.escape(w2) }`.strip.to_i
    if res <= maxdist
      ret << [[line_a, window.length], [line_b+offset, other_slice.length], res ]
    end
    break if other_slice.length < window.length
  end
  ret
end


def check_file_refactorability(filename, minws, maxdist)
  puts "CHECKING FILE: #{ filename }", ""
  raw_lines = File.readlines(filename).map { |line| line.rstrip }.each_with_index.to_a.reject { |line, i| line.empty? }
  lines = `cat #{ Shellwords.escape(filename) } | ./unwhitespace`.split("\n")

  skipuntil = -1
  (0..lines.length-1).each do |i|
    next if i < skipuntil
    remaining = lines.drop(i);
    prev_result = []
    wl = (minws...remaining.length).each do |j|
      window = remaining.take(j)
      after = remaining.drop(j)
      res = get_window_lev(window, after, line_a: i, line_b: i+window.length, maxdist: maxdist)
      if res.empty?
        if !prev_result.empty?
          top, btm, lev_dist = prev_result.sort_by { |_, _, lev| lev }.first
          top_block = raw_lines.drop(top.first).take(top.last).map { |w,idx| sprintf("%3d #{w}", idx+1) }.join("\n")
          btm_block = raw_lines.drop(btm.first).take(btm.last).map { |w,idx| sprintf("%3d #{w}", idx+1) }.join("\n")

          output = <<-END.chomp("\n")
#{ top_block }
#{ "-"*100 }
#{ btm_block }

DISTANCE: #{lev_dist}
#{ "="*100 }
END
          puts output, ""
        end
        skipuntil = i + window.length
        break
      else
        prev_result = res
      end
    end
  end
end

ARGV.drop(2).each do |arg|
  if File.directory?(arg)
    Dir[ File.join(arg, '**', '*') ].reject { |p| File.directory? p }.each { |f| check_file_refactorability(f, min_window_size, max_levenshtein_dist) }
  elsif File.file?(arg)
    check_file_refactorability(arg, min_window_size, max_levenshtein_dist)
  else
    puts "ERROR - Not a file: '#{ arg }'"
  end
end
