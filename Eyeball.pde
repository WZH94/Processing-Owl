/******************************************************************************/
/*!
\file   Eyeball.pde
\author Wong Zhihao
\par    email: wongzhihao.student.utwente.nl
\date
\brief
  This file contains the implementation of the Eyeball component. This handles 
  the function that allows the eyeball to follow the cursor, and the drawing 
  of the eyeball.
*/
/******************************************************************************/

private class Eyeball
{
  private final float eyeball_size_;       // Size of the eyeball
  private final float eyeball_to_eye_gap;  // Distance of the gap between eyeball to eye when in the center
  private vec eyeball_pos_;          // Pos of the eyeball
  private final color eyeball_colour_;     // Colour of the eyeball
  
  // The radians from the mouse to the eyeball
  private float mouse_to_eyeball_radians_;
  
  // The vector from the mouse to the eyeball
  private vec mouse_to_eyeball_distance_;
  
  // Eyeball ratios
  private float eye_displacement_eyeball_to_eye_gap_x_;
  private float eye_displacement_eyeball_to_eye_gap_y_;
  
  /******************************************************************************/
  /*!
      Constructor for the eyeball, takes in the eye size
  */
  /******************************************************************************/
  Eyeball(float eye_size)
  {
    eyeball_size_ = eye_size * 0.15f;
    eyeball_colour_ = color (255);
    
    // The distance from the outer edge of the eyeball to the eye when centered
    eyeball_to_eye_gap = (eye_size - eyeball_size_);
    
    // The maximum displacement percentage of the eyeball to the eye
    eye_displacement_eyeball_to_eye_gap_x_ = eyeball_to_eye_gap * 0.35f;
    eye_displacement_eyeball_to_eye_gap_y_ = eyeball_to_eye_gap * 0.4f;
    
    mouse_to_eyeball_radians_ = 0;
    
    mouse_to_eyeball_distance_ = new vec();
    
    eyeball_pos_ = new vec();
  }
  
  /******************************************************************************/
  /*!
      Updates the eyeball
  */
  /******************************************************************************/
  void Update(vec owl_pos_, boolean is_ai)
  {    
    Update_Cursor_Eyeball_Tracking(owl_pos_, is_ai);
  }
  
  /******************************************************************************/
  /*!
      Draws the eyeball
  */
  /******************************************************************************/
  void Draw()
  {
    // Set art style
    fill(eyeball_colour_);
    noStroke();
    
    pushMatrix();
    translate(eyeball_pos_.x, eyeball_pos_.y);
    
    // Prints out the eyeballs
    ellipse(0, 0, eyeball_size_, eyeball_size_);
    
    popMatrix();
  }
  
  /******************************************************************************/
  /*!
      Updates the movement of the eyeball based on where the cursor is
  */
  /******************************************************************************/
  private void Update_Cursor_Eyeball_Tracking(vec owl_pos, boolean is_ai)
  {
    // Only tracks if is player controlled owl
    if (is_ai == false)
    {
      // Distances from cursor to individual eyeballs
      float diff_x = cursor.cursor_pos.x - eyeball_pos_.x - owl_pos.x;
      float diff_y = cursor.cursor_pos.y - eyeball_pos_.y - owl_pos.y;
      
      // Set the distances as vectors
      mouse_to_eyeball_distance_.x = diff_x;
      mouse_to_eyeball_distance_.y = diff_y;

      // Change the distances to unsigned values
      mouse_to_eyeball_distance_.x = (mouse_to_eyeball_distance_.x > 0) ? mouse_to_eyeball_distance_.x : (mouse_to_eyeball_distance_.x * -1);
      mouse_to_eyeball_distance_.y = (mouse_to_eyeball_distance_.y > 0) ? mouse_to_eyeball_distance_.y : (mouse_to_eyeball_distance_.y * -1);
        
      // Update the distances into fractions of the screen width and height
      mouse_to_eyeball_distance_.x /= (HALF_WIDTH);
      mouse_to_eyeball_distance_.y /= (HALF_HEIGHT);
      
      // If the fraction is more than 1, reset it to 1
      if (mouse_to_eyeball_distance_.x > 1)
        mouse_to_eyeball_distance_.x = 1;
        
      if (mouse_to_eyeball_distance_.y > 1)
        mouse_to_eyeball_distance_.y = 1;
        
      // Keep the minimum displacement to be 0.75
      if (mouse_to_eyeball_distance_.x < 0.75f)
        mouse_to_eyeball_distance_.x = 0.75f;
        
      if (mouse_to_eyeball_distance_.y < 0.75f)
        mouse_to_eyeball_distance_.y = 0.75f;

      // Find the radian through toa concept since I have opp (y-axis) and adj (x-axis) values
      mouse_to_eyeball_radians_ = atan (diff_y / diff_x);
      
      // Adjust the radian based on which quartile it is in
      if (diff_x < 0)
        mouse_to_eyeball_radians_ += PI;
        
      if (diff_x > 0 && diff_y < 0)
        mouse_to_eyeball_radians_ += TWO_PI;
        
      // Calculate how far the eyeballs move depending on where the mouse is
      eyeball_pos_.x = cos (mouse_to_eyeball_radians_) * eye_displacement_eyeball_to_eye_gap_x_ * mouse_to_eyeball_distance_.x;
      eyeball_pos_.y = sin (mouse_to_eyeball_radians_) * eye_displacement_eyeball_to_eye_gap_y_ * mouse_to_eyeball_distance_.y;
    }

    // Is AI controlled, reset to default position
    else
    {
      eyeball_pos_.x = 0;
      eyeball_pos_.y = 0;
    }
  }
}
