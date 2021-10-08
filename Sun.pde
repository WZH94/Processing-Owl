/******************************************************************************/
/*!
\file   Sun.pde
\author Wong Zhihao
\par    email: wongzhihao.student.utwente.nl
\date
\brief
  This file contains the implementation of the Sun component. The Sun rises
  from the left side of the screen when day starts and ends up at the right
  side of the screen when day ends. Its coordinate does not change, and is
  only translated from a vector.
*/
/******************************************************************************/

class Sun {
  private final PImage texture_;        // Texture of the object
  private final SoundFile screaming_;

  private final vec pos_;               // Coordinates of the object, DOES NOT CHANGE
  private final float size_;            // Size of the object
  private final float radius_;          // Radius of the object
      
  private float offset_magnitude_;      // Magnitude to offset from bottom edge of the canvas
  private float current_radians_;       // Angle of the vector to offset
  private vec vector_position_;         // Vector that offsets, coordinate is translated from this vector

  /******************************************************************************/
  /*!
      Default Constructor
  */
  /******************************************************************************/
  Sun()
  {
    texture_ = loadImage("screaming_sun.png");

    screaming_ = new SoundFile(main.this, "screaming_sun_mono.wav");
    screaming_.loop();

    // Positions sun in the center of the canvas, and at the bottom
    pos_ = new vec(HALF_WIDTH, height);

    // Size of the sun scales according to width of canvas
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
      Updates the sun, takes in parameters from the Sky
  */
  /******************************************************************************/
  void Update(float time_of_day, float length_of_day, float noon_time, float dusk_time, float dawn_time)
  {
    // Check if the time of day is at day, and is between noon and dusk, from 0 
    if (time_of_day >= noon_time && time_of_day <= dusk_time)
    {
      // Since length of day is not linear and is split at 1 to 0, this is from noon, so it starts out at half PI, 90
      // degrees upwards, and sets at 0, right side of the screen. Minus off fractions of half PI calculated
      // by how much it has progressed into the day.
      current_radians_ = HALF_PI - ((time_of_day - noon_time) / (dusk_time - noon_time) * HALF_PI);
    }

    // The other half of the day, from between 0 to 1 to 1
    else if (time_of_day >= dawn_time && time_of_day <= length_of_day)
    {
      // Starts out at PI, at left side of screen and ends up at noon
      current_radians_ = PI - ((time_of_day - dawn_time) / (length_of_day - dawn_time) * HALF_PI);
    }

    // Snap sun outside of canvas during night
    else current_radians_ = PI + HALF_PI;

    // Calculates the vector that will offset the moon from its position
    Calculate_Vector_Position();

    //Set_Screaming_Properties(time_of_day, length_of_day, noon_time, dusk_time, dawn_time);
  }
  
  /******************************************************************************/
  /*!
      Draws the sun
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
      Calculate the vector that will offset the sun from its postition, based on 
      the radians calculated before
  */
  /******************************************************************************/
  private void Calculate_Vector_Position()
  {
    vector_position_.x = cos(current_radians_) * offset_magnitude_;
    vector_position_.y = sin(current_radians_) * offset_magnitude_;
  }
}
