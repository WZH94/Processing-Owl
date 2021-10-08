/******************************************************************************/
/*!
\file   Owl.pde
\author Wong Zhihao
\par    email: wongzhihao.student.utwente.nl
\date
\brief
  This file contains the implementation of the Owl class. The owl consists
  of a Body and Head component. It contains the position, size, speed and other
  variables that affect the behaviour of the owl. The other components are 
  dependent on the variables of these class. This class mainly handles the
  movement and positioning of the owl, and includes the AI for the NPC owls
*/
/******************************************************************************/

enum X_DIRECTION
{
  SAME,
  LEFT,
  RIGHT
};

enum Y_DIRECTION
{
  SAME,
  ABOVE,
  BELOW
};

class Owl {    
  private Body body_;  // Owl contains a body
  private Head head_;  // Owl contains a head

  private boolean is_ai_;                      // If the owl is player controlled or AI
               
  private vec owl_pos_;                        // Pos of the owl
  private final float owl_size_;               // Size of the owl
  private final float scale_;                  // Scale of the owl
                
  private boolean is_moving_x_;                // If owl is moving horizontally
  private boolean is_moving_y_;                // If owl is moving vertically
  
  private final float ai_acc_speed_;           // Acceleration speed of the owl if is ai
  private final float ai_deacc_speed_;         // Decceleration speed of the owl if is ai
  private final float ai_max_move_speed_;      // Max speed the owl can move at if is ai

  private final float player_acc_speed_;       // Acceleration speed of the owl if is player controlled
  private final float player_deacc_speed_;     // Decceleration speed of the owl if is player controlled
  private final float player_max_move_speed_;  // Max speed the owl can move at if is player controlled

  private float acc_speed_;                    // Acceleration speed of the owl
  private float deacc_speed_;                  // Decceleration speed of the owl
  private float max_move_speed_;               // Max speed the owl can move at
  private vec move_velocity_;                  // The current velocity the owl is moving in
      
  private float body_radians_;                 // How much the body is rotating
  private final float body_radians_max_;       // How much the body can rotate at max
  private float head_radians_;                 // How much the head is rotating in addition to body
  private final float head_radians_max_;       // How much the head can rotate at max in addition to body
      
  private float hover_distance_;               // The current distance the owl is hovering at while flying
  private vec owl_pos_hover_;                  // The pos of the owl while hovering, it is kept seperate from normal owl pos
 
  // AI VARIABLES 
  private boolean ai_is_moving_;               // Whether the AI is moving or not
 
  private int ai_last_move_;                   // The last time in ms the owl toggled moving
  private final float ai_seed_;                // The seed that handles the randomness of the owl's AI behaviour
 
  private int ai_last_x_axis_toggle_;          // The last time in ms the owl stopped or started moving in the x-axis
  private int ai_last_y_axis_toggle_;          // The last time in ms the owl stopped or started moving in the y-axis
 
  private int ai_last_x_direction_change_;     // The last time in ms the owl changed direction in the x-axis
  private int ai_last_y_direction_change_;     // The last time in ms the owl changed direction in the y-axis
 
  private boolean ai_move_x_direction_;        // Which direction the owl is moving in the x-axis. true for left -x false for right +x
  private boolean ai_move_y_direction_;        // Which direction the owl is moving in the y-axis. true for up -y false for down +y
 
  private int ai_last_fly_;                    // The last time in ms the owl toggled flying
  private final float ai_flying_seed_;         // The seed that handles the randomness of the owl's flying behaviour

  /******************************************************************************/
  /*!
      Default constructor
  */
  /******************************************************************************/
  Owl(boolean is_ai)
  {
    // THESE VALUES ARE THE SAME FOR EVERY OWL

    is_ai_ = is_ai;

    // Default moving and flying to false
    is_moving_x_ = false;
    is_moving_y_ = false;

    // Not moving
    move_velocity_ = new vec();

    body_radians_ = 0;
    body_radians_max_ = radians(20);
    head_radians_ = 0;
    head_radians_max_ = radians(15);

    // Default hover values are 0
    owl_pos_hover_ = new vec ();
    hover_distance_ = 0;

    // AI is not moving
    ai_is_moving_ = false;

    // Randomise the AI seed
    ai_seed_ = random(1500, 5000);
    // Last time it moved, sets it so that it can automatically move once the program starts
    ai_last_move_ = millis() - int(ai_seed_);

    // Initialise to a value
    ai_move_x_direction_ = false;
    ai_move_y_direction_ = false;

    // Last time it changed direction, set to current time
    ai_last_x_direction_change_ = millis();
    ai_last_y_direction_change_ = millis();

    // Last time it toggled movement in the axises, set to current time
    ai_last_x_axis_toggle_ = millis();
    ai_last_y_axis_toggle_ = millis();

    // Randomise the flying seed
    ai_flying_seed_ = random(5000, 20000);
    // Last time it flied, sets it so that it can automatically fly once the program starts 
    ai_last_fly_ = millis() - int(ai_flying_seed_);

    // THESE VALUES DIFFER FROM OWL TO OWL

    // This owl is player controlled
    if (is_ai == false)
    {
      scale_ = 1;

      // Change these values to set owl speeds
      player_acc_speed_ = 0.45f * scale_;
      player_deacc_speed_ = 0.5f * scale_;
      player_max_move_speed_ = 16f * scale_;

      // AI moves slower
      ai_acc_speed_ = player_acc_speed_ * 0.5f;
      ai_deacc_speed_ = player_deacc_speed_ * 0.5f;
      ai_max_move_speed_ = player_max_move_speed_ * 0.5f;
      
      acc_speed_ = player_acc_speed_;
      deacc_speed_ = player_deacc_speed_;
      max_move_speed_ = player_max_move_speed_;

      // Default owl pos at center of screen
      owl_pos_ = new vec(HALF_WIDTH, HALF_HEIGHT);
      // Change value to change size of owl
      owl_size_ = 60.0f * scale_;
      
      // Allocates memory for the components
      body_ = new Body(owl_size_);
      head_ = new Head(owl_size_, owl_pos_);
    }

    // This owl is AI controlled, and will have custom random values for physical features
    else
    {
      // Randomise the scale of the AI owl, is never bigger than player owl
      scale_ = random(0.4, 0.8);

      // Change these values to set owl speeds
      player_acc_speed_ = 0.45f * scale_;
      player_deacc_speed_ = 0.5f * scale_;
      player_max_move_speed_ = 16f * scale_;

      // AI moves slower
      ai_acc_speed_ = player_acc_speed_ * 0.5f;
      ai_deacc_speed_ = player_deacc_speed_ * 0.5f;
      ai_max_move_speed_ = player_max_move_speed_ * 0.5f;
    
      acc_speed_ = ai_acc_speed_;
      deacc_speed_ = ai_deacc_speed_;
      max_move_speed_ = ai_max_move_speed_;

      // Change value to change size of owl
      owl_size_ = 60.0f * scale_;
      // Default owl pos at center of screen
      owl_pos_ = new vec(random(owl_size_, width - owl_size_), random(owl_size_, height - owl_size_));

      // Allocates memory for the components
      body_ = new Body(owl_size_);
      head_ = new Head(owl_size_, owl_pos_);
    }
  }
  
  /******************************************************************************/
  /*!
      Updates the owl position based on velocity, checks if it should decelerate,
      handles the wrapping and updates its components
  */
  /******************************************************************************/
  void Update(Sky sky)
  {
    // Movement, only can move while flying
    // Can remove !is_ai_ to control every owl's movements
    if (!is_ai_ && Get_Is_Flying ())
    {
      if (keys_manager [0])
        Move_UD (true);
        
      if (keys_manager [1])
        Move_UD (false);
        
      if (keys_manager [2])
        Move_LR (true);
        
      if (keys_manager [3])
        Move_LR (false);
    }

    // Executes AI logic
    if (is_ai_)
      AI_Logic(sky);

    // Update owl position with its velocity
    owl_pos_.x += move_velocity_.x;
    owl_pos_.y += move_velocity_.y;

    // Owl should decelerate if it is not flying OR it is not moving horizontally/vertically but there is still momentum to it
    if (Get_Is_Flying() == false || (is_moving_x_ == false && move_velocity_.x != 0))
      Decelerate(true);
      
    if (Get_Is_Flying() == false || (is_moving_y_ == false && move_velocity_.y != 0))
      Decelerate(false);
      
    // Handles the owl wrapping from one end of the screen to the other
    Wrap();
    
    // Updates the body component
    body_.Update(owl_size_, this);

    // Find its new position after it is hovering while keeping its actual position. MUST BE AFTER body_.Update()
    owl_pos_hover_.x = owl_pos_.x; 
    owl_pos_hover_.y = owl_pos_.y - hover_distance_;

    // Updates the head position
    head_.Update(owl_pos_hover_, is_ai_);
  }
  
  /******************************************************************************/
  /*!
      Draws the owl
  */
  /******************************************************************************/
  void Draw()
  {
    pushMatrix();
    // Translates owl position
    translate(owl_pos_hover_.x, owl_pos_hover_.y);
    // Rotates the body
    rotate(body_radians_);
    
    // Every subsequent coordinated is translated from this owl position
    body_.Draw();

    // Additionally rotates the head
    pushMatrix();
    rotate(head_radians_);
    
    head_.Draw();

    popMatrix();
    popMatrix();
  }

  /******************************************************************************/
  /*!
      Gets if the owl is flying or not, retrieve value from body->wings
  */
  /******************************************************************************/
  boolean Get_Is_Flying()
  {
    return body_.Get_Is_Flying();
  }
  
  /******************************************************************************/
  /*!
      Sets the lift off and landing of the owl, calls function in body->wings
  */
  /******************************************************************************/
  void Toggle_Flying()
  {
    body_.Toggle_Flying();
  }
  
  /******************************************************************************/
  /*!
      Sets the rotation of the body and head
  */
  /******************************************************************************/
  void Set_Rotation()
  {
    // Calculates the percentage of current velocity over max speed and multiply
    // by max rotation of body and head
    body_radians_ = (move_velocity_.x / max_move_speed_) * body_radians_max_;
    head_radians_ = (move_velocity_.x / max_move_speed_) * head_radians_max_;
  }
  
  /******************************************************************************/
  /*!
      Accelerates the owl on the x-axis. true to move left (-x), false to move right(+x)
  */
  /******************************************************************************/
  private void Move_LR(boolean direction)
  {    
    if (direction == true)
    {
      move_velocity_.x -= acc_speed_;
      
      // Snap the velocity to max speed if it has exceeded
      if (move_velocity_.x < -max_move_speed_)
        move_velocity_.x = -max_move_speed_;
    }
      
    else 
    {
      move_velocity_.x +=acc_speed_;

      // Snap the velocity to max speed if it has exceeded
      if (move_velocity_.x > max_move_speed_)
        move_velocity_.x = max_move_speed_;
    }

    // Rotates the owl
    Set_Rotation();
  }
  
  /******************************************************************************/
  /*!
      Accelerates the owl on the y-axis. true to move up(-y), false to move down(+y)
  */
  /******************************************************************************/
  private void Move_UD(boolean direction)
  {
    if (direction == true)
    {
      move_velocity_.y -= acc_speed_;
      
      // Snap the velocity to max speed if it has exceeded
      if (move_velocity_.y < -max_move_speed_)
        move_velocity_.y = -max_move_speed_;
    }
      
    else 
    {
      move_velocity_.y += acc_speed_;
      
      // Snap the velocity to max speed if it has exceeded
      if (move_velocity_.y > max_move_speed_)
        move_velocity_.y = max_move_speed_;
    }
  }
  
  /******************************************************************************/
  /*!
      Decelerates the owl when it is not moving but there is still velocity,
      true for x-axis, false for y-axis
  */
  /******************************************************************************/
  private void Decelerate(boolean axis)
  {
    // x-axis
    if (axis == true)
    {
      if (move_velocity_.x > 0)
      {
        move_velocity_.x -= deacc_speed_;
        
        // Snap the velocity to 0 if it has exceeded
        if (move_velocity_.x < 0)
          move_velocity_.x = 0;
      }
      
      else if (move_velocity_.x < 0)
      {
        move_velocity_.x += deacc_speed_;
        
        // Snap the velocity to 0 if it has exceeded
        if (move_velocity_.x > 0)
          move_velocity_.x = 0;
      }
      
      Set_Rotation();
    }
    
    // y-axis
    else if (axis == false)
    {
       if (move_velocity_.y > 0)
      {
        move_velocity_.y -= deacc_speed_;
        
        // Snap the velocity to 0 if it has exceeded
        if (move_velocity_.y < 0)
          move_velocity_.y = 0;
      }
      
      else if (move_velocity_.y < 0)
      {
        move_velocity_.y += deacc_speed_;
        
        // Snap the velocity to 0 if it has exceeded
        if (move_velocity_.y > 0)
          move_velocity_.y = 0;
      }
    }
  }
  
  /******************************************************************************/
  /*!
      Sets if the owl is moving horizontally
  */
  /******************************************************************************/
  void Is_Moving_X(boolean state)
  {
    is_moving_x_ = state;
  }
  
  /******************************************************************************/
  /*!
      Sets if the owl is moving vertically
  */
  /******************************************************************************/
  void Is_Moving_Y(boolean state)
  {
    is_moving_y_ = state;
  }
  
  /******************************************************************************/
  /*!
      Sets the distance the owl is hovering above the groud currently
  */
  /******************************************************************************/
  void Hover(float distance)
  {
    hover_distance_ = distance;
  }
  
  /******************************************************************************/
  /*!
      Wraps the owl to the other side of the screen when it exits one side.
  */
  /******************************************************************************/
  private void Wrap()
  {
    // Check if object should wrap from left to right side of screen
    if (owl_pos_.x < -owl_size_)
      owl_pos_.x = width + owl_size_;
    
    // Check if object should wrap from right to left side of screen
    if (owl_pos_.x > width + owl_size_)
      owl_pos_.x = -owl_size_;
    
    // Check if object should wrap from top to bottom side of screen
    if (owl_pos_.y < -owl_size_ - hover_distance_)
      owl_pos_.y = height + (owl_size_ * 1.2f);
      
    // Check if object should wrap from bottom to top side of screen
    if (owl_pos_.y > height + owl_size_ + hover_distance_)
      owl_pos_.y = -owl_size_ * 1.2f;
  }

  /************************************ AI LOGIC ************************************/

  /******************************************************************************/
  /*!
      Executes every AI logic function
  */
  /******************************************************************************/
  private void AI_Logic(Sky sky)
  {
    // AI flying logic
    AI_Fly();

    // Can only execute AI move logic if it is flying
    if (Get_Is_Flying() == true)
      AI_Move();

    // AI opening and closing eyes logic
    AI_Eyes(sky);
  }

  /******************************************************************************/
  /*!
      Handles turning on and off the owl flying
  */
  /******************************************************************************/
  private void AI_Fly()
  {
    // Check if ready to toggle movement based on whether the time elapsed since last movement has passed the movement seed value
    if (millis() - ai_last_fly_ >= ai_flying_seed_)
      AI_Toggle_Flying();
  }
  
  /******************************************************************************/
  /*!
      Handles the randomness of the owl flying
  */
  /******************************************************************************/
  private void AI_Toggle_Flying()
  {
    // Generate random number to check if it should toggle movement
    float random_number = random(0, ai_flying_seed_);

    // The larger the number, the SMALLER the chance
    // If already flying and is daytime OR is not flying and is nighttime, higher chance of toggling, else lower chance
    int chance = ((Get_Is_Flying() && sky.Get_Day_Or_Night_Time()) || (!Get_Is_Flying() && !sky.Get_Day_Or_Night_Time())) ? 200 : 3000;

    // Algorithm checks if random number is less than or equal to 100th of the seed value. Number is kept small as this should not happen often.
    if (random_number <= ai_flying_seed_ / chance)
    {
      Toggle_Flying();

      if (Get_Is_Flying() == false)
      {
        is_moving_x_ = false;
        is_moving_y_ = false;
      }

      // Sets the new last move time
      ai_last_fly_ = millis();
    }
  }

  /******************************************************************************/
  /*!
      Handles all the movement logic of the owl
  */
  /******************************************************************************/
  private void AI_Move()
  {
    // Check if ready to toggle movement based on whether the time elapsed since last movement has passed the movement seed value
    if (millis() - ai_last_move_ >= ai_seed_)
      AI_Toggle_Movement();

    // Check if owl is avoiding something
    boolean avoiding_something = AI_Avoidance_Module();

    // Check if owl should be moving and sets its movement logic
    if (ai_is_moving_)
      AI_Movement_Logic(avoiding_something);
  }

  /******************************************************************************/
  /*!
      Handles turning on and off the movement of the AI owls
  */
  /******************************************************************************/
  private void AI_Toggle_Movement()
  {
    // Generate random number to check if it should toggle movement
    float random_number = random(0, ai_seed_);

    // The larger the number, the SMALLER the chance
    // If not already moving, higher chance of toggling, else lower chance
    int chance = (!ai_is_moving_) ? 50 : 500;

    // Algorithm to randomise if action should happen
    if (random_number <= ai_seed_ / chance)
    {
      // Check if AI is already moving
      if (ai_is_moving_)
      {
        // Sets it to stop moving entirely
        ai_is_moving_ = false;
        is_moving_x_ = false;
        is_moving_y_ = false;
      }

      // AI is not moving at all, set it to move in both x and y
      else 
      {
        ai_is_moving_ = true;
      }

      // Sets the new last move time
      ai_last_move_ = millis();
    }
  }

  /******************************************************************************/
  /*!
      Handles the logic of the AI movement, and handles the movement itself
  */
  /******************************************************************************/
  private void AI_Movement_Logic(boolean avoiding_something)
  {
    // If avoiding something, do not change the axis movements
    if (!avoiding_something)
    {
      // Toggles stopping and starting of owl moving in each axis
      AI_Toggle_Movement_Axis();
      // Toggles direction owl moves in each axis
      AI_Toggle_Axis_Directions();
    }

    // Moves the owl in the x-axis
    if (is_moving_x_ == true)
    {
      Move_LR(ai_move_x_direction_);
    }

    // Moves the owl in the y-axis
    if (is_moving_y_ == true)
    {
      Move_UD(ai_move_y_direction_);
    }
  }

  /******************************************************************************/
  /*!
      Handles the turning on and off of the AI movement along the x and y axises
  */
  /******************************************************************************/
  private void AI_Toggle_Movement_Axis()
  {
    // If it is here, either x or y should be moving. First, check if not moving in either axises
    if (is_moving_x_ == false && is_moving_y_ == false)
    {
      // Owl is not moving in any axises even though it should, randomise between 3 numbers
      switch(int(random(0,3)))
      {
        // Only sets the x-axis to be moving
        case 0: is_moving_x_ = true;
          break;

        // Only sets the y-axis to be moving
        case 1: is_moving_y_ = true;
          break;

        // Sets it to be moving on both axises
        case 2: is_moving_x_ = true;
          is_moving_y_ = true;
          break;
      }

      ai_is_moving_ = true;
    }

    // Now, there is a chance to toggle either x or y axis to move or not move
    else
    {
      // Generate random number from ai seed
      float random_number = random(0, ai_seed_);

      // The larger the number, the SMALLER the chance
      // If moving in both axises already, lower chance of toggling, else higher chance
      int chance = (is_moving_x_ && is_moving_y_) ? 10000 : 200;

      // Calculate change to toggle x-axis movement
      // BUT FIRST, check if not only moving in x-axis, so that it doesn't accidentally cause it to stop moving
      // on x-axis when it is already not moving in y-axis
      if (is_moving_y_)
      {
        // Safe to possibly stop x-axis movement, calculate chance of it happening now
        // The larger the number, the SMALLER the chance to toggle x-axis movement
        if (random_number <= ai_seed_ / chance)
        {
          is_moving_x_ = (is_moving_x_ == true) ? false : true;
        }
      }

      // Generate another random number
      random_number = random(0, ai_seed_);

      // Calculate change to toggle y-axis movement
      // BUT FIRST, check if not only moving in y-axis, so that it doesn't accidentally cause it to stop moving
      // on y-axis when it is already not moving in x-axis
      if (is_moving_x_)
      {
        // Safe to possibly stop x-axis movement, calculate chance of it happening now
        // The larger the number, the SMALLER the chance to toggle x-axis movement
        if (random_number <= ai_seed_ / chance)
        {
          is_moving_y_ = (is_moving_y_ == true) ? false : true;
        }
      }
    }
  }

  /******************************************************************************/
  /*!
      Handles the direction the AI moves along the different axises
  */
  /******************************************************************************/
  private void AI_Toggle_Axis_Directions()
  {
    if (millis() - ai_last_x_direction_change_ >= ai_seed_ / 3)
    {
      // Generate random number from ai seed
      float random_number = random(0, ai_seed_);

      // The larger the number, the SMALLER the chance
      int chance = 50;

      if (random_number <= ai_seed_ / chance)
      {
        // Generate 2 random numbers, 0 or 1
        switch (int(random(0, 2)))
        {
          case 0: ai_move_x_direction_ = false;
            break;

          case 1: ai_move_x_direction_ = true;
            break;
        }

        ai_last_x_direction_change_ = millis();
      }
    }

    if (millis() - ai_last_y_direction_change_ >= ai_seed_ / 3)
    {
      // Generate random number from ai seed
      float random_number = random(0, ai_seed_);

      // The larger the number, the SMALLER the chance
      int chance = 50;

      if (random_number <= ai_seed_ / chance)
      {
        // Generate 2 random numbers, 0 or 1
        switch (int(random(0, 2)))
        {
          case 0: ai_move_y_direction_ = false;
            break;

          case 1: ai_move_y_direction_ = true;
            break;
        }

        ai_last_y_direction_change_ = millis();
      }
    }
  }

  /******************************************************************************/
  /*!
      Handles the randomness of the owl eyes closing and opening
  */
  /******************************************************************************/
  private void AI_Eyes(Sky sky)
  {
    // Is flying and eyes are already closed, open them
    if (Get_Is_Flying() && head_.AI_Get_Eyes_Closed())
    {
      head_.AI_Set_Eyes_Closed();
    }

    // Otherwise, only other time eyes will open and close is when not flying
    else if (!Get_Is_Flying())
    {
      float random_number = random(0, ai_flying_seed_);

      // The larger the number, the SMALLER the chance
      // If is daytime and eyes are not closed OR is nighttime and eyes are closed, higher chance of toggling, else lower chance
      int chance = (((sky.Get_Day_Or_Night_Time()) && !head_.AI_Get_Eyes_Closed()) || (!sky.Get_Day_Or_Night_Time() && head_.AI_Get_Eyes_Closed())) ? 150 : 4000;
      
      // Algorithm checks if random number is less than or equal to 100th of the seed value. Number is kept small as this should not happen often.
      if (random_number <= ai_flying_seed_ / chance)
        head_.AI_Set_Eyes_Closed();
    }
  }

  /******************************************************************************/
  /*!
      Executes all the logic related with the AI owls avoiding other flying owls
  */
  /******************************************************************************/
  private boolean AI_Avoidance_Module()
  {
    boolean avoiding_something = false;

    // Loops through every AI owl
    for (int i = 0; i < num_owls; ++i)
    {
      // Check if owl being checked is the same as owl checking and continue
      if (owl_pos_.x == owls_list[i].owl_pos_.x && owl_pos_.y == owls_list[i].owl_pos_.y)
        continue;

      // Only avoid owls that are flying
      else if (owls_list[i].Get_Is_Flying() && Collision_Detection_In_Range(owls_list[i], owl_pos_, owl_size_, 3))
      {
        AI_Avoidance_Logic(owls_list[i]);
        avoiding_something = true;
      }
    }

    return avoiding_something;
  }

  /******************************************************************************/
  /*!
      Handles the direction to avoid the AI owl
  */
  /******************************************************************************/
  private void AI_Avoidance_Logic(Owl owl_check)
  {
    // Stores the x and y direction of the colliding owl
    X_DIRECTION x_direction = Check_X_Colliding_Direction(owl_check);
    Y_DIRECTION y_direction = Check_Y_Colliding_Direction(owl_check);

    // If it is here, either x or y should be moving. First, check if not moving in either axises
    if (!is_moving_x_ && !is_moving_y_)
    {
      // Owl is not moving in any axises even though it should, randomise between 3 numbers
      switch(int(random(0,3)))
      {
        // Only sets the x-axis to be moving
        case 0: is_moving_x_ = true;
          break;

        // Only sets the y-axis to be moving
        case 1: is_moving_y_ = true;
          break;

        // Sets it to be moving on both axises
        case 2: is_moving_x_ = true;
          is_moving_y_ = true;
          break;
      }

      ai_is_moving_ = true;
    }

    // Check if moving rightwards and the owl it is colliding with is to the right as well
    if (is_moving_x_ && ai_move_x_direction_ == false && x_direction == X_DIRECTION.RIGHT)
    {
      // Randomise between 2 numbers
      switch (int(random(0, 2)))
      {
        // Case 0 means owl will invert its x direction to fly away from colliding owl
        case 0: ai_move_x_direction_ = true;
          break;

        // Case 1 means owl will change its y direction to avoid the colliding owl
        case 1: Avoid_Owl_Y_Direction(y_direction);
          break;            
      }
    }
    // Check if moving leftwards and the owl it is colliding with is to the left as well
    else if (is_moving_x_ && ai_move_x_direction_ == true && x_direction == X_DIRECTION.LEFT)
    {
      // Randomise between 2 numbers
      switch (int(random(0, 2)))
      {
        // Case 0 means owl will invert its x direction to fly away from colliding owl
        case 0: ai_move_x_direction_ = false;
          break;

        // Case 1 means owl will change its y direction to avoid the colliding owl
        case 1: Avoid_Owl_Y_Direction(y_direction);
          break;            
      }
    }

    // Check if moving downwards and the owl it is colliding with is below as well
    if (is_moving_y_ && ai_move_y_direction_ == false && y_direction == Y_DIRECTION.BELOW)
    {
      // Randomise between 2 numbers
      switch (int(random(0, 2)))
      {
        // Case 0 means owl will invert its y direction to fly away from colliding owl
        case 0: ai_move_y_direction_ = true;
          break;

        // Case 1 means owl will change its x direction to avoid the colliding owl
        case 1: Avoid_Owl_X_Direction(x_direction);
          break;            
      }
    }
    // Check if moving upwards and the owl it is colliding with is above as well
    else if (is_moving_y_ && ai_move_y_direction_ == true && y_direction == Y_DIRECTION.ABOVE)
    {
      // Randomise between 2 numbers
      switch (int(random(0, 2)))
      {
        // Case 0 means owl will invert its y direction to fly away from colliding owl
        case 0: ai_move_y_direction_ = false;
          break;

        // Case 1 means owl will change its y direction to avoid the colliding owl
        case 1: Avoid_Owl_X_Direction(x_direction);
          break;            
      }
    }
  }

  /******************************************************************************/
  /*!
      Controls the direction the AI will move in the x-axis to avoid an owl
  */
  /******************************************************************************/
  private void Avoid_Owl_X_Direction(X_DIRECTION x_direction)
  {
    // First, check if it already moving away from colliding owl in the x-axis and return
    if ((is_moving_x_ && ai_move_x_direction_ == false && x_direction == X_DIRECTION.RIGHT) || 
        (is_moving_x_ && ai_move_x_direction_ == true && x_direction == X_DIRECTION.LEFT))
      return;

    // Makes it move in the x-axis if it is not already
    if (is_moving_x_ == false)
      is_moving_x_ = true;

    // Check which direction the colliding owl is on the x-axis
    switch (x_direction)
    {
      // Colliding owl is leftwards, owl will move rightwards
      case LEFT: ai_move_y_direction_ = false;
        break;

      // Colliding owl is rightwards, owl will move leftwards
      case RIGHT: ai_move_y_direction_ = true;
        break;

      // Colliding owl is same coordinate, owl will randomly move leftwards or upwards
      case SAME:
      {
        // Randomise between 2 numbers
        int random = int(random(0, 2));

        switch (random)
        {
          case 0: ai_move_x_direction_ = false;
            break;

          case 1: ai_move_x_direction_ = true;
            break;
        }
      }
    }
  }

  /******************************************************************************/
  /*!
      Controls the direction the AI will move in the y-axis to avoid an owl
  */
  /******************************************************************************/
  private void Avoid_Owl_Y_Direction(Y_DIRECTION y_direction)
  {
    // First, check if it already moving away from colliding owl in the y-axis and return
    if ((is_moving_y_ && ai_move_y_direction_ == false && y_direction == Y_DIRECTION.ABOVE) || 
        (is_moving_y_ && ai_move_y_direction_ == true && y_direction == Y_DIRECTION.BELOW))
      return;

    // Makes it move in the y-axis if it is not already
    if (is_moving_y_ == false)
      is_moving_y_ = true;

    // Check which direction the colliding owl is on the y-axis
    switch (y_direction)
    {
      // Colliding owl is below, owl will move downwards
      case BELOW: ai_move_y_direction_ = true;
        break;

      // Colliding owl is above, owl will move upwards
      case ABOVE: ai_move_y_direction_ = false;
        break;

      // Colliding owl is same coordinate, owl will randomly move upwards or downwards
      case SAME:
      {
        // Randomise between 2 numbers
        int random = int(random(0, 2));

        switch (random)
        {
          case 0: ai_move_y_direction_ = false;
            break;

          case 1: ai_move_y_direction_ = true;
            break;
        }
      }
    }
  }

  /******************************************************************************/
  /*!
      Checks if this owl is to the left or right of the owl it is colliding with
  */
  /******************************************************************************/
  private X_DIRECTION Check_X_Colliding_Direction(Owl owl_check)
  {
    // If the checked owl's x minus this owl's x is equal to 0, it is in the same
    // x coordinate, returns SAME
    if (owl_check.owl_pos_.x - owl_pos_.x == 0)
      return X_DIRECTION.SAME;

    // If the checked owl's x minus this owl's x is lesser than 0, it's displacement
    // is negative x, meaning checked owl is to the left of this owl, returns LEFT
    else if ((owl_check.owl_pos_.x - owl_pos_.x < 0))
      return X_DIRECTION.LEFT;

    // Checked owl is to the right of this owl, return RIGHT
    else return X_DIRECTION.RIGHT;
  }

  /******************************************************************************/
  /*!
      Checks if this owl is above or below the owl it is colliding with
  */
  /******************************************************************************/
  private Y_DIRECTION Check_Y_Colliding_Direction(Owl owl_check)
  {
    // If the checked owl's y minus this owl's y is equal to 0, it is in the same
    // y coordinate, returns SAME
    if (owl_check.owl_pos_.y - owl_pos_.y == 0)
      return Y_DIRECTION.SAME;

    // If the checked owl's y minus this owl's y is lesser than 0, it's displacement
    // is negative y, meaning checked owl is above this owl, returns ABOVE
    else if ((owl_check.owl_pos_.y - owl_pos_.y < 0))
      return Y_DIRECTION.ABOVE;

    // Checked owl is below this owl, return BELOW
    else return Y_DIRECTION.BELOW;
  }

  /******************************************************************************/
  /*!
      Getter for is_ai
  */
  /******************************************************************************/
  boolean Get_AI()
  {
    boolean is_ai = is_ai_;

    return is_ai;
  }

  /******************************************************************************/
  /*!
      Setter for is_ai
  */
  /******************************************************************************/
  void Set_AI()
  {
    if (is_ai_)
    {
      is_ai_ = false;

      acc_speed_ = player_acc_speed_;
      deacc_speed_ = player_deacc_speed_;
      max_move_speed_ = player_max_move_speed_;
    }

    else
    {
      is_ai_ = true;

      acc_speed_ = ai_acc_speed_;
      deacc_speed_ = ai_deacc_speed_;
      max_move_speed_ = ai_max_move_speed_;
    }
  }
}
