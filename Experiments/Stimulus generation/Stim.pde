class Stim{
  float v;
  float a;
  float lv;
  float dt;
  
  Stim(float v, float a, float dt){
    this.v = v;
    this.a = a;
    this.dt = dt;
  }
  
  String toString(){
    return "V: " + this.v + " | " + "A: " + this.a + " | " + "DT: " + this.dt;
  }

}
