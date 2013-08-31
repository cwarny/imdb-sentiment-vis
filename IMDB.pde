import rita.*;

String sent = "neg/";
String folderPath = "/Users/cwarny/Dropbox/Studies/MSA NCSU/MSA/Text Mining/aclImdb/train/";
File folder;
File[] files;
int fileIndex = 0;

ArrayList<String> reviews = new ArrayList();
ArrayList<TextObject> textObjects = new ArrayList();
ArrayList<TextObject> negAdjectives = new ArrayList();
ArrayList<TextObject> posAdjectives = new ArrayList();

PFont titleFont;

int speed = 200;
int time;
float maxNegCount = 0;
float maxPosCount = 0;

boolean showPositives = false;
boolean showNegatives = false;

void setup() {
  size(1280, 720, P3D);
  titleFont = createFont("Helvetica", 48);
  textFont(titleFont);
  
  folder = new File(folderPath + sent);
  files = folder.listFiles();
  
  loadReview(folderPath + sent + files[fileIndex].getName());
  setupTextObjects();
  stackText();
}

void draw() {
  
  background(0);
  time++;
  if (time == speed && (!showNegatives && !showPositives)) arrangeObjects();
  pushMatrix();
    scale(1);
    for (TextObject to:textObjects) {
      to.update();
      to.render(); 
    }
  popMatrix();
  
  
  if (showNegatives || showPositives) {
    scale(1);
  } else {
    translate(width/2,height/2);
    scale(map(sqrt(max(negAdjectives.size(),posAdjectives.size())), 0,sqrt(100),1,0.55));
  }
  if (!showPositives) {
    if (showNegatives) {
      for (TextObject to:negAdjectives) {
        if (to.txt.length() > 3) {
          to.update();
          to.render();
        }
      }
    } else {
      for (TextObject to:negAdjectives) {
        to.update();
        to.render();
      }
    }
  }
  
    
  if (!showNegatives) {
    if (showPositives) {
      for (TextObject to:posAdjectives) {
        if (to.txt.length() > 3) {
          to.update();
          to.render(); 
        }
      }
    } else {
      for (TextObject to:posAdjectives) {
        to.update();
        to.render(); 
      }
    }
  }
  
  
  if ((!showNegatives && !showPositives) && (frameCount % (1.5*speed) == 0)) update();

  //saveFrame("out/frames####.png");
}

void loadReview(String url) {
  String rev = join(loadStrings(url), " ").toLowerCase();
  reviews.add(rev);
}

void stackText() {
  float stackX = 0;
  float stackY = 100;
  for (TextObject to:textObjects) {
    to.tpos.x = stackX;
    to.tpos.y = stackY;
    float w = textWidth(to.txt) + 5;
    stackX += w;
    
    if(stackX > width) {
      to.tpos.x = 0;
      stackY += 40;
      stackX = w;
      to.tpos.y = stackY;
    }
  }
}

void setupTextObjects() {
   textObjects.clear();
   RiAnalyzer analyzer = new RiAnalyzer(this);
   String rev = reviews.get(fileIndex);
   analyzer.analyze(rev);
   String[] tags = split(analyzer.getPos(), " ");
   String[] words = analyzer.getTokens();
   for (int i=0; i<words.length; i++) {
     TextObject to = new TextObject();
     to.txt = words[i];
     to.txtSize = 24;
     to.mood = sent;
     to.tag = tags[i];
     if (i > 0) {
       for (int j=0; j<i; j++) {
         if (words[i].equals(words[j])) {
           to.tag = "";
           break;
         }
       }
     }
     if (sent.equals("neg/")) {
       for (TextObject t:negAdjectives) {
          if (t.txt.equals(to.txt)) {
            to.tag = "";
            break;
          }
       }
     } else {
       for (TextObject t:posAdjectives) {
          if (t.txt.equals(to.txt)) {
            to.tag = "";
            break;
          }
       }
     }
     textObjects.add(to);
   }
}

void arrangeObjects() {
  
  for (TextObject to:textObjects) {
    if (sent.equals("neg/")) {
      boolean newWord = true;
      for (TextObject t:negAdjectives) {
        if (t.txt.equals(to.txt)) {
          t.count++;
          if ((t.count > maxNegCount) && t.txt.length() > 3) maxNegCount = t.count;
          newWord = false;
          break;
        }
      }
      if (newWord && to.tag.equals("jj")) {
        negAdjectives.add(to);
      }
    } else {
      boolean newWord = true;
      for (TextObject t:posAdjectives) {
        if (t.txt.equals(to.txt)) {
          t.count++;
          if ((t.count > maxPosCount) && t.txt.length() > 3) maxPosCount = t.count;
          newWord = false;
          break;
        }
      }
      if (newWord && to.tag.equals("jj")) {
        posAdjectives.add(to);
      }
    }
  }
  
  if (sent.equals("neg/")) {
    for (TextObject to:negAdjectives) {
      textObjects.remove(to);
    }
    for (int i=0; i<negAdjectives.size(); i++) {
       float radius = map(negAdjectives.size(), 0, 10, 0, 50);
       float theta = map(i,0,negAdjectives.size(),0,TWO_PI);
       negAdjectives.get(i).trot = theta;
       float x = cos(theta) * radius;
       float y = sin(theta) * radius;
       negAdjectives.get(i).tpos = new PVector(x, y);
    }
  }
  else {
    for (TextObject to:posAdjectives) {
      textObjects.remove(to);
    }
    for (int i=0; i<posAdjectives.size(); i++) {
       float radius = map(posAdjectives.size(), 0, 10, 0, 50);
       float theta = map(i,0,posAdjectives.size(),0,TWO_PI);
       posAdjectives.get(i).trot = theta;
       float x = cos(theta) * radius;
       float y = sin(theta) * radius;
       posAdjectives.get(i).tpos = new PVector(x, y);
    }
  }
  
}

void update() {
  try {
    fileIndex++;
    time = 0;
    sent = sent.equals("neg/") ? "pos/":"neg/";
    folder = new File(folderPath + sent);
    files = folder.listFiles();
    println(files[fileIndex].getName());
    loadReview(folderPath + sent + files[fileIndex].getName());
    setupTextObjects();
    stackText();
  } catch(Exception e) {
    update();
  }
}

void keyPressed() {
  if (key == 'p') {
    textObjects.clear();
    showPositives = showPositives ? false : true;
    showNegatives = !showPositives;
    for (TextObject to:posAdjectives) {
      for (TextObject t:negAdjectives) {
        if (!to.txt.equals(t.txt) || (to.txt.equals(t.txt) && abs(to.count - t.count)/t.count > 0.5)) {
          to.txtSize = map(to.count, 1, maxPosCount, 13, 70);
          to.trot = 0;
          to.tpos = new PVector(random(width),random(height)); 
        }
      }
    }
    
  } else if (key == 'n') {
    textObjects.clear();
    showNegatives = showNegatives ? false : true;
    showPositives = !showNegatives;
    for (TextObject to:negAdjectives) {
      for (TextObject t:posAdjectives) {
        if (!to.txt.equals(t.txt) || (to.txt.equals(t.txt) && abs(to.count - t.count)/t.count > 0.5)) {
          to.txtSize = map(to.count, 1, maxNegCount, 13, 70);
          to.trot = 0;
          to.tpos = new PVector(random(width),random(height)); 
        }
      }
    }
    
  } else if (key == ' ') {
    showNegatives = false;
    showPositives = false;
    for (TextObject to:negAdjectives) {
      to.txtSize = 24;
    }
    for (TextObject to:posAdjectives) {
      to.txtSize = 24;
    }
    for (int i=0; i<negAdjectives.size(); i++) {
       float radius = map(negAdjectives.size(), 0, 10, 0, 50);
       float theta = map(i,0,negAdjectives.size(),0,TWO_PI);
       negAdjectives.get(i).trot = theta;
       float x = cos(theta) * radius;
       float y = sin(theta) * radius;
       negAdjectives.get(i).tpos = new PVector(x, y);
    }
    for (int i=0; i<posAdjectives.size(); i++) {
       float radius = map(posAdjectives.size(), 0, 10, 0, 50);
       float theta = map(i,0,posAdjectives.size(),0,TWO_PI);
       posAdjectives.get(i).trot = theta;
       float x = cos(theta) * radius;
       float y = sin(theta) * radius;
       posAdjectives.get(i).tpos = new PVector(x, y);
    }
 
  } else if (key == 's') {
    save("out/" + year() + "_" + month() + "_" + day() + "_" + hour() + "_" + minute() + "_" + second() + ".png"); //save a snapshot
  }
}
