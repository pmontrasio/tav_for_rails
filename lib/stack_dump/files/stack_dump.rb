class StackDump
  def self.trace()
    return "" unless $!
    trace = Array.new
    $!.backtrace.each do |line|
      trace << line.to_s
    end
    trace.join("\n")
  end
end
