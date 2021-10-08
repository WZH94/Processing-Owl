/******************************************************************************/
/*!
\file   Head.pde
\author Wong Zhihao
\par    email: wongzhihao.student.utwente.nl
\date
\brief
  This file contains the implementation of the Head component. The head consists
  of the left and right eyes components, and handes the drawing of the ears,
  forehead, beak, headeyes and the eye component
*/
/******************************************************************************/

private class Head
{
  // Eyes component
  private Eye left_eye_;
  private Eye right_eye_;
  
  private final float head_size_;   // Size of the head relative to owl_size
  private vec left_head_pos_;      // Position of the left eye head
  private vec right_head_pos_;     // Position of the right eye head
  
  private vec actual_left_head_pos_;      // Position of the left eye head
  private vec actual_right_head_pos_;     // Position of the right eye head
  
  private final color head_outline_;     // Colour of the head outline
  private final color beak_colour_;      // Colour of the beak
  private final color forehead_colour_;  // Colour of the forehead
  
  // Head ratios
  private final float head_pos_head_size_x_;
  private final float head_pos_owl_size_y_;
  
  // Ear ratios
  private final float ear_bezier_owl_size_x_1_;
  private final float ear_bezier_owl_size_x_2_;
  private final float ear_bezier_owl_size_x_3_;
  private final float ear_bezier_owl_size_x_4_;
  private final float ear_bezier_owl_size_x_5_;
  
  private final float ear_bezier_owl_size_y_1_;
  private final float ear_bezier_owl_size_y_2_;
  private final float ear_bezier_owl_size_y_3_;
  private final float ear_bezier_owl_size_y_4_;
  private final float ear_bezier_owl_size_y_5_;
  
  // Forehead ratios
  private final float forehead_ellipse_owl_size_y_1_;
  private final float forehead_ellipse_head_size_x_1_;
  private final float forehead_ellipse_owl_size_y_2_;
  
  // Beak ratios
  private final float beak_bezier_head_size_x_start_;
  private final float beak_bezier_owl_size_y_start_;
  private final float beak_bezier_owl_size_x_1_;
  private final float beak_bezier_owl_size_x_2_;
  private final float beak_bezier_owl_size_x_4_;
  private final float beak_bezier_owl_size_x_5_;
  private final float beak_bezier_head_size_x_end_;
  
  private final float beak_bezier_owl_size_y_1_;
  private final float beak_bezier_owl_size_y_2_;
  private final float beak_bezier_owl_size_y_4_;
  private final float beak_bezier_owl_size_y_5_;
  private final float beak_bezier_owl_size_y_end_;
  
  /******************************************************************************/
  /*!
      Constructor for the Head, takes in the owl size and its coordinate
  */
  /******************************************************************************/
  Head (float owl_size, vec owl_pos)
  {
    head_size_ = owl_size;
    
    head_outline_ = color (173, 127, 82);
    beak_colour_ = color (234, 228, 90);
    forehead_colour_ = color (206, 158, 110);
    
    left_eye_ = new Eye (head_size_, true);
    right_eye_ = new Eye (head_size_, false);
    
    // Head part ratios
    head_pos_head_size_x_ = head_size_ * 0.5f;
    head_pos_owl_size_y_ = owl_size * 0.4f;
    
    // Sets positions of the eye heads from the center of the owl and offset based on head and owl size ratios
    left_head_pos_ = new vec (owl_pos.x - head_pos_head_size_x_, owl_pos.y - head_pos_owl_size_y_);
    right_head_pos_ = new vec (owl_pos.x + head_pos_head_size_x_, owl_pos.y - head_pos_owl_size_y_);
    
    actual_left_head_pos_ = new vec ();
    actual_right_head_pos_ = new vec ();
    
    // x-axis control points modifiers for the ear bezier
    ear_bezier_owl_size_x_1_ = owl_size * 0.2f;
    ear_bezier_owl_size_x_2_ = owl_size * 0.3f;
    ear_bezier_owl_size_x_3_ = owl_size * 0.35f;
    ear_bezier_owl_size_x_4_ = owl_size * 0.5f;
    ear_bezier_owl_size_x_5_ = owl_size * 0.6f;
    
    // y-axis control points modifiers for the ear bezier
    ear_bezier_owl_size_y_1_ = owl_size * 0.2f;
    ear_bezier_owl_size_y_2_ = owl_size * 0.4f;
    ear_bezier_owl_size_y_3_ = owl_size * 0.7f;
    ear_bezier_owl_size_y_4_ = owl_size * 0.8f;
    ear_bezier_owl_size_y_5_ = owl_size * 0.4f;
    
    // Forehead dimensions modifier for ellipse
    forehead_ellipse_owl_size_y_1_ = owl_size * 0.6f;
    forehead_ellipse_head_size_x_1_ = head_size_ * 1.5f;
    forehead_ellipse_owl_size_y_2_ = owl_size * 0.8f;
    
    // x-axis control points modifiers for beak bezier
    beak_bezier_head_size_x_start_ = head_size_ * 0.6f;
    beak_bezier_owl_size_y_start_ = owl_size * 0.5f;
    beak_bezier_owl_size_x_1_ = owl_size * 0.5f;
    beak_bezier_owl_size_x_2_ = owl_size * 0.3f;
    beak_bezier_owl_size_x_4_ = owl_size * 0.3f;
    beak_bezier_owl_size_x_5_ = owl_size * 0.5f;
    beak_bezier_head_size_x_end_ = head_size_ * 0.6f;
    
    // y-axis control points modifiers for beak bezier
    beak_bezier_owl_size_y_1_ = owl_size * 0.5f;
    beak_bezier_owl_size_y_2_ = owl_size * 0.2f;
    beak_bezier_owl_size_y_4_ = owl_size * 0.2f;
    beak_bezier_owl_size_y_5_ = owl_size * 0.5f;
    beak_bezier_owl_size_y_end_ = owl_size * 0.5f;
  }
  
  /******************************************************************************/
  /*!
      Updates coordinates of the head parts
  */
  /******************************************************************************/
  void Update(vec owl_pos, boolean is_ai)
  {    
    // Updates head eye positions before drawing anything
    left_head_pos_.x = -head_pos_head_size_x_;
    left_head_pos_.y = -head_pos_owl_size_y_;
    right_head_pos_.x = head_pos_head_size_x_;
    right_head_pos_.y = -head_pos_owl_size_y_;
    
    // The actual coordinate of the head eyes, translating with the coordinates from the
    // current transformation matrix
    actual_left_head_pos_.x = owl_pos.x + left_head_pos_.x;
    actual_left_head_pos_.y = owl_pos.y + left_head_pos_.y;
    actual_right_head_pos_.x = owl_pos.x + right_head_pos_.x;
    actual_right_head_pos_.y = owl_pos.y + right_head_pos_.y;
    
    left_eye_.Update(actual_left_head_pos_, is_ai); 
    right_eye_.Update(actual_right_head_pos_, is_ai);
  }
  
  /******************************************************************************/
  /*!
      Draws the parts and components of the head
  */
  /******************************************************************************/
  void Draw()
  {   
    /************************************* EARS *************************************/    
    // LEFT EAR
    
    beginShape();
    
    // Start point at the center of eye heads
    vertex(left_head_pos_.x, left_head_pos_.y);
    
    // Varying ratios
    bezierVertex(left_head_pos_.x - ear_bezier_owl_size_x_1_, left_head_pos_.y - ear_bezier_owl_size_y_1_, 
    left_head_pos_.x - ear_bezier_owl_size_x_2_, left_head_pos_.y - ear_bezier_owl_size_y_2_, 
    left_head_pos_.x - ear_bezier_owl_size_x_3_, left_head_pos_.y - ear_bezier_owl_size_y_3_);              //tip of the ear
    
    // Varying ratios
    bezierVertex(left_head_pos_.x - ear_bezier_owl_size_x_4_, left_head_pos_.y - ear_bezier_owl_size_y_4_, 
    left_head_pos_.x + ear_bezier_owl_size_x_5_, left_head_pos_.y - ear_bezier_owl_size_y_5_, 
    0, left_head_pos_.y);                                                                           // end point of the ear
    
    endShape();
    
    // RIGHT EAR
    
    beginShape();
    
    // Start point at the center of eye heads
    vertex(right_head_pos_.x, right_head_pos_.y);
    
    bezierVertex(right_head_pos_.x + ear_bezier_owl_size_x_1_, right_head_pos_.y - ear_bezier_owl_size_y_1_, 
    right_head_pos_.x + ear_bezier_owl_size_x_2_, right_head_pos_.y - ear_bezier_owl_size_y_2_, 
    right_head_pos_.x + ear_bezier_owl_size_x_3_, right_head_pos_.y - ear_bezier_owl_size_y_3_);              // tip of the ear
    
    bezierVertex(right_head_pos_.x + ear_bezier_owl_size_x_4_, right_head_pos_.y - ear_bezier_owl_size_y_4_, 
    right_head_pos_.x - ear_bezier_owl_size_x_5_, right_head_pos_.y - ear_bezier_owl_size_y_5_, 
    0, right_head_pos_.y);                                                                            // end point of the ear
    
    endShape();
    
    /************************************* FOREHEAD *************************************/
        
    fill(forehead_colour_);
    stroke(0);    
    strokeWeight(4.0f);

    ellipse(0, -forehead_ellipse_owl_size_y_1_, forehead_ellipse_head_size_x_1_, forehead_ellipse_owl_size_y_2_);
    
    /************************************* BEAK *************************************/
    
    fill(beak_colour_);
    
    beginShape();
    
    // start point of the beak
    vertex (-beak_bezier_head_size_x_start_, -beak_bezier_owl_size_y_start_);
    
    bezierVertex (-beak_bezier_owl_size_x_1_, -beak_bezier_owl_size_y_1_, 
    -beak_bezier_owl_size_x_2_, -beak_bezier_owl_size_y_2_, 
    0, 10.0f);                                                                // tip of the beak
    
    bezierVertex(beak_bezier_owl_size_x_4_, -beak_bezier_owl_size_y_4_, 
    beak_bezier_owl_size_x_5_, -beak_bezier_owl_size_y_5_, 
    beak_bezier_head_size_x_end_, -beak_bezier_owl_size_y_end_);           // end point of the beak
    
    endShape();
    
    /************************************* HEAD EYES *************************************/
    
    fill(255);
    stroke(head_outline_);
    strokeWeight(5.0f);

    if (left_eye_.AI_Get_Eye_Closed() == true)
      fill(forehead_colour_);

    else fill(255);

    ellipse(left_head_pos_.x, left_head_pos_.y, head_size_, head_size_);

    if (right_eye_.AI_Get_Eye_Closed() == true)
      fill(forehead_colour_);

    else fill(255);
    
    ellipse(right_head_pos_.x, right_head_pos_.y, head_size_, head_size_);
    
    // Draws the eyes
    
    pushMatrix();
    translate(left_head_pos_.x, left_head_pos_.y);   
    
    left_eye_.Draw();    
    
    popMatrix();
    
    pushMatrix();
    translate(right_head_pos_.x, right_head_pos_.y);  
    
    right_eye_.Draw();
    
    popMatrix();
  }

  /******************************************************************************/
  /*!
      Getter for the left and right eye eyes closed variables. Checks both
  */
  /******************************************************************************/
  boolean AI_Get_Eyes_Closed()
  {
    if (left_eye_.AI_Get_Eye_Closed() || right_eye_.AI_Get_Eye_Closed()
)      return true;

    else return false;
  }

  /******************************************************************************/
  /*!
      Setter for the left and right eye eys closed variables.
  */
  /******************************************************************************/
  void AI_Set_Eyes_Closed()
  {
    left_eye_.AI_Set_Eyes_Closed();
    right_eye_.AI_Set_Eyes_Closed();
  }
}
