desc 'test'
task :sample_test do
  i = 0
  while i < 4 do
    sleep 5
    puts 'i: ' + i.to_s
    i += 1
  end
end
