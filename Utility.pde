/******************************************************************************/
/*!
\file   Utility.pde
\author Wong Zhihao
\par    email: wongzhihao.student.utwente.nl
\date
\brief
  This file contains helper functions that are used throughout the program.
*/
/******************************************************************************/

/******************************************************************************/
/*!
    Loops through every owl and returns the owl that is not an AI
*/
/******************************************************************************/
Owl Find_Player_Owl()
{
  for (int i = 0; i < num_owls; ++i)
    if (!owls_list[i].Get_AI())
      return owls_list[i];

  return owls_list[0];
}

/******************************************************************************/
/*!
  	Checks if an AI owl is in range with another object
*/
/******************************************************************************/
boolean Collision_Detection_In_Range(Owl owl_check, vec pos, float radius, int range)
{
  // The distance between this owl and the other object in x and y
  float displacement_x = owl_check.owl_pos_.x - pos.x;
  float displacement_y = owl_check.owl_pos_.y - pos.y;

  // The max distance between both objects possible to allow collision detection
  float collision_displacement = (radius * range) + (owl_check.owl_size_ * range);

  // Uses pythagorean theorem to check if the two objects are within range
  if ((collision_displacement * collision_displacement) >= (displacement_x * displacement_x) + (displacement_y * displacement_y))
    return true;

  else return false;
}
