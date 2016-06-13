task :tunnlr do
  system 'ssh -nNt -g -R :12479:0.0.0.0:3000 tunnlr3150@ssh1.tunnlr.com'
end
