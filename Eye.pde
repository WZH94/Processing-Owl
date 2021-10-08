/******************************************************************************/
/*!
\file   Eye.pde
\author Wong Zhihao
\par    email: wongzhihao.student.utwente.nl
\date
\brief
  This file contains the implementation of the Eye component. The eye consists
  of an eyeball component, and handles the function that allows the eye to follow
  the cursor, and the drawing of the eye.
*/
/******************************************************************************/

private class Eye
{
  private Eyeball eyeball_;       // Component
  
  private final float eye_size_;        // Size Of the individual eyes relative to head size
  private final float eye_radius_;
  private final float eye_to_head_gap_; // Distance of the gap between eyes to head when in the center
  private vec eye_pos_;           // Position of the left eye
  private final color eye_colour_;      // Colour of the eyes

  private boolean eye_closed_;    // Whether the owl's eyes are closed
  
  // The radians from the mouse to the individiual eyes
  private float mouse_to_eye_radians_;
  
  // The vector from the mouse to the individual eyes
  private vec mouse_to_eye_distance_;
  
  // Eye ratios
  private float eye_displacement_eyes_to_head_gap_x_;
  private float eye_displacement_eyes_to_head_gap_y_;

  private final boolean which_eye_; // true is left eye, false is right eye
  
  /******************************************************************************/
  /*!
      Constructor for the eye, takes in the size of the head and whether it is
      the left or right eye
  */
  /******************************************************************************/
  Eye(float head_size, boolean which_eye)
  {
    which_eye_ = which_eye;

    eye_size_ = head_size * 0.7f;
    eye_radius_ = eye_size_ * 0.5f;
    
    // The distance from the outer edge of the eye to the head eye when centered
    eye_to_head_gap_ = (head_size - eye_size_) * 0.5f;
    
    // The maximum displacement percentage of the eye to the eyehead
    eye_displacement_eyes_to_head_gap_x_ = eye_to_head_gap_ * 0.6f;
    eye_displacement_eyes_to_head_gap_y_ = eye_to_head_gap_ * 0.5f;
    
    eye_colour_ = color(0);

    eye_closed_ = false;
    
    mouse_to_eye_radians_ = 0;
    
    eye_pos_ = new vec();
    
    mouse_to_eye_distance_ = new vec();
    
    // Creates the eyeball object for the eye
    eyeball_ = new Eyeball(eye_size_);
  }
    
  /******************************************************************************/
  /*!
      Updates the eye component
  */
  /******************************************************************************/
  void Update(vec head_pos, boolean is_ai)
  {
    Update_Cursor_Eye_Tracking(head_pos, is_ai);

    // Updates the eyeball component
    eyeball_.Update(head_pos, is_ai);
  }
  
  /******************************************************************************/
  /*!
      Draws the eye and its component
  */
  /******************************************************************************/
  void Draw()
  {  
    fill(eye_colour_);
    noStroke();

    // Translates from the eye coordinates
    pushMatrix();
    translate(eye_pos_.x, eye_pos_.y);

    // If the eye is closed, dont draw the eyeball and etc.
    if (eye_closed_)
    {
      stroke(0.2);

      // The two angles of the end coordinates of the line
      float angle_1;
      float angle_2;

      // Left eye
      if (which_eye_ == true)
      {
        angle_1 = radians(45);
        angle_2 = radians(225);
      }

      // Right eye
      else
      {
        angle_1 = radians(135);
        angle_2 = radians(315);
      }

      // Draws the line, magnitude of the vector is the eye radius
      line(eye_radius_ * cos(angle_1), eye_radius_ * sin(angle_1), eye_radius_ * cos(angle_2), eye_radius_ * sin(angle_2));
    }

    else
    {
      // Prints out the eyes
      ellipse(0, 0, eye_size_, eye_size_);
      
      // Draws the eyeball
      eyeball_.Draw();
   }

      popMatrix();
  }
  
  /******************************************************************************/
  /*!
      Updates the movement of the eyes based on where the cursor is
  */
  /******************************************************************************/
  private void Update_Cursor_Eye_Tracking(vec owl_pos, boolean is_ai)
  {
    // If the owl is player controlled, track the cursor from the eye
    if (is_ai == false)
    {
      // Distances from cursor to eye
      float diff_x = cursor.cursor_pos.x - eye_pos_.x - owl_pos.x;
      float diff_y = cursor.cursor_pos.y - eye_pos_.y - owl_pos.y;

      // Set the distance as vectors
      mouse_to_eye_distance_.x = diff_x;
      mouse_to_eye_distance_.y = diff_y;

      // Change the distances to unsigned values
      mouse_to_eye_distance_.x = (mouse_to_eye_distance_.x > 0) ? mouse_to_eye_distance_.x : (mouse_to_eye_distance_.x * -1);
      mouse_to_eye_distance_.y = (mouse_to_eye_distance_.y > 0) ? mouse_to_eye_distance_.y : (mouse_to_eye_distance_.y * -1);

      // Check if the mouse is on the eyes
      if (mouse_to_eye_distance_.x <= eye_radius_ && mouse_to_eye_distance_.y <= eye_radius_)
        eye_closed_ = true;

      else
      {
        eye_closed_ = false;
          
        // Update the distances into fractions of the screen width and height
        mouse_to_eye_distance_.x /= (HALF_WIDTH);
        mouse_to_eye_distance_.y /= (HALF_HEIGHT);
        
        // If the fraction is more than 1, reset it to 1
        if (mouse_to_eye_distance_.x > 1)
          mouse_to_eye_distance_.x = 1;
          
        if (mouse_to_eye_distance_.y > 1)
          mouse_to_eye_distance_.y = 1;
        
        // Find the radian through toa concept since I have opp (y-axis) and adj (x-axis) values
        mouse_to_eye_radians_ = atan (diff_y / diff_x);
        
        // Adjust the radian based on which quartile it is in
        if (diff_x < 0)
          mouse_to_eye_radians_ += PI;
          
        if (diff_x > 0 && diff_y < 0)
          mouse_to_eye_radians_ += TWO_PI;
          
        eye_pos_.x = cos (mouse_to_eye_radians_) * eye_displacement_eyes_to_head_gap_x_ * mouse_to_eye_distance_.x;  // how much to move the left eye towards the head on the x axis
        eye_pos_.y = sin (mouse_to_eye_radians_) * eye_displacement_eyes_to_head_gap_y_ * mouse_to_eye_distance_.y;  // how much to move the left eyes towards the head on the y axis
      }
    }

    // Is AI controlled, reset to default position
    else
    {
      eye_pos_.x = 0;
      eye_pos_.y = 0;
    }
  }

  /******************************************************************************/
  /*!
      Getter function for eye_closed_
  */
  /******************************************************************************/
  boolean AI_Get_Eye_Closed()
  {
    boolean status = eye_closed_;

    return status;
  }

  /******************************************************************************/
  /*!
      Setter function for eye_closed_
  */
  /******************************************************************************/
  void AI_Set_Eyes_Closed()
  {
    eye_closed_ = eye_closed_ ? false : true;
  }
}
