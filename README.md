# TERRIFIC-MARIO-BROS.

Intent:
The intent of our project was to, as accurately as we could, recreate the first level  of the original Super Mario Bros.


High Level Description:

Our game had many functions that to the ordinary eye look simple, but indeed were  more than meets the eye. Here are a few high level descriptions of the main complex  parts of Super Mario Bros.

The jump function was governed by a tic and toc timer. While the jump key was  pressed, Mario’s upward velocity was set at a constant number. We intended for the  timer to restrict this to a small amount of time to provide a maximum jump height when  the jump key was held down, but allow for a quick key press to result in a small jump.  We also would check to see whether Mario was falling or not so that he could not jump in mid air. Before the code for it was lost, we had Mario’s image change to his jump  image whenever he was in the air after a jump and not when just falling, we also lost the  height­control functionality.

Running Animations: The running animation was also governed by a tic­toc timer. While  the direction keys were being pressed a timer was running. Depending on the value of  the timer, Mario’s image would change and would return to his standing image when he  came to a stop.  

The way we detected collisions was that we loaded an image of the map that  only had the floor and unbreakable objects like the pipes and the bricks. The rest of the  background was transparent using the program, GIMP. For ground detection, we  checked if the row below Mario of the transparent background file was all zeros. If they  were then that meant Mario was falling, which then used freefall physics to determine  Mario’s Y­position. Otherwise he would stay. We did this also for horizontal detection to  set the boundaries.  

The screen movement was governed by Mario’s position and the axis function.  We uploaded the whole, long map of the first world and zoomed into a different frame of  it based solely on Mario’s position.

Technical Challenges: We had major difficulties with frame rate and collision detection  with objects in the background. For example, Mario would get trapped in the floor, walls,  pipes, the ceiling, and many other places. We also had difficulties getting the jump  animation function to work as many times Mario would fall out of the world and glitch  out. We had it working as some point but due to technical difficulties that file was lost  and we couldn’t fully restore functionality. However one difficulty that was not actually  that hard was generating the graphics. Everything looked good, but the physics of the  game itself was very arduous.
	
Omitted Functionality: Jumping to a height dictated by how long the jump key was  pressed, enemies that could be killed, sliding down the pole animation, and power ups  were all omitted due to the amount of work they would take to program as well as the  difficulties of checking whether each enemy was touching Mario. For example if Mario  touched him from either side, Mario would die, but if Mario jumped on top of the enemy,  the enemy would die with an animation. Another thing that was omitted was the ability to  interact with the background besides just hitting the boundaries. Specifically we were  not able to make the bricks breakable or have coin and power up functionality due to the  time and work of programming the animations and all the cases for checking whether  we hit the block. Also the scoring system, coin count, and timer, and multiple levels  were omitted as the physics of this game proved to be very time consuming and difficult.  
