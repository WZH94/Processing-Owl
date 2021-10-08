/******************************************************************************/
/*!
\file   Cursor.pde
\author Wong Zhihao
\par    email: wongzhihao.student.utwente.nl
\date
\brief
  This file contains the implementation of the Cursor, which just tracks the
  coordinates of the mouse cursor and stores it as a vector
*/
/******************************************************************************/

class Cursor
{
  vec cursor_pos; // The vector that stores the cursor position
  
  /******************************************************************************/
  /*!
      Constructor
  */
  /******************************************************************************/
  Cursor ()
  {
    // Cannot be initialised to 0
    cursor_pos = new vec (1, 1);
  }
  
  /******************************************************************************/
  /*!
      Updates the cursor class position based on mouse cursor position
  */
  /******************************************************************************/
  void Update_Cursor_Position(float x, float y)
  {
    cursor_pos.x = x;
    cursor_pos.y = y;
  }

  /******************************************************************************/
  /*!
      Checks if the cursor is over any owl and sets that owl to an AI
  */
  /******************************************************************************/
  void Choose_Owl()
  {
    // Loops through every owl
    for (int i = 0; i < num_owls; ++i)
    {
      if (Collision_Detection_In_Range(owls_list[i], cursor_pos, 1, 1))
      {
        // Set the player controlled owl to AI first
        Find_Player_Owl().Set_AI();
        owls_list[i].Set_AI();
      }
    }
  }
}
