import java.util.*;

class Particle {
    float x;
    float y;
    float r = 1;
    PVector position;
    PVector velocity;
    PVector acceleration;
    PVector previousPosition;
    float maxSpeed = 4;
    color pColor;
    int opacity = 225;
    LinkedList<PVector> previousPositions;
    PVector removedPosition;
    int trailLength;

    int start_red = 203;
    int start_green = 48;
    int start_blue = 102;

    int red = this.start_red;
    int green = this.start_green;
    int blue = this.start_blue;

    int end_red = 22;
    int end_green = 191;
    int end_blue = 253;

    int red_step = (end_red - start_red) / 50;
    int green_step = (end_green - start_green) / 50;
    int blue_step = (end_blue - start_blue) / 50;
    
    int connotation1 = -1;
    int connotation2 = 1;
    int connotation3 = 1;
  
    Particle(int trailLength, float x, float y) {
        if (x != -1 && y != -1) {
          this.x = x;
          this.y = y;
        } else {
          this.x = random(width);
          this.y = random(height);
        }
        
        this.position = new PVector(this.x, this.y);
        this.acceleration = new PVector(0,0);
        this.velocity = new PVector(0, 0);
        this.previousPosition = this.position.copy();
        this.trailLength = trailLength;
        this.previousPositions = new LinkedList<>();
        int colorOfSpeed = (int) (this.velocity.mag() * (255 / this.maxSpeed));
        this.pColor = color(this.red, this.green, this.blue);
    }

    void update(PVector[] flowField, int i) {
        // save the previous position
        this.updatePrevious();
        int colorOfSpeed = (int) (this.velocity.mag() * (255 / this.maxSpeed));
        // this.pColor = color(colorOfSpeed, 224 - colorOfSpeed, colorOfSpeed);
        
        // this.red = (int) this.red + (int) (this.velocity.x / 10);
        // this.green = (int) (this.green - this.x / 10);
        // this.blue = (int) (this.blue - this.y / 10); //<>//
        this.pColor = color(this.red, this.green, this.blue);  //<>//

        this.red = this.red + this.red_step * connotation1;
        this.green = this.green + this.green_step * connotation2;
        this.blue = this.blue + this.blue_step * connotation3;

        if (this.red > this.end_red || this.red < this.start_red) {
          connotation1 = connotation1 * -1;
        }

        if (this.green > this.end_green || this.green < this.start_green) {
          connotation2 = connotation2 * -1;
        }

        if (this.blue > this.end_blue || this.blue < this.start_blue) {
          connotation3 = connotation3 * -1;
        }
        // this.pColor = color(colorOfSpeed, 224 - this.y / 5, 208 - this.x);
        // float opacityPerling = noise((float)this.x, (float)this.velocity.mag());
        // this.opacity = this.opacity > 150 ? (this.opacity - (int (opacityPerling * 255) / 10)): 255;
        
         
        this.followTheFlow(flowField);
        this.velocity.add(this.acceleration);
        this.velocity.limit(this.maxSpeed);
        this.position.add(this.velocity);
        this.acceleration.mult(0);
        this.edges();
    }
    
    void followTheFlow(PVector[] flowField) {
        int x = (int) (this.position.x / scale);
        int y = (int) (this.position.y / scale);
        
        int index = (x + y * cols) % flowField.length;
         //<>//
        // apply the force(direction) of the nearest vector //<>//
        this.acceleration.add(flowField[index]);
    }

    void updatePrevious() {
        this.previousPosition = this.position.copy();
        if (this.previousPositions.size() < this.trailLength) {
          // if the particle trail hasn't reached the limit yet
          // we just add the new position to the end of the linked list
          this.previousPositions.add(this.previousPosition);
        } else {
          // the particle trail has reached the limit,
          // so we have to remove the oldest recorded position of the particle
          // while also adding the new position to the end of the linked list
          this.removedPosition = this.previousPositions.remove();
          this.previousPositions.add(this.previousPosition);   
        }
    }
    
    
    
    void removeTrail() {
        if (this.removedPosition != null) {
          PVector nextConnection = this.previousPositions.peek(); // Retrieves, but does not remove, the head (first element) of this list.
          
          if (nextConnection.y == 0 || nextConnection.x == 0 || nextConnection.y == height || nextConnection.x == width) {
            return;
          }
          stroke(0, 6);
          line(nextConnection.x, nextConnection.y, this.removedPosition.x, this.removedPosition.y);
        }
    
    }
    
    void show() {
        // fill(this.pColor, 50);
        stroke(this.pColor, this.opacity);
        strokeWeight(this.r);
        //ellipse(this.position.x, this.position.y, this.r, this.r);
        //size((int)this.r,(int)this.r);
        // point(this.position.x, this.position.y);
        line(this.position.x, this.position.y, this.previousPosition.x, this.previousPosition.y);
        
        if (this.previousPositions.size() >= this.trailLength) {
          // removeTrail();
        }
        
    }
    
    void edges() {
      if (this.position.x > width) {
        this.position.x = 0;
        this.updatePrevious();
      }
      
      if (this.position.x < 0) {
        this.position.x = width;
        this.updatePrevious();
      }
      
      if (this.position.y > height) {
        this.position.y = 0;
        this.updatePrevious();
      } 
      
      if (this.position.y < 0) {
        this.position.y = height;
        this.updatePrevious();
      }
    }
}
