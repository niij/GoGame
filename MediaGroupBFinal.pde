// These are the three image resources, goban (the name of the board), black stone, and white stone
PImage gobanImg, stoneBlackImg, stoneWhiteImg;
int boardSize = 19;
int windowSize = 600;
int bSize = int(windowSize * .75);
// This is the 2d array representation of the board.  There are three possible strings for each index:
//   "n" for (n)ot placed, "w" for white stone, "b" for black stone
String[][] goban = new String[boardSize][boardSize];
String[][] captureBoard;
// Image resources
String[] fname = {"go_board.jpg", "stone_black.png", "stone_white.png"};
int blackScore=0, whiteScore=0;
boolean bTerritory, wTerritory;//for scoring territory
boolean blackTurn = true; 
String curError = ""; // String of current error message to be drawn to screen
float border, lineWidth;  // Used to calculate drawing of stones on board


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
  surface.setSize(windowSize, windowSize);
  border = width*.75/boardSize/2;  // Size of the border around the board
  lineWidth = width*.75/boardSize; // Distance between adjacent stones
  gobanImg = loadImage(fname[0]);
  stoneBlackImg = loadImage(fname[1]);
  stoneWhiteImg = loadImage(fname[2]);
  //score();
  //print("black score: " + blackScore+" white score: " + whiteScore);
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
      for(int cx=0; x<boardSize; cx++) {
        for(int cy=0; y<boardSize; cy++) {
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
  
  //Check north
  if (x != 0) {
    if (goban[x-1][y] == opp && !cardinalOpen(x-1,y)) {
      captureBoard[x-1][y] = "c";
      if (captureCheck(x-1,y)) return true;
      else captureBoard[x-1][y] = null;
    }
  }
  
  //Check south
  if (x < boardSize-1) {
    if (goban[x+1][y] == opp && !cardinalOpen(x+1,y)) {
      captureBoard[x+1][y] = "c";
      if (captureCheck(x+1,y)) return true;
      else captureBoard[x+1][y] = null;
    }
  }
  
  //Check east
  if (y < boardSize-1) {
    if (goban[x][y+1] == opp && !cardinalOpen(x,y+1)) {
      captureBoard[x][y+1] = "c";
      if (captureCheck(x,y+1)) return true;
      else captureBoard[x][y+1] = null;
    }
  }
  
  //Check west
  if (y != 0) {
    if (goban[x][y-1] == opp && !cardinalOpen(x,y-1)) {
      captureBoard[x][y-1] = "c";
      if (captureCheck(x,y-1)) return true;
      else captureBoard[x][y-1] = null; 
    }
  }
  
  return false;
}

boolean cardinalOpen(int x, int y) {
  if (x-1 >= 0 && goban[x-1][y] == "n") return true;
  if (x+1 <= boardSize && goban[x+1][y] == "n") return true;
  if (y+1 <= boardSize && goban[x][y+1] == "n") return true;
  if (y-1 >= 0 && goban[x][y-1] == "n") return true;
  return false;
}


void mousePressed() {
  if (mousePressed) {
    if((mouseX < bSize) && (mouseY < bSize)){
        println("BSIZE: ", bSize);
        println(mouseX, mouseY);
        int xpos = int(mouseX / lineWidth);
        int ypos = int(mouseY / lineWidth);
        placedStone(xpos,ypos);  // Call the function to attempt a stone placement
    }
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

// Draw function to loop continuously drawing the board and all pieces
void draw() {
  background(255);
  imageMode(CORNER);
  image(gobanImg, 0, 0, bSize, bSize);  // Draw the board
  imageMode(CENTER);  // Center the stone images, it makes the math easier to read
  if (curError != "") {
    text(curError, 0, height-30);
  }
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