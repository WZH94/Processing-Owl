/******************************************************************************/
/*!
\file   Body.pde
\author Wong Zhihao
\par    email: wongzhihao.student.utwente.nl
\date
\brief
  This file contains the implementation of the Body component. The body consists
  of a Wings component, and handles the drawing of the stomach and the feet
*/
/******************************************************************************/

private class Body 
{
  private Wings wings_;        // Contains the wings component
  
  // Width and height modifiers of the stomach
  private final float body_width_;
  private final float body_height_;

  // Colour of the components
  private final color body_colour_;
  private final color feet_colour_;
  
  // Body ratios
  private final float stomach_bezier_owl_size_;

  private final int num_of_feet_;
  
  /******************************************************************************/
  /*!
      Constructor
  */
  /******************************************************************************/
  Body(float owl_size) 
  { 
    // Initialise class member variables
    body_width_ = owl_size * 1.5f;
    body_height_ = owl_size * 1.3f;
    
    body_colour_ = color (206, 158, 110);
    feet_colour_ = color (232, 106, 28);
    
    // Create memory of component
    wings_ = new Wings(owl_size);
    
    // Initialise body ratios
    stomach_bezier_owl_size_ = owl_size * 0.5f;

    num_of_feet_ = 3;
  }
  
  /******************************************************************************/
  /*!
      Updates the components of the body
  */
  /******************************************************************************/
  void Update(float owl_size, Owl owl)
  {
    wings_.Update(owl_size, owl);
  }
  
  /******************************************************************************/
  /*!
      Draws the components and parts of the body, transformation matrix from
      owl pos
  */
  /******************************************************************************/
  void Draw() 
  {    
    /************************************* FEET *************************************/
    
    fill(feet_colour_);
    stroke(0);
    strokeWeight(3.0f);
    
    float radians = 0;  // The rotation of each subsequent feet/claw
    
    // Draws the left feets
    for (int i = 0; i < num_of_feet_; ++i)
    {
      // Rotates every subsequent feet
      pushMatrix();
      radians += radians(10);
      rotate(radians);

      ellipse(0, body_height_ * 0.65f, body_width_ * 0.12f, body_height_ * 0.22f);

      popMatrix();
    }
    
    // Reset the radians for the next side
    radians = 0;
    
    // Draws the right feets
    for (int i = 0; i < num_of_feet_; ++i)
    {
      pushMatrix();
      radians -= radians(10);
      rotate(radians);

      ellipse(0, body_height_ * 0.65f, body_width_ * 0.12f, body_height_ * 0.22f);

      popMatrix();
    }
    
    /************************************* STOMACH *************************************/
    
    fill(body_colour_);
    stroke(0);    
    strokeWeight(4.0f);
    
    bezier (-stomach_bezier_owl_size_, -stomach_bezier_owl_size_,   // start pos
            -body_width_, body_height_, 
            body_width_, body_height_, 
            stomach_bezier_owl_size_,  -stomach_bezier_owl_size_);  // end pos
            
    // Draws the wings component
    wings_.Draw();
  }

  /******************************************************************************/
  /*!
      Calls the wings function to toggle flying. Called from Owl class
  */
  /******************************************************************************/
  void Toggle_Flying()
  {
    wings_.Toggle_Flying();
  }
  
  /******************************************************************************/
  /*!
      Gets the state of the owl flying from the wings function. Called from Owl
      class
  */
  /******************************************************************************/
  boolean Get_Is_Flying()
  {
    return wings_.Get_Is_Flying();
  }
}
