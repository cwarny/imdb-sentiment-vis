class TextObject {
  
  String txt;
  String tag;
  String mood;
  float txtSize;
  float count = 1;
  
  PVector pos = new PVector();
  PVector tpos = new PVector();
  
  float rot = 0;
  float trot = 0;
  
  void update() {
    pos.lerp(tpos, 0.1);
    rot = lerp(rot,trot,0.1);
    if (!tag.equals("jj") && time > 100) tpos.y += (2 - map(txt.length(), 1, 10, 0.1, 2));
  }
  
  void render() {
    pushMatrix();
      translate(pos.x, pos.y);
      rotate(rot);
      textSize(txtSize);
      
      fill(255, 255, 255, map(time, 100, speed, 255, 0));
      if (tag.equals("jj")) {
        if (mood.equals("neg/")) {
          fill(222, 45, 38);
        } else if (mood.equals("pos/")) {
          fill(44, 162, 95);
        }
      }
      text(txt, 0, 0);
    popMatrix();
  }
  
}
