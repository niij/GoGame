// These are the three image resources, goban (the name of the board), black stone, and white stone
PImage gobanImg, stoneBlackImg, stoneWhiteImg;
int boardSize = 19;
int windowSize = 600;
int windowWidth = 450;
int bSize = int(windowSize * .75);
// This is the 2d array representation of the board.  There are three possible strings for each index:
//   "n" for (n)ot placed, "w" for white stone, "b" for black stone
String[][] goban = new String[boardSize][boardSize];
String[][] captureBoard;
// Image resources
String[] fname = {"go_board.jpg", "stone_black.png", "stone_white.png"};
int blackScore=0, whiteScore=5;
boolean bTerritory, wTerritory;//for scoring territory
boolean blackTurn = true; 
String curError = ""; // String of current error message to be drawn to screen
float border, lineWidth;  // Used to calculate drawing of stones on board
PFont font;
boolean gameComplete = false;
  int passXL = 225;
  int passXR = 370;
  int passYT = 470;
  int passYB = 520;
  int completeXL = 80;
  int completeXR = 225;
  int completeYT = 470;
  int completeYB = 520;
  int scoreXL = 150;
  int scoreXR = 300;
  int scoreYT = 480;
  int scoreYB = 590;
  PImage topRightUI;
  PImage topLeftUI;
  PImage botRightUI;
  PImage botLeftUI;
  int winnerYT = 200;
  int winnerYB = 275;
  int winnerXL = 125;
  int winnerXR = 325;
  int restartYT = 300;
  int restartYB = 350;
  int restartXL = 150;
  int restartXR = 300;  

void setup() {
  fill(255,0,0); //Set text color to red
  textSize(24);
  // Fill the board with "n", as a game starts with no stones played. (note: java.util.Arrays.fill does NOT work for 2d arrays)
  for (int x = 0; x<goban.length; x++) {
    for (int y = 0; y<goban.length; y++) {
      goban[x][y] = "n";
    }
  }
  // Window size can be changed, as long as it remains square (no, this can't be a variable because Processing doesn't support variables in size())
  size(100, 100);
  surface.setResizable(true);
  surface.setSize(windowWidth, windowSize);
  border = windowSize*.75/boardSize/2;  // Size of the border around the board
  lineWidth = windowSize*.75/boardSize; // Distance between adjacent stones
  gobanImg = loadImage(fname[0]);
  stoneBlackImg = loadImage(fname[1]);
  stoneWhiteImg = loadImage(fname[2]);
 
  font = createFont("Verdana-12.vlw",16);
  textFont(font);
  topRightUI = loadImage("cornerRT.jpg");
  topLeftUI = loadImage("cornerLT.jpg");
  botRightUI = loadImage("cornerRB.jpg");
  botLeftUI = loadImage("cornerLB.jpg");
}


// Incomplete function that is called everytime a stone is placed to check for either: a suicide move/capture/ko/no action

// A **SUICIDE MOVE** is when a player would kill his own stone/group if played at a location.  This should be handled by 
//   setting the placed stone back to "n", displaying a text("Suicide move") and returning the control of the current
//   play back to the offending player.  http://senseis.xmp.net/?Suicide

// A **CAPTURE** is simply when a stone or group of stones is touching nothing except for the opposite color (walls work as wildcards)
// For some very clear examples of capture, see the section "The Rule of Capture" at http://www.kiseido.com/ff.htm

// A **KO MOVE** is when a play would result in the board going back to the state 2 moves before.  This prevents games from getting
//   stuck in simple loops.  This is explained very well at http://senseis.xmp.net/?Ko
void placedStone(int x, int y) {
  curError = ""; //Reset the error message each time a new placement attempt is made
  if (suicideCheck(x, y)) {
    curError = "This was a suicide move, please try again";
  }
  else if (goban[x][y] == "n") {
    goban[x][y] = blackTurn ? "b" : "w";  // If it's black turn, place black stone, else place a white stone
    captureBoard = new String[boardSize][boardSize];
    if (captureCheck(x,y)) {
      for(int cx=0; cx<boardSize; cx++) {
        for(int cy=0; cy<boardSize; cy++) {
          if (captureBoard[cx][cy] == "c") {
            goban[cx][cy] = "n";
            if (blackTurn) blackScore += 1;
            else whiteScore += 1;
          }
        }
      }
    }
    blackTurn = !blackTurn; // Switch whose turn it is. (Whose Turn Is It Anyway?: where the rules are made up and the points don't matter)
  }
}

boolean suicideCheck(int x, int y) {
  // Check if it's a suicide move, if so return true
  return false;
}

boolean captureCheck(int x, int y) {
  String opp = (blackTurn) ? "w" : "b"; //Identify opponent
  println(opp);
  
  if (noCardinalOpps(x,y,opp)) {
    println("No Cardinal Opps");
    return false;
  } else {
    if (y-1 >= 0 && goban[x][y-1] == opp && !cardinalOpen(x,y-1)) {
      println("Hit Up");
      goban[x][y-1] = "c";
      captureBoard[x][y-1] = "c";
      if (!noCardinalOpps(x,y-1,opp)) {
        if (!captureCheck(x,y-1)) {
          goban[x][y-1] = opp;
          captureBoard[x][y-1] = null;
        }
      }
    }
    if (y+1 < boardSize && goban[x][y+1] == opp && !cardinalOpen(x,y+1)) {
      println("Hit Down");
      goban[x][y+1] = "c";
      captureBoard[x][y+1] = "c";
      if (!noCardinalOpps(x,y+1,opp)) {
        if (!captureCheck(x,y+1)) {
          goban[x][y+1] = opp;
          captureBoard[x][y+1] = null;
        }
      }
    }
    if (x-1 >=0 && goban[x-1][y] == opp && !cardinalOpen(x-1,y)) {
      println("Hit Left");
      goban[x-1][y] = "c";
      captureBoard[x-1][y] = "c";
      if (!noCardinalOpps(x-1,y,opp)) {
        if (!captureCheck(x-1,y)) {
          goban[x-1][y] = opp;
          captureBoard[x-1][y] = opp;
        }
      }
    }
    if (x+1 < boardSize && goban[x+1][y] == opp && !cardinalOpen(x+1,y)) {
      println("Hit Right");
      goban[x+1][y] = "c";
      captureBoard[x+1][y] = "c";
      if (!noCardinalOpps(x+1,y,opp)) {
        if (!captureCheck(x+1,y)) {
          goban[x+1][y] = opp;
          captureBoard[x+1][y] = opp;
        }
      }
    }
    return true;
  }
}

boolean cardinalOpen(int x, int y) {
  if (x-1 >= 0 && goban[x-1][y] == "n") return true;
  if (x+1 <= boardSize && goban[x+1][y] == "n") return true;
  if (y+1 <= boardSize && goban[x][y+1] == "n") return true;
  if (y-1 >= 0 && goban[x][y-1] == "n") return true;
  return false;
}

boolean noCardinalOpps(int x, int y, String opp) {
  if (y-1 >= 0 && goban[x][y-1] == opp) return false;
  if (y+1 < boardSize && goban[x][y+1] == opp) return false;
  if (x-1 >=0 && goban[x-1][y] == opp) return false;
  if (x+1 < boardSize && goban[x+1][y] == opp) return false;
  return true;
}

void mousePressed() {
  if (!gameComplete && mousePressed) {
    if((mouseX < bSize) && (mouseY < bSize)){
        println("BSIZE: ", bSize);
        println(mouseX, mouseY);
        int xpos = int(mouseX / lineWidth);
        int ypos = int(mouseY / lineWidth);
        placedStone(xpos,ypos);  // Call the function to attempt a stone placement
    }
  }
  if(!gameComplete && mouseX<=completeXR && mouseX>=completeXL && mouseY<=completeYB && mouseY>=completeYT && !insideCircle())
  {
    gameComplete = true;
    score();
  }
  if(!gameComplete && mouseX<=passXR && mouseX>=passXL && mouseY<=passYB && mouseY>=passYT && !insideCircle())
  {
     blackTurn = !blackTurn;
  }
  if(gameComplete && mouseX<=restartXR && mouseX>=restartXL && mouseY<=restartYB && mouseY>=restartYT)  // when reset button is pressed
  {
    for (int x = 0; x<goban.length; x++) {  // set all positions on board as "not placed"
      for (int y = 0; y<goban.length; y++) {
        goban[x][y] = "n";
      }
    }
    blackTurn = true; //black starts the game
    gameComplete = false; // game is no longer complete, so reset scores
    blackScore=0; // reset scores back to default of 0 for black and komi for white
    whiteScore=5;
  }  
}

// Function called at the finish of the game which calculates the owned territory of each player
void score()
{
  //assume captured stones added as captured
  //count valid stones and unmarked territory
  for(int x=0; x<boardSize; x++)
  {
    for(int y=0; y<boardSize; y++)
    {
      bTerritory=false;
      wTerritory=false;
      label(x,y,"c");
      if(bTerritory||wTerritory)//if unmarked territory detected
      {
        for(int cx=0; cx<boardSize; cx++)
        {
          for(int cy=0; cy<boardSize; cy++)
          {
            if(goban[cx][cy]=="c" && bTerritory && wTerritory)//mutual territory
            {
              goban[cx][cy] = "m";
            }
            else if(goban[cx][cy]=="c" && bTerritory ==true)
            {
              goban[cx][cy] = "b"; 
            }
            else if(goban[cx][cy]=="c" && wTerritory ==true)
            {
              goban[cx][cy] = "w";
            }
          }
        }
      }
      if(goban[x][y] == "w")
      {
        whiteScore++;
      }
      if(goban[x][y] == "b")
      {
        blackScore++;
      }
    }
  }
}
void label(int x, int y, String p) 
{
  //check for border colors
  if(goban[x][y]=="b")
  {
    bTerritory=true;
  }
  if(goban[x][y]=="w")
  {
    wTerritory=true;
  }
  
  //check for non-checked blanks
  if(goban[x][y]=="n")
  {
    goban[x][y] = p;
    if(x>0)
    {
      label( x-1, y, p); 
    }
    if(x<boardSize-1)
    {
      label(x+1, y, p);
    }
    if(y>0)
    {
      label(x, y-1, p);
    }
    if(y<boardSize-1)
    {
      label(x, y+1, p);
    }
  }
}
boolean insideCircle()
{
  if(dist(mouseX,mouseY, 225,495)<=35)
  {
    return true;
  }
  return false;
}

void drawUI()
{
  textAlign(CENTER);
 
  noStroke();
  fill(220,207,186);
  quad(scoreXR, scoreYT, scoreXR, scoreYB, scoreXL,scoreYB, scoreXL, scoreYT);
  fill(0);
  text("Scores",(scoreXR-scoreXL)/2+scoreXL,550);

  stroke(161,148,129);
  strokeWeight(7);
  fill(220,207,186);
  quad(completeXR, completeYT, completeXR, completeYB, completeXL, completeYB, completeXL, completeYT);
  fill(0);
  text("Complete",(completeXR-25-completeXL)/2+completeXL,(completeYB-completeYT)/2+completeYT+6);
  
  fill(220,207,186);
  quad(passXR, passYT, passXR, passYB, passXL,passYB, passXL, passYT);
  fill(0);
  text("Pass",(passXR-passXL+15)/2+passXL,(passYB-passYT)/2+passYT+6);
    
  noStroke();  
  ellipseMode(CENTER);
  if(blackTurn)
  {
    fill(0);
  }
  else
  {
    fill(255);
  }
  ellipse(450/2,495,70,70);  
  fill(255);
  arc(450/2,495,60,60,PI+(PI/2),2*PI+(PI/2));
  fill(0);
  arc(450/2,495,60,60,(PI/2),PI+(PI/2));
    
  if(gameComplete)
  {
    
    fill(0);
    text(""+blackScore,scoreXL+40,570);
    text(""+whiteScore,scoreXR-40, 570 ); 
    
    noStroke();
    fill(220,207,186);
    quad(winnerXR, winnerYT, winnerXR, winnerYB, winnerXL,winnerYB, winnerXL, winnerYT);
    fill(0);
    String winner;
    if(blackScore>whiteScore)
    {
      winner = "Black Wins";
    }
    else if(blackScore<whiteScore)
    {
      winner = "White Wins";
    }
    else
    {
      winner = "It's a Tie";
    }
    text(winner,(winnerXR-winnerXL)/2+winnerXL,(winnerYB-winnerYT)/2+winnerYT+6);
    
    stroke(161,148,129);
    strokeWeight(7);
    fill(220,207,186);
    quad(restartXR, restartYT, restartXR, restartYB, restartXL,restartYB, restartXL, restartYT);
    fill(0);
    text("Restart",(restartXR-restartXL)/2+restartXL,(restartYB-restartYT)/2+restartYT+6);

  }
  else
  {
    fill(0);
    text("--.-",scoreXL+40,570);
    text("--.-",scoreXR-40, 570 );
  }
  textAlign(LEFT);
}

// Draw function to loop continuously drawing the board and all pieces
void draw() {
  background(109,116,65);
  imageMode(CENTER);
  
  image(topRightUI,440,460);
  image(topLeftUI,10,460);
  image(botRightUI,440,590);
  image(botLeftUI,10,590);
  
  imageMode(CORNER);
  image(gobanImg, 0, 0, bSize, bSize);  // Draw the board
  
  imageMode(CENTER);  // Center the stone images, it makes the math easier to read
  if (curError != "") {
    text(curError, 0, height-30);
  }
  if(!gameComplete)
  {
    for (int x = 0; x<goban.length; x++) {  //fill our array with "n", which denoted (n)ot-placed
      for (int y = 0; y<goban.length; y++) {
        if (goban[x][y] != "n") { //Skip blank stones
          if (goban[x][y] == "b") {  // Draw black stones
            image(stoneBlackImg, int(border+(x*lineWidth)), int(border+(y*lineWidth)), int(lineWidth), int(lineWidth));
          }
          else if (goban[x][y] == "w") {  // Draw white stones
            image(stoneWhiteImg, int(border+(x*lineWidth)), int(border+(y*lineWidth)), int(lineWidth), int(lineWidth));
          }
        }
      }
    }  
  }
  drawUI();
}