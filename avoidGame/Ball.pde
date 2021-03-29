class Ball{
  float x;
  float y;
  float vx;
  float vy;
  float size;
  
  public Ball(float size, float vBall){
    this.size = size;
    x = size;
    y = random(size/2, height - size/2);
    vx = random(1,vBall);
    vy = sqrt(vBall*vBall - vx*vx);
  }
  
  public int move(){
    if( y + size/2  + vy > height || y - size/2 + vy < 0){
      vy = -vy;
    }
    
    if(x - size/2 + vx < 0){
      vx = -vx;
      return 2;
    }
    
    if( x + size/2  + vx > width){
      vx = -vx;
      return 1;
    }
    
    x += vx;
    y += vy;
    return 0;
  }
  
  public void paint(){
     circle(x,y,size); 
  }
}
