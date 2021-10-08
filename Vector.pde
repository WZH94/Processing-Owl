/******************************************************************************/
/*!
\file   Vector.pde
\author Wong Zhihao
\par    email: wongzhihao.student.utwente.nl
\date
\brief
  This file contains the implementation of the Vector class, which stores 
  x and y coordinates as a 2d vector class.
*/
/******************************************************************************/

class vec
{
  float x;
  float y;
  
  /******************************************************************************/
  /*!
      Default constructor, sets vector to 0
  */
  /******************************************************************************/
  vec()
  {
    x = 0;
    y = 0;
  }
  
  /******************************************************************************/
  /*!
      Parametirsed constructor, sets the vector to arguments
  */
  /******************************************************************************/
  vec(float x, float y)
  {
    this.x = x;
    this.y = y;
  }
}
