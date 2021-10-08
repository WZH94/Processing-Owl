/******************************************************************************/
/*!
\file   Wings.pde
\author Wong Zhihao
\par    email: wongzhihao.student.utwente.nl
\date
\brief
  This file contains the implementation of the Wings component. This handles 
  the flapping of the wings and also affects the hovering distance based on
  the angle of the wings.
*/
/******************************************************************************/

class Wings
{
  // Point where the wing pivots from (top)
  private vec left_wing_pivot_pos_;
  private vec right_wing_pivot_pos_;

  // Point where the wing swings from (bottom)
  private vec left_wing_swing_pos_;
  private vec right_wing_swing_pos_;
  
  // Point between pivot and swing pos
  private vec left_wing_midpoint_pos_;
  private vec right_wing_midpoint_pos_;
  
  // The vector from the midpoint to the pivot/swing point, and the normalised vector towards the wingtip
  private vec left_wing_vec_;
  private vec left_wing_normal_vec_;
  private vec right_wing_vec_;
  private vec right_wing_normal_vec_;
  
  // Point of the tip of the wings
  private vec left_wing_tip_pos_;
  private vec right_wing_tip_pos_;
  
  // Magnitude of the vector from midpoint to pivot/swing point, used to normalise the vector
  private final float vector_magnitude_;
  
  private final float wingspan_;           // How long ONE wing is
  private final float wing_width_;         // Width of the wing at the WIDEST point
  private float wing_angle_;               // What angle the wing is at currently
    
  private final color wing_colour_;        // Colour of the wing
    
  private boolean flap_direction_;         // True wings flap upwards, false downwards
  private float wing_speed_;               // Speed wings flap at
    
  private final float max_angle_;          // Max angle the wing can flap to
  private final float min_angle_;          // Min angle the wing can flap to
  
  // Percentages of the wing flap angle's from the center that do not flap at max speed
  private final float upper_angle_speed_threshold_;
  private final float lower_angle_speed_threshold_;
  
  private final float hover_min_distance_; // The min distance the owl can hover while flying, also the max distance from lifting off
  private final float hover_max_distance_; // The max distance IN ADDITION to the min distance the owl can hover while flying
  
  private boolean is_flying_;              // If owl is flying
  private boolean is_lifting_off_;         // If owl is lifting off
  private boolean is_preparing_to_land_;   // If owl is preparing to landing
  private boolean is_landing_;             // If owl is landing

  /******************************************************************************/
  /*!
      Constructor that takes in the size of the owl
  */
  /******************************************************************************/
  Wings(float owl_size)
  {
    // Start out flapping upwards
    flap_direction_ = true;
    wing_speed_ = 20 * (PI / 180);
    
    max_angle_ = 180 * (PI / 180);
    min_angle_ = 18 * (PI / 180);
    
    upper_angle_speed_threshold_ = (max_angle_ - min_angle_) * 0.6;
    lower_angle_speed_threshold_ = (max_angle_ - min_angle_) * 0.4;
    
    left_wing_pivot_pos_ = new vec (-owl_size * 0.5f,  -owl_size * 0.4f);
    
    wingspan_ = owl_size * 1.15f;
    wing_width_ = owl_size * 0.5f;
    wing_angle_ = 19 * (PI / 180);
    
    // Find the bottom wing coord (adj = x, opp = y), using cah and soh, since I have the angle and hyp (the wing width * fraction)
    float adj = wing_width_ * cos(wing_angle_ );
    float opp = wing_width_ * sin(wing_angle_ );
    
    left_wing_swing_pos_ = new vec(adj + left_wing_pivot_pos_.x, opp + left_wing_pivot_pos_.y);
    
    // Find the midpoint between both coords
    left_wing_midpoint_pos_ = new vec((left_wing_swing_pos_.x + left_wing_pivot_pos_.x) * 0.5f, (left_wing_swing_pos_.y + left_wing_pivot_pos_.y) * 0.5f);
    
    // Find the vector and normal vector from midpoint to pivot pos
    left_wing_vec_ = new vec(left_wing_pivot_pos_.x - left_wing_midpoint_pos_.x, left_wing_pivot_pos_.y - left_wing_midpoint_pos_.y);
    
    // Find the magnitude of the vector
    vector_magnitude_ = sqrt((left_wing_vec_.x) * (left_wing_vec_.x) + (left_wing_vec_.y) * (left_wing_vec_.y));
    
    // Normalise the vector
    left_wing_vec_.x /= vector_magnitude_;
    left_wing_vec_.y /= vector_magnitude_;
    
    // Find the normal vector
    left_wing_normal_vec_ = new vec(left_wing_vec_.y, -left_wing_vec_.x);
    
    // Find the tip of the wing with the normal vector multiplied by wingspan
    left_wing_tip_pos_ = new vec(left_wing_midpoint_pos_.x + left_wing_normal_vec_.x * wingspan_, left_wing_midpoint_pos_.y + left_wing_normal_vec_.y * wingspan_);
    
    // REPEAT THE SAME FOR RIGHT WING BUT MIRRORED X AXIS
    
    right_wing_pivot_pos_ = new vec(owl_size * 0.5f, owl_size * 0.4f);
    
     // Find the bottom wing coord (adj = x, opp = y), using cah and soh, since I have the angle and hyp (the wing width * fraction)
    right_wing_swing_pos_ = new vec(right_wing_pivot_pos_.x - adj, opp + right_wing_pivot_pos_.y);
    
    // Find the midpoint between both coords
    right_wing_midpoint_pos_ = new vec((right_wing_swing_pos_.x + right_wing_pivot_pos_.x) * 0.5f, (right_wing_swing_pos_.y + right_wing_pivot_pos_.y) * 0.5f);
    
    // Find the vector and normal vector from midpoint to pivot pos
    right_wing_vec_ = new vec(right_wing_pivot_pos_.x - right_wing_midpoint_pos_.x, right_wing_pivot_pos_.y - right_wing_midpoint_pos_.y);
    
    // Normalise the vector
    right_wing_vec_.x /= vector_magnitude_;
    right_wing_vec_.y /= vector_magnitude_;
    
    // Find the normal vector
    right_wing_normal_vec_ = new vec(-right_wing_vec_.y, right_wing_vec_.x);
    
    // Find the tip of the wing with the normal vector multiplied by wingspan
    right_wing_tip_pos_ = new vec(right_wing_midpoint_pos_.x + right_wing_normal_vec_.x * wingspan_, right_wing_midpoint_pos_.y + right_wing_normal_vec_.y * wingspan_);

    hover_min_distance_ = owl_size * 0.5f;
    hover_max_distance_ = owl_size * 0.45f;
    
    wing_colour_ = color (129, 115, 74);
    
    is_flying_ = false;
    is_lifting_off_ = false;
    is_preparing_to_land_ = false;
    is_landing_ = false;
  }
  
  /******************************************************************************/
  /*!
      Updates the wings
  */
  /******************************************************************************/
  void Update(float owl_size, Owl owl)
  {
    left_wing_pivot_pos_.x = -owl_size * 0.5f;
    left_wing_pivot_pos_.y = -owl_size * 0.4f;
    right_wing_pivot_pos_.x = owl_size * 0.5f;
    right_wing_pivot_pos_.y = -owl_size * 0.4f;
    
    Flap_Wings(owl);
    
    /**************************** LEFT WING /****************************/
    
    // Find the bottom wing coord (adj = x, opp = y), using cah and soh, since I have the angle and hyp (the wing width * fraction)
    float adj = wing_width_ * cos (wing_angle_ );
    float opp = wing_width_ * sin (wing_angle_ );
    
    left_wing_swing_pos_.x = adj + left_wing_pivot_pos_.x;
    left_wing_swing_pos_.y = opp + left_wing_pivot_pos_.y;
    
    // Find the midpoint between both coords
    left_wing_midpoint_pos_.x = (left_wing_swing_pos_.x + left_wing_pivot_pos_.x) * 0.5f;
    left_wing_midpoint_pos_.y = (left_wing_swing_pos_.y + left_wing_pivot_pos_.y) * 0.5f;
    
    // Find the vector and normal vector from midpoint to pivot pos
    left_wing_vec_.x = left_wing_pivot_pos_.x - left_wing_midpoint_pos_.x;
    left_wing_vec_.y = left_wing_pivot_pos_.y - left_wing_midpoint_pos_.y;
    
    // Normalise the vector
    left_wing_vec_.x /= vector_magnitude_;
    left_wing_vec_.y /= vector_magnitude_;
    
    // Find the normal vector
    left_wing_normal_vec_.x = left_wing_vec_.y;
    left_wing_normal_vec_.y = -left_wing_vec_.x;
    
    // Find the tip of the wing with the normal vector multiplied by wingspan
    left_wing_tip_pos_.x = left_wing_midpoint_pos_.x + left_wing_normal_vec_.x * wingspan_;
    left_wing_tip_pos_.y = left_wing_midpoint_pos_.y + left_wing_normal_vec_.y * wingspan_;
    
    /**************************** RIGHT WING /****************************/
    
    // Find the bottom wing coord (adj = x, opp = y), using cah and soh, since I have the angle and hyp (the wing width * fraction)
    right_wing_swing_pos_.x = right_wing_pivot_pos_.x - adj;
    right_wing_swing_pos_.y = opp + right_wing_pivot_pos_.y;
    
    // Find the midpoint between both coords
    right_wing_midpoint_pos_.x = (right_wing_swing_pos_.x + right_wing_pivot_pos_.x) * 0.5f;
    right_wing_midpoint_pos_.y = (right_wing_swing_pos_.y + right_wing_pivot_pos_.y) * 0.5f;
    
    // Find the vector and normal vector from midpoint to pivot pos
    right_wing_vec_.x = right_wing_pivot_pos_.x - right_wing_midpoint_pos_.x;
    right_wing_vec_.y = right_wing_pivot_pos_.y - right_wing_midpoint_pos_.y;
    
    // Normalise the vector
    right_wing_vec_.x /= vector_magnitude_;
    right_wing_vec_.y /= vector_magnitude_;
    
    // Find the normal vector
    right_wing_normal_vec_.x = -right_wing_vec_.y;
    right_wing_normal_vec_.y = right_wing_vec_.x;
    
    // Find the tip of the wing with the normal vector multiplied by wingspan
    right_wing_tip_pos_.x = right_wing_midpoint_pos_.x + right_wing_normal_vec_.x * wingspan_;
    right_wing_tip_pos_.y = right_wing_midpoint_pos_.y + right_wing_normal_vec_.y * wingspan_;
  }
  
  /******************************************************************************/
  /*!
      Draws the wings
  */
  /******************************************************************************/
  void Draw()
  {    
    fill(wing_colour_);
    
    // LEFT WING
    beginShape();

    vertex(left_wing_pivot_pos_.x, left_wing_pivot_pos_.y);
    
    bezierVertex((left_wing_midpoint_pos_.x + left_wing_normal_vec_.x * wingspan_ * 0.5f) + left_wing_vec_.x * wing_width_ * 1.3f, 
    (left_wing_midpoint_pos_.y + left_wing_normal_vec_.y * wingspan_ * 0.5f) + left_wing_vec_.y * wing_width_ * 1.3f,
    (left_wing_midpoint_pos_.x + left_wing_normal_vec_.x * wingspan_ * 0.8f) + left_wing_vec_.x * wing_width_ * 0.5f, 
    (left_wing_midpoint_pos_.y + left_wing_normal_vec_.y * wingspan_ * 0.8f) + left_wing_vec_.y * wing_width_ * 0.5f,
    left_wing_tip_pos_.x, left_wing_tip_pos_.y);
    
    bezierVertex((left_wing_midpoint_pos_.x + left_wing_normal_vec_.x * wingspan_ * 0.8f) - left_wing_vec_.x * wing_width_* 0.5f, 
    (left_wing_midpoint_pos_.y + left_wing_normal_vec_.y * wingspan_ * 0.8f) - left_wing_vec_.y * wing_width_ * 0.5f,
    (left_wing_midpoint_pos_.x + left_wing_normal_vec_.x * wingspan_ * 0.5f) - left_wing_vec_.x * wing_width_ * 1.3f, 
    (left_wing_midpoint_pos_.y + left_wing_normal_vec_.y * wingspan_ * 0.5f) - left_wing_vec_.y * wing_width_ * 1.3f,
    left_wing_swing_pos_.x, left_wing_swing_pos_.y);

    endShape();
    
    line(left_wing_pivot_pos_.x, left_wing_pivot_pos_.y, left_wing_swing_pos_.x, left_wing_swing_pos_.y);
    
    // RIGHT WING
    beginShape();

    vertex(right_wing_pivot_pos_.x, right_wing_pivot_pos_.y);
    
    bezierVertex((right_wing_midpoint_pos_.x + right_wing_normal_vec_.x * wingspan_ * 0.5f) + right_wing_vec_.x * wing_width_ * 1.3f, 
    (right_wing_midpoint_pos_.y + right_wing_normal_vec_.y * wingspan_ * 0.5f) + right_wing_vec_.y * wing_width_ * 1.3f,
    (right_wing_midpoint_pos_.x + right_wing_normal_vec_.x * wingspan_ * 0.8f) + right_wing_vec_.x * wing_width_ * 0.5f, 
    (right_wing_midpoint_pos_.y + right_wing_normal_vec_.y * wingspan_ * 0.8f) + right_wing_vec_.y * wing_width_ * 0.5f,
    right_wing_tip_pos_.x, right_wing_tip_pos_.y);
    
    bezierVertex((right_wing_midpoint_pos_.x + right_wing_normal_vec_.x * wingspan_ * 0.8f) - right_wing_vec_.x * wing_width_* 0.5f, 
    (right_wing_midpoint_pos_.y + right_wing_normal_vec_.y * wingspan_ * 0.8f) - right_wing_vec_.y * wing_width_ * 0.5f,
    (right_wing_midpoint_pos_.x + right_wing_normal_vec_.x * wingspan_ * 0.5f) - right_wing_vec_.x * wing_width_ * 1.3f, 
    (right_wing_midpoint_pos_.y + right_wing_normal_vec_.y * wingspan_ * 0.5f) - right_wing_vec_.y * wing_width_ * 1.3f,
    right_wing_swing_pos_.x, right_wing_swing_pos_.y);
    
    endShape();
    
    line(right_wing_pivot_pos_.x, right_wing_pivot_pos_.y, right_wing_swing_pos_.x, right_wing_swing_pos_.y);
  }
  
  /******************************************************************************/
  /*!
      Toggles flying based on whether it is already flying, and which part of the
      landing or lifting off process it is at
  */
  /******************************************************************************/
  void Toggle_Flying()
  {
    // It can only start to lift off if NONE of these conditions are true)
    if (is_flying_ == false && is_lifting_off_ == false && is_preparing_to_land_ == false && is_landing_ == false)
    {
      is_lifting_off_ = true;
    }
    
    // You can cancel preparing to land and continue flying
    else if (is_flying_ == false && is_preparing_to_land_ == true)
    {
      is_flying_ = true;
      is_preparing_to_land_ = false;
    }
    
    // It can only start to land if it is flying
    else if (is_flying_ == true)
    {
      is_flying_ = false;
      is_preparing_to_land_ = true;
    }
  }
  
  /******************************************************************************/
  /*!
      Getter function
  */
  /******************************************************************************/
  boolean Get_Is_Flying()
  {
    return is_flying_;
  }
  
  /******************************************************************************/
  /*!
      Logic for how quicly the wings flap and in which direction based on its
      flying status
  */
  /******************************************************************************/
  void Flap_Wings(Owl owl)
  {
    // Owl is lifting off
    if (is_lifting_off_)
    {
      // Increase angle to make the wings move upwards, lifting is slower
      wing_angle_ += wing_speed_ *  Wing_Speed_Modifier() * 0.7f;

      // Check if angle has increased past the max angle
      if (wing_angle_ > max_angle_)
      {
        // Snap angle to max angle and change the flap direction to flap downwards
        wing_angle_ = max_angle_;
        flap_direction_ = false;
        
        is_lifting_off_ = false;
        is_flying_ = true;
      }
      
      Calculate_Hover_Distance_Lift_Off_Landing(owl);
    }
    
    // Owl is already flying
    else if (is_flying_)
    {
      // Check the flap direction
      if (flap_direction_ == true)
      {
        // Increase angle to make the wings move upwards
        wing_angle_ += wing_speed_ *  Wing_Speed_Modifier();
        
        // Check if angle has increased past the max angle
        if (wing_angle_ > max_angle_)
        {
          // Reset angle to max angle and change the flap direction to flap downwards
          wing_angle_ = max_angle_;
          flap_direction_ = false;
        }
      }
      
      // Same as above
      if (flap_direction_ == false)
      {
        wing_angle_ -= wing_speed_ *  Wing_Speed_Modifier();
        
        if (wing_angle_ < min_angle_)
        {
          wing_angle_ = min_angle_;
          flap_direction_ = true;
        }
      }
      
      Calculate_Hover_Distance(owl);
    }
    
    // The owl is no longer flying and preparing to land
    else if (is_preparing_to_land_ == true)
    {
      // Check if the wing is still flapping upwards and let it complete that motion first
      if (flap_direction_ == true)
      {
        // Increase angle to make the wings move upwards
        wing_angle_ += wing_speed_ *  Wing_Speed_Modifier();
        
        // Check if angle has increased past the max angle
        if (wing_angle_ > max_angle_)
        {
          // Reset angle to max angle and change the flap direction to flap downwards
          wing_angle_ = max_angle_;
          flap_direction_ = false;
          
          // Owl is prepared to land now
          is_preparing_to_land_ = false;
          is_landing_ = true;
        }
        
        Calculate_Hover_Distance(owl);
      }
      
      // Check if the wing is flapping downwards and let it complete one full motion first
      else if (flap_direction_ == false)
      {
        wing_angle_ -= wing_speed_ *  Wing_Speed_Modifier();
        
        if (wing_angle_ < min_angle_)
        {
          wing_angle_ = min_angle_;
          flap_direction_ = true;
        }
        
        Calculate_Hover_Distance(owl);
      }
    }
    
    // Owl has finished preparing to land is will land now
    else if (is_landing_ == true)
    {
      // And decrease the angle accordingly until it reaches the min angle
      wing_angle_ -= wing_speed_ *  Wing_Speed_Modifier() * 0.5f;
      
      // Snaps
      if (wing_angle_ < min_angle_)
      {
        wing_angle_ = min_angle_;
        flap_direction_ = true;
        
        is_landing_ = false;
      }
      
      Calculate_Hover_Distance_Lift_Off_Landing(owl);
    }
  }
  
  /******************************************************************************/
  /*!
      Calculates the speed of the flapping of the wing based on its angle between
      the middle and the top and bottom angles
  */
  /******************************************************************************/
  float Wing_Speed_Modifier()
  {
    // If wing is within the lower half of its movement angle
    if (wing_angle_ < lower_angle_speed_threshold_)
      return (wing_angle_ / lower_angle_speed_threshold_);
    
    // If wing is within the upper half of its movement angle
    else if (wing_angle_ > upper_angle_speed_threshold_)
      return (upper_angle_speed_threshold_ / wing_angle_);
    
    // Wing is in the middle, return 1 for max speed
    else return 1;
  }
  
  /******************************************************************************/
  /*!
      Calculates how much the owl should hover when flying
  */
  /******************************************************************************/
  void Calculate_Hover_Distance(Owl owl)
  {
    // Difference between the max angle and the current wing angle, fraction of
    // the total angle it can fly at
    float wing_angle_ratio = (max_angle_ - wing_angle_) / (max_angle_ - min_angle_);
    
    // While flying, it is hovering above the min distance already
    owl.Hover((hover_max_distance_ * wing_angle_ratio) + hover_min_distance_);
  }

  /******************************************************************************/
  /*!
      Calculates how much the owl should hover when lifting off and landing
  */
  /******************************************************************************/
  void Calculate_Hover_Distance_Lift_Off_Landing(Owl owl)
  {
    // How far the wing angle is above the min angle, fraction of
    // the total angle it can fly at
    float wing_angle_ratio = (wing_angle_ - min_angle_) / (max_angle_ - min_angle_);
    
    owl.Hover(hover_min_distance_ * wing_angle_ratio);
  }
}
