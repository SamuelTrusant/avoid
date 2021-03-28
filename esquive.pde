import java.lang.*;
import processing.video.*;
import cvimage.*;
import org.opencv.core.*;
//Detectores
import org.opencv.objdetect.CascadeClassifier;
import org.opencv.objdetect.Objdetect;

Capture cam;
CVImage img;
MatOfRect faces;
ArrayList<Ball> balls = new ArrayList<Ball>();

int frames = 0;
int framesPerScore = 5;
int score = 0;
int bestScore = 0;
//Cascadas para detección
CascadeClassifier face,leye,reye;
//Nombres de modelos
String faceFile, leyeFile,reyeFile;

void setup() {
  size(640, 480);
  //Cámara
  cam = new Capture(this, width , height);
  cam.start(); 
  
  //OpenCV
  //Carga biblioteca core de OpenCV
  System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
  println(Core.VERSION);
  img = new CVImage(cam.width, cam.height);
  
  //Detectores
  faceFile = "haarcascade_frontalface_default.xml";
  leyeFile = "haarcascade_mcs_lefteye.xml";
  reyeFile = "haarcascade_mcs_righteye.xml";
  face = new CascadeClassifier(dataPath(faceFile));
  leye = new CascadeClassifier(dataPath(leyeFile));
  reye = new CascadeClassifier(dataPath(reyeFile));
}

void draw() {  
  if (cam.available()) {
    background(0);
    cam.read();
    
    //Obtiene la imagen de la cámara
    img.copy(cam, 0, 0, cam.width, cam.height, 
    0, 0, img.width, img.height);
    img.copyTo();
    
    //Imagen de grises
    Mat gris = img.getGrey();
    
    //Imagen de entrada
    image(img,0,0);
    
    //Detección y pintado de contenedores
    FaceDetect(gris);
    
    gris.release();
    
    Rect [] facesArr = faces.toArray();
    
    String scoreS = "score: " + score;
    fill(255);
    textSize(24);
    text(scoreS,width,height);
    noStroke();
    fill(255);
    for (Ball ball : balls){
      ball.move();
      ball.paint();
    }
    if(checkBalls()){
      print("pierdes");
      //balls = new ArrayList<Ball>();
    }
  }
  
  frames++;
  if(frames % 5 == 0) score++;
  if(frames % 200 == 1) balls.add(new Ball(50,5));
}

void FaceDetect(Mat grey)
{
  Mat auxroi;
  
  //Detección de rostros
  faces = new MatOfRect();
  face.detectMultiScale(grey, faces, 1.15, 3, 
    Objdetect.CASCADE_SCALE_IMAGE, 
    new Size(60, 60), new Size(200, 200));
  Rect [] facesArr = faces.toArray();
  
   //Dibuja contenedores
  noFill();
  stroke(255,0,0);
  strokeWeight(4);
  for (Rect r : facesArr) {    
    rect(r.x, r.y, r.width, r.height);   
   }
  
  //Búsqueda de ojos
  MatOfRect leyes,reyes;
  for (Rect r : facesArr) {    
    //Izquierdo (en la imagen)
    leyes = new MatOfRect();
    Rect roi=new Rect(r.x,r.y,(int)(r.width*0.7),(int)(r.height*0.6));
    auxroi= new Mat(grey, roi);
    
    //Detecta
    leye.detectMultiScale(auxroi, leyes, 1.15, 3, 
    Objdetect.CASCADE_SCALE_IMAGE, 
    new Size(30, 30), new Size(200, 200));
    Rect [] leyesArr = leyes.toArray();
    
    //Dibuja
    stroke(0,255,0);
    for (Rect rl : leyesArr) {    
      rect(rl.x+r.x, rl.y+r.y, rl.height, rl.width);   //Strange dimenions change
    }
    leyes.release();
    auxroi.release(); 
     
     
    //Derecho (en la imagen)
    reyes = new MatOfRect();
    roi=new Rect(r.x+(int)(r.width*0.3),r.y,(int)(r.width*0.7),(int)(r.height*0.6));
    auxroi= new Mat(grey, roi);
    
    //Detecta
    reye.detectMultiScale(auxroi, reyes, 1.15, 3, 
    Objdetect.CASCADE_SCALE_IMAGE, 
    new Size(30, 30), new Size(200, 200));
    Rect [] reyesArr = reyes.toArray();
    
    //Dibuja
    stroke(0,0,255);
    for (Rect rl : reyesArr) {    
      rect(rl.x+r.x+(int)(r.width*0.3), rl.y+r.y, rl.height, rl.width);   //Strange dimenions change
    }
    reyes.release();
    auxroi.release(); 
  }
  
  faces.release();
}

boolean checkBalls(){
    Rect [] facesArr = faces.toArray();
    print("sdljfldk  ");
    for (Ball ball : balls){
      for(Rect r : facesArr){
        if(ball.x >= r.x - r.width/2 && ball.x <= r.x + r.width/2){
          if(ball.y >= r.y - r.height/2 && ball.y <= r.y + r.height/2) return true;
        }
      }
    }
    
    return false;
}
