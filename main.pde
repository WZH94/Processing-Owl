/******************************************************************************/
/*!
\file   main.pde
\author Wong Zhihao
\par    email: wongzhihao.student.utwente.nl
\date
\brief
  This file contains the main loop of the program.
*/
/******************************************************************************/

// Imports the Sound library for Processing
import processing.sound.*;

boolean debug_mode = false;

// Reduce computing per frame by having variables for these
float HALF_WIDTH;
float HALF_HEIGHT;

Sound audio_manager;                    // Global properties for Processing's sound library
boolean muted;                          // Whether audio is muted
      
boolean [] keys_manager;                // Holds keyboard inputs in an array
final int num_owls = 10;                // Number of AI owl in the map
Cursor cursor;                          // Cursor to hold cursor coordinates
Owl owls_list[] = new Owl[num_owls];    // Initialise array for every owl
Sky sky;                                // The sky/background

/******************************************************************************/
/*!
    Initialises the program and allocates memory
*/
/******************************************************************************/
void setup()
{  
  // Initialise canvas and shape origins
  size(1600, 1200);
  
  // TURN THIS ON TO INCREASE PERFORMANCE SIGNIFICANTLY
  noSmooth();
  // TURN THIS ON FOR LOW PERFORMANCE BUT SMOOTH CURVES
  //smooth(8);

  rectMode(CENTER);
  ellipseMode(CENTER);

  // Set the frame rate
  frameRate(60);
  
  HALF_WIDTH = width / 2;
  HALF_HEIGHT = height / 2;

  // Default muted because the screaming sun is annoying
  muted = true;
  
  // Allocate memory for objects
  audio_manager = new Sound(this);
  audio_manager.volume(0);
  cursor = new Cursor();
  sky = new Sky();
  keys_manager = new boolean [4];

  owls_list[0] = new Owl(false);

  for (int i = 1; i < num_owls; ++i)
    owls_list[i] = new Owl(true);
  
  // Initialise keyboard inputs to be all false, keys not being pressed
  for (int i = 0; i < 4; ++i)
    keys_manager[i] = false;
}

/******************************************************************************/
/*!
    Main loop of the program, updates and draws every object
*/
/******************************************************************************/
void draw()
{
  sky.Update();

  sky.Draw();
  
  for (int i = 0; i < num_owls; ++i)
    owls_list[i].Update(sky);

  for (int i = 0; i < num_owls; ++i)
    owls_list[i].Draw();

  /************************ DEBUG ************************/
  if (debug_mode)
  {
    fill (255);
    stroke (0);
    
    // Draw the 200 pixel box around the character
    // line (width/2 + 100, height/2 + 100, width/2 + 100, height/2 - 100); // right line
    // line (width/2 - 100, height/2 + 100, width/2 - 100, height/2 - 100); // left line
    // line (width/2 + 100, height/2 + 100, width/2 - 100, height/2 + 100); // top line
    // line (width/2 + 100, height/2 - 100, width/2 - 100, height/2 - 100); // left line
    // text (mouseX, 10, 10);
    // text (mouseY, 50, 10);
    
    text (frameRate, 30, 20);
  }
}

/******************************************************************************/
/*!
    Updates cursor class postion everytime cursor moves
*/
/******************************************************************************/
void mouseMoved()
{
  cursor.Update_Cursor_Position(mouseX, mouseY);
}

/******************************************************************************/
/*!
    Handles keyboard inputs when any key is pressed
*/
/******************************************************************************/
void keyPressed()
{
  // Toggles player owl to fly or not fly
  if (key == ' ')
    Find_Player_Owl().Toggle_Flying();
       
  // Updates the keys manager input for the player owl's movements
  if (key == 'w' || key == 'W')
    keys_manager [0] = true;
    
  if (key == 's' || key == 'S')
    keys_manager [1] = true;
    
  if (key == 'a' || key == 'A')
    keys_manager [2] = true;
    
  if (key == 'd' || key == 'D')
    keys_manager [3] = true;
  
  // Checks if player is moving owl in the y-axis W or S
  for (int i = 0; i < 2; ++i)
  {
    if (keys_manager[i] == true)
    {
      Find_Player_Owl().Is_Moving_Y(true);
      break;
    }
  }
  
  // Checks if player is moving owl in the x-axis A or D
  for (int i = 2; i < 4; ++i)
  {
    if (keys_manager[i] == true)
    {
      Find_Player_Owl().Is_Moving_X(true);
      break;
    }
  }

  if (key == 'm' || key == 'M')
  {
    muted = muted ? false : true;

    if (muted)
      audio_manager.volume(0);

    else audio_manager.volume(1);
  }
}

/******************************************************************************/
/*!
    Handles keyboard inputs when any key is released
*/
/******************************************************************************/
void keyReleased ()
{
  // Updates the keys manager input for the player owl's movements
  if (key == 'w' || key == 'W')
    keys_manager [0] = false;
    
  if (key == 's' || key == 'S')
    keys_manager [1] = false;
    
  if (key == 'a' || key == 'A')
    keys_manager [2] = false;
    
  if (key == 'd' || key == 'D')
    keys_manager [3] = false;
    
  // Checks if player is NOT moving owl in the y-axis W and S
  if (keys_manager [0] == false && keys_manager [1] == false)
    Find_Player_Owl().Is_Moving_Y(false);
  
  // Checks if player is NOT moving owl in the x-axis A and D
  if (keys_manager [2] == false && keys_manager [3] == false)
    Find_Player_Owl().Is_Moving_X(false);
}

/******************************************************************************/
/*!
    Allows the cursor to click on owls on the map and choose to control them
*/
/******************************************************************************/
void mousePressed()
{
  cursor.Choose_Owl();
}
