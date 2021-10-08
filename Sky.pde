/******************************************************************************/
/*!
\file   Sky.pde
\author Wong Zhihao
\par    email: wongzhihao.student.utwente.nl
\date
\brief
  This file contains the implementation of the Sky class. The sky consists
  of a Sun and Moion components. It contains the position, size, speed and other
  variables that affect the behaviour of the owl. The other components are 
  dependent on the variables of these class. This class mainly handles the
  movement and positioning of the owl.
*/
/******************************************************************************/

class Sky {
  // Components of Sky
  private Sun sun_;
  private Moon moon_;
  
  private float time_elapsed_;          // How much time has passed in the program, converted to seconds
  private final float length_of_day_;   // How long a day lasts in seconds

  // Noon to Sunset to Dusk to Midnight to Dawn to Sunrise
  private final float noon_time_;
  private final float late_noon_time_;
  private final float sunset_time_;
  private final float dusk_time_;
  private final float midnight_time_;
  private final float dawn_time_;
  private final float sunrise_time_;

  private float time_of_day_;           // In seconds, from 0 to length of day

  // Colours of the times of days
  private final color noon_colour_;
  private final color late_noon_colour_;
  private final color sunset_colour_;
  private final color dusk_colour_;
  private final color midnight_colour_;
  private final color dawn_colour_;
  private final color sunrise_colour_;

  // The current colour
  color sky_colour_;

  /******************************************************************************/
  /*!
      Default Constructor
  */
  /******************************************************************************/
  Sky()
  {
    sun_ = new Sun();
    moon_ = new Moon();
    
    // 0 time has elapsed since start of program
    time_elapsed_ = 0;
    // Change this value to set the time of day
    length_of_day_ = 100;

    // When program first starts out, time of day is 0.
    time_of_day_ = 0;

    // Percentages of the length of day the different times of days are
    noon_time_ = 0;
    late_noon_time_ = length_of_day_ * 0.1f;
    sunset_time_ = length_of_day_ * 0.2f;
    dusk_time_ = length_of_day_ * 0.3f;
    midnight_time_ = length_of_day_ * 0.5f;
    dawn_time_ = length_of_day_ * 0.7f;
    sunrise_time_ = length_of_day_ * 0.8f;

    // The colours of the days
    noon_colour_ = color(221, 245, 255);
    late_noon_colour_ = color(106, 187, 222);
    sunset_colour_ = color(196, 109, 23);
    dusk_colour_ = color(19, 26, 122);
    midnight_colour_ = color(0, 10, 30);
    dawn_colour_ = color(28, 52, 150);
    sunrise_colour_ = color(255, 206, 106);

    // Current colour is noon colour
    sky_colour_ = noon_colour_;
  }

  /******************************************************************************/
  /*!
      Updates the Sky and its components
  */
  /******************************************************************************/
  void Update()
  {
    Update_Timing();
    Update_Sky_Colour();

    sun_.Update(time_of_day_, length_of_day_, noon_time_, dusk_time_, dawn_time_);
    moon_.Update(time_of_day_, dusk_time_, dawn_time_);
  }

  /******************************************************************************/
  /*!
      Draws the Sky and its components
  */
  /******************************************************************************/
  void Draw()
  {
    background(sky_colour_);
    
    sun_.Draw();
    moon_.Draw();
  }

  /******************************************************************************/
  /*!
      Getter for the current sky colour
  */
  /******************************************************************************/
  color Get_Sky_Colour()
  {
    return sky_colour_;
  }

  /******************************************************************************/
  /*!
      Updates the time elapsed and time of day
  */
  /******************************************************************************/
  private void Update_Timing()
  {
    // Converts ms to seconds
    time_elapsed_ = millis() * 0.001f;

    time_of_day_ = time_elapsed_ % length_of_day_;
  }

  /******************************************************************************/
  /*!
      Changes the sky colour according to the time of day
  */
  /******************************************************************************/
  private void Update_Sky_Colour()
  { 
    float period_length = 0;        // How long the current period is in seconds
    float time_left_percentage = 0; // How much time is left in the current period in percentage

    float time_from = 0;            // The start time of the current period
    float time_to = 0;              // The end time of the current period

    color colour_from = 0;          // The colour of the start of the period
    color colour_to = 0;            // The colour of the end of the period

    // Period is Noon to Late Noon
    if (time_of_day_ >= noon_time_ && time_of_day_ <= late_noon_time_)
    {
      time_from = noon_time_;
      time_to = late_noon_time_;

      colour_from = noon_colour_;
      colour_to = late_noon_colour_;
    }

    // Period is Late Noon to Sunset
    else if (time_of_day_ >= late_noon_time_ && time_of_day_ <= sunset_time_)
    {
      time_from = late_noon_time_;
      time_to = sunset_time_;

      colour_from = late_noon_colour_;
      colour_to = sunset_colour_;
    }

    // Period is Sunset to Dusk
    else if (time_of_day_ >= sunset_time_ && time_of_day_ <= dusk_time_)
    {
      time_from = sunset_time_;
      time_to = dusk_time_;

      colour_from = sunset_colour_;
      colour_to = dusk_colour_;
    }

    // Period is Dusk to Midnight
    else if (time_of_day_ >= dusk_time_ && time_of_day_ <= midnight_time_)
    {
      time_from = dusk_time_;
      time_to = midnight_time_;

      colour_from = dusk_colour_;
      colour_to = midnight_colour_;
    }

    // Period is Midnight to Dawn
    else if (time_of_day_ >= midnight_time_ && time_of_day_ <= dawn_time_)
    {
      time_from = midnight_time_;
      time_to = dawn_time_;

      colour_from = midnight_colour_;
      colour_to = dawn_colour_;
    }

    // Period is Dawn to Sunrise
    else if (time_of_day_ >= dawn_time_&& time_of_day_ <= sunrise_time_)
    {
      time_from = dawn_time_;
      time_to = sunrise_time_;

      colour_from = dawn_colour_;
      colour_to = sunrise_colour_;
    }

    // Period is Sunrise to Noon
    else if (time_of_day_ >= sunrise_time_)
    {
      time_from = sunrise_time_;
      time_to = length_of_day_;

      colour_from = sunrise_colour_;
      colour_to = noon_colour_;
    }

    period_length = time_to - time_from;
    time_left_percentage = (time_of_day_ - time_from) / period_length;

    // Calculates the sky colour by converting the colour from to the colour to based on how much
    // time is left in percentage
    sky_colour_ = color(red(colour_from) + (red(colour_to) - red(colour_from)) * time_left_percentage,
      green(colour_from) + (green(colour_to) - green(colour_from)) * time_left_percentage,
      blue(colour_from) + (blue(colour_to) - blue(colour_from)) * time_left_percentage);
  }

  /******************************************************************************/
  /*!
      Returns if it is day or night time. Returns true if it is day, false if it
      is night
  */
  /******************************************************************************/
  boolean Get_Day_Or_Night_Time()
  {
    if (time_of_day_ >= dusk_time_ && time_of_day_ <= dawn_time_)
      return false;

    else return true;
  }
}
