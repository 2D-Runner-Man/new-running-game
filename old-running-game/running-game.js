$( document ).ready(function() {
var context, controller, loop;

var context = document.querySelector("canvas").getContext("2d");
var rectangle = document.getElementById("person");
var obstacle = document.getElementById("obstacle");
  
 

context.canvas.height = 500;
context.canvas.width = 900;
/*context.canvas.interval = setInterval(updateCanvas, 20);
function clear () { 
  context.clearRect(0, 0, context.canvas.width,  context.canvas.height);
}
function update () {
  context.canvas
  context.fillStyle = color;
        context.fillRect(this.x, this.y, this.width, this.height);
    }
function updateCanvas() {
    if (rectangle.crashWith(obstacle)) {
    rectangle.newPos();
    rectangle.clear();
    rectangle.update();
}
*/

rectangle = {
  marginTop: 100,
  height: 50 ,
  jumping: true ,
  width: 50 ,
  x: 200, // center of the canvas
  x_velocity: 0,
  y: 0,
  y_velocity: 0
    
};

obstacle = {
  marginTop: 100,
   x: 450,
   y: 316,
   width: 75,
   height: 75,
};

controller = {

  left:false,
  right:false,
  up:false,
  keyListener:function(event) {

    var key_state = (event.type == "keydown")?true:false;

    switch(event.keyCode) {

      case 37:// left key
        controller.left = key_state;
      break;
      case 38:// up key
        controller.up = key_state;
      break;
      case 39:// right key
        controller.right = key_state;
      break;

    }
 }
};
 
loop = function() {

  if (controller.up && rectangle.jumping == false) {

    rectangle.y_velocity -= 20;
    rectangle.jumping = true;

  }

  if (controller.left) {

    rectangle.x_velocity -= 0.5;

  }

  if (controller.right) {

    rectangle.x_velocity += 0.5;

  }
  rectangle.x += rectangle.x_velocity;
  rectangle.y += rectangle.y_velocity;
  rectangle.y_velocity += 0.8;// gravity
  rectangle.x_velocity *= 0.95;// friction
  rectangle.y_velocity *= 0.95;// friction
  
  var reset = function () {
  // Reset player's position to centre of canvas
  rectangle.x = 200,
  rectangle.y = 0
  }
  

  /* rectangle.newPos = function() {
    
  }*/

  // if rectangle is falling below floor line
  if (rectangle.y > 390 - 50 - 0) {

    rectangle.jumping = false;
    rectangle.y = 390 - 50 - 0;
    rectangle.y_velocity = 0;

  }

  // if rectangle is going off the left of the screen
  if (rectangle.x < -32) {

    rectangle.x = 855;

  } else if (rectangle.x > 855) {// if rectangle goes past right boundary

    rectangle.x = -32;

  }
   var background = new Image();
  background.src = "background.png"
  // show the background image
  background.onload = function(){
    context.drawImage(background,0,0);   
}
  context.fillStyle = "#202020";
  context.fillRect(0, 0, 900, 500);// x, y, width, height
  context.fillStyle = "#ff0000";// hex for red
  context.beginPath();
  context.rect(rectangle.x, rectangle.y, rectangle.width, rectangle.height);
  context.fill();
  context.strokeStyle = "#202830";
  context.lineWidth = 10;
  context.beginPath();
  context.moveTo(100, 395); // line length
  context.lineTo(810, 395); // line length
  context.stroke();
  
 //Obstacle
  context.fillStyle = 'green';
  context.beginPath();
  context.rect(obstacle.x, obstacle.y, obstacle.width, obstacle.height);
  context.fill();
  
  if (
    rectangle.x <= (obstacle.x + 32)
    && obstacle.x <= (rectangle.x + 32)
    && rectangle.y <= (obstacle.y + 32)
    && obstacle.y <= (rectangle.y + 32)
  ) {
    reset();
  }

  
 
  // call update when the browser is ready to draw again
  window.requestAnimationFrame(loop);

};

window.addEventListener("keydown", controller.keyListener);
window.addEventListener("keyup", controller.keyListener);
window.requestAnimationFrame(loop);
});
