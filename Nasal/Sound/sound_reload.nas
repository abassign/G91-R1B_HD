var sound_reload = func {
  var sf = getprop('/tmp/sound-xml/path');
  if(sf == nil)
  {
    sf = getprop('/sim/fg-root') ~ '/' ~ getprop('/sim/sound/path');
    setprop('/tmp/sound-xml/path', sf);
  }
  var st = io.stat(sf);
  var lm = getprop('/tmp/sound-xml/modified');
  if(lm == nil)
  {
    lm = st[9];
    setprop('/tmp/sound-xml/modified', lm);
  }
  elsif(lm < st[9])
  {
    setprop('/tmp/sound-xml/modified', st[9]);
    fgcommand('reinit', props.Node.new({ subsystem: "sound" }));
  }
  settimer(sound_reload, 2);
 }

sound_reload();
