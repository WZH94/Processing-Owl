/******************************************************************************/
/*!
\file   Moon.pde
\author Wong Zhihao
\par    email: wongzhihao.student.utwente.nl
\date
\brief
  This file contains the implementation of the Moon component. The Moon rises
  from the left side of the screen when night starts and ends up at the right
  side of the screen when night ends. Its coordinate does not change, and is
  only translated from a vector.
*/
/******************************************************************************/

class Moon {
  private final PImage texture_;          // Texture of the object
  private final vec pos_;                 // Coordinates of the object, DOES NOT CHANGE
  private final float size_;              // Size of the object
  private final float radius_;            // Radius of the object
  
  private float offset_magnitude_;  // Magnitude to offset from bottom edge of the canvas
  private float current_radians_;   // Angle of the vector to offset
  private vec vector_position_;     // Vector that offsets, coordinate is translated from this vector

  /******************************************************************************/
  /*!
      Default Constructor
  */
  /******************************************************************************/
  Moon()
  {
    texture_ = loadImage("bbb_moon.png");

    // Positions moon in the center of the canvas, and at the bottom
    pos_ = new vec(HALF_WIDTH, height);

    // Size of the moon scales according to width of canvas
    size_ = width * 0.1f;
    radius_ = size_ / 2;
    
    // Offset by half of the canvas width
    offset_magnitude_ = HALF_WIDTH;
    // Default radians is 90 degrees upwards
    current_radians_ = HALF_PI;
    vector_position_ = new vec();
  }
  
  /******************************************************************************/
  /*!
      Updates the moon, takes in parameters from the Sky
  */
  /******************************************************************************/
  void Update(float time_of_day, float dusk_time, float dawn_time)
  {
    // Check if the time of day is at night, then the moon should be at the top half of the canvas
    if (time_of_day >= dusk_time && time_of_day <= dawn_time)
    { 
      // Starts out from PI radians, or Left side of map, and minus off fractions of PI calculated
      // by how much it has progressed into the night. Ends up at radians 0, or Right side of map
      current_radians_ = PI - ((time_of_day - dusk_time) / (dawn_time - dusk_time) * PI);
    }

    // Snap moon outside of canvas during day
    else current_radians_ = PI + HALF_PI;

    // Calculates the vector that will offset the moon from its position
    Calculate_Vector_Position();
  }
  
  /******************************************************************************/
  /*!
      Draws the moon
  */
  /******************************************************************************/
  void Draw()
  {
    pushMatrix();
    // Translates from vector postiion
    translate(vector_position_.x, -vector_position_.y);

    image(texture_, pos_.x, pos_.y, size_, size_);

    popMatrix();
  }
  
  /******************************************************************************/
  /*!
      Calculate the vector that will offset the moon from its postition, based on 
      the radians calculated before
  */
  /******************************************************************************/
  private void Calculate_Vector_Position()
  {
    vector_position_.x = cos(current_radians_) * offset_magnitude_;
    vector_position_.y = sin(current_radians_) * offset_magnitude_;
  }
}
