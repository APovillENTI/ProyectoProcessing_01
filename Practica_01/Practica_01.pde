// VARIABLES CONSTANTES

// Tiempo que duran los efectos de los items
static final int SPEED_TIME = 5000; 
static final int FREEZE_TIME = 3000; 
static final int INMORTAL_TIME = 5000;
static final int VENOM_TIME = 10000;
static final int INOFENSIVE_TIME = 5000;

// Poder de los efectos de los items
static final float VENOM_DAMAGE = 0.05;
static final float CURE_ITEM = 50;
static final float DAMAGE_ITEM = 1;

// Cuantos powerUp necesitaremos recoger para pasar a la siguiente sala
static final int POWER_UPS_REQUIRED = 3;

// Iniciales del PJ
static final float PJ_VELOCIDAD = 3; 
static final float PJ_SIZE = 20;

// Vida inicial del PNJ2
static final float HP = 100;

// MAX MIN enemigos
static final int MIN_ENEMIES = 5;
static final int MAX_ENEMIES = 20;

// MINUS PLUS BUTTONS SIZE
static final int MP_SIZE = 40;

//Colores
color morado = color(150, 0, 180); // Para el veneno
color rojo = color(200, 0, 0); // Para los enemigos
color rojo_claro = color (255, 50, 50); // Para el boton quit 
color cian = color(165, 244, 255); // Para los enemigos congelados (Frozen)
color verde = color(0, 205, 0); // Para los items
color verde_claro = color(50, 255, 50); // Para el boton restart
color amarillo = color(250, 250, 0); // Para el efecto de velociad
color naranja = color(250, 150, 0); // Para el PNJ1
color azul = color(0, 0, 250); // Para el PNJ2
color blanco = color(255, 255, 255); // Para la inmortalidad
color turquesa = color(0, 250, 160); // Para el PJ
color rosa = color(255, 160, 200); // Para el efecto inofensivo

//Variables de muros
PVector[] muros; // Contiene todos los muros
float ancho_muro, alto_muro; 
float WallDamage = 0.5; // Daño que inflingen los muros al colisionar con el PNJ2
int muros_num; // Numero max de muros

//Variables de Jugador
float pj_vel; 
float pj_size;
PVector pj_pos;
color pj_color;

float alfa = 0.1;

boolean using_mouse = false; // Para cambiar de modo WASD a modo Mouse (falta por ajustar)

//Enum del Item
public enum Item_type {VEL, FREEZE, INMORTAL, CURE, DAMAGE, VENOM, INOFENSIVE, NULO};
int type_num = 7; // Es el numero total de efectos de los items(sin contar el NULO) para randomizarlos
//Enum del Enemy
public enum Enemy_type {SHY, STALKER, PREDATOR}; // SHY: Se acerca al PNJ2 pero huye del PJ
                                                 // STALKER: Se acerca al PNJ1
                                                 // PREDATOR: Ataca al PNJ2
                                               
public enum Scene {MENU, LEVEL1, BOSS, DEATH, VICTORY}; // En qué escena nos encontramos                        
Scene actualScene;

public class Button {
  
  PVector pos;
  float ancho, alto;
  Scene sceneToGo;
  color c_base;
  color c_over;
  
  Button()
  {
    pos = new PVector(0,0);
    sceneToGo = Scene.MENU;
  }
  
  boolean IsOver()
  {
    if (mouseX < pos.x - ancho / 2 || mouseY < pos.y - alto / 2 || mouseX > pos.x + ancho / 2 || mouseY > pos.y + alto / 2) 
    {
      return false;
    }
    else
    {
      return true;
    }
  }
}

public class Item {
  boolean powerUp; // Decide si el item es un powerUp o powerDown (Se tiene que usar para la logica de recoger los powerUps para pasar a la siguiente sala
  boolean isTaken; // Indica si el item ha sido recogido o no (sirve para saber si hay que dibujarlo o no)
  Item_type type; // Qué tipo de efecto inflinge el item
  PVector pos;
  Timer effectTimer; // Timer que se activa cuando se recoge un item cuyo efecto dura un tiempo
  float effectTime; // Tiempo que va a durar el efecto
  
  Item() // Constructor de la clase Item (se ejecuta cada vez que se crea un nuevo item)
  {
    effectTimer = new Timer(); 
    isTaken = false;
    pos = new PVector(0,0);
  }
   
  Item_type Type(int num) // Este método sirve para asignarle un efecto aleatorio al item (haciendo que num sea un numero aleatorio)
  {
    switch(num)
    {
      case 0:
        return Item_type.VEL;
      case 1:
        return Item_type.FREEZE;
      case 2: 
        return Item_type.INMORTAL;
      case 3: 
        return Item_type.CURE; // (si num <= 3, siempre será powerUp)
      case 4: 
        return Item_type.DAMAGE; 
      case 5:
        return Item_type.VENOM;
      case 6:
        return Item_type.INOFENSIVE;
      default:
        return Item_type.NULO;
    }
  }
}

public class Pnj {
  boolean isWaiting; // Cuando spawnea, el PNJ2 permanece inmovil, este booleano activa o desactiva este estado 
                     // Ya que el PNJ1 no espera, lo vamos a utilizar para saber cuando el PNJ va a tener que huir de un enemigo o no
    float vel;
    float size;
    float dist; // distancia respecto al PJ que tendrá el PNJ
    float hp; 
    PVector pos;
    color tint; // Color del PNJ
    
   Pnj() //Constructor de la clase PNJ
   {
     isWaiting = true;
     pos = new PVector(0, 0); // la posición es aleatoria
   }
}

public class Enemy {
  PVector pos;
  boolean isDead;
  boolean isAwake;
  float vel; 
  float size;
  float detectionDistance; // Distancia a la que el enemigo empezará a huir el PJ
  float speedIncrement; // Esta variable se utiliza para variar la velocidad del enemy constantemente
  Enemy_type type; // Comportamiento que tendrá el enemy
  Timer speedTimer; // Este timer sirve para la variación de la velocidad del enemy
  
  Enemy() {
    speedIncrement = 0.1;
    speedTimer = new Timer();
    pos = new PVector(0,0);
    type = Enemy_type.SHY;
    size = 10;
    isDead = false;
    isAwake = false;
    detectionDistance = 50;
  }
}

public class Timer { // Timer para controlar el tiempo
  boolean isStarted; // indica si ha empezado a contar
  float finalTime; // tiempo al que se tiene que detener
  
  void StartTimer(float time) // método que inicia el tiempo (recibe el tiempo que debe pasar en milis)
  {
    if (!isStarted) // Comprueva que el timer no se haya iniciado ya
    {
       finalTime = millis() + time; // El tiempo final es el tiempo transcurrido desde que se ha iniciado el programa + el tiempo que se desea esperar
       isStarted = true;
    }  
  }
  boolean CheckTimer() // Comprueva si el timer ha terminado
  {
    if (millis() >= finalTime)
    {
      isStarted = false;
      return true; // Ha terminado
    }
    else
    {
      return false; // No ha terminado
    }
  }
  
  Timer()
  {
    isStarted = false;
  }
}

// Inicializamos los PNJ
Pnj pnj1 = new Pnj(); 
Pnj pnj2 = new Pnj();

// Variables de Item
Item[] items; // Contiene todos los items
int items_num;
int powerUpsTaken;

// Variables que indican el estado actual del player
boolean poisoned = false;
boolean frozen = false;
boolean inmortal = false;
boolean inofensive = false;

float items_size = 10; 
float speedUp = 1; // la velocidad del PJ se multiplica por este valor, el cual cambia si se obtiene un item de velocidad
color item_color = verde;

// Variables de Enemy
Enemy[] enemies; // Contiene todos los enemigos
int N = MIN_ENEMIES; // Total de enemigos
int enemy_counter = 0; // Cuenta los enemigos spawneados

float enemySpawnTime = 5000; // Tiempo que tardan los enemigos en spawnear
float enemySpeedTime = 2500; // Tiempo que tarda en variar la velocidad del enemy
//Velocidad Max y min del enemy (variará dentro de este rango)
float enemyMaxVel = 0.3;
float enemyMinVel = 0.05;
float enemyDamage = 0.5; // Daño que ejerce el enemigo al colisionar

float pjEnemyOffset; // Es la distancia que debe de haber para que el player colisione con el enemigo y lo mate
float pnj2EnemyOffset; // La distancia entre el PNJ2 y el enemigo
float pjItemOffset;

color enemy_color = rojo;
Timer enemyTimer; // Se utiliza para paulatinar el spawn de enemigos

// Manager numero de enemigos
PVector label_pos;
float ancho_label = 100;

// Variables de los botones
Button playButton;
Button mQuitButton;
Button restartButton;
Button quitButton;
Button N_plus;
Button N_minus;

// Guardamos la mitad de la pantalla w = witdh, h = height
float w_half; 
float h_half;

//  SETUP

void setup() {
  // Creamos la ventana
  actualScene = Scene.MENU;
  size(600, 600);
  w_half = width / 2;
  h_half = height / 2;
  
  InitializeScene();
}

//  DRAW

void draw()
{
  background(255);
  
  switch (actualScene) //<>//
  {
    case MENU:
      MainMenu();
      break;
    case LEVEL1:
    
         //Movimiento del PJ (WASD)
      if (keyPressed) {
        if ((key == 'w' || key == 'W')) { // && Borders(0, pj_pos, pj_vel) && !WallBorder(0, pj_pos)) {
          pj_pos.y -= pj_vel * speedUp; // SpeedUp es 1 normalmente, cuando se recoge un item de velocidad se duplica
        }
        else if ((key == 'd' || key == 'D')) { // && Borders(3, pj_pos, pj_vel) && !WallBorder(3, pj_pos)) {
          pj_pos.x += pj_vel * speedUp;
        }
        else if ((key == 'a' || key == 'A')) { // && Borders(2, pj_pos, pj_vel) && !WallBorder(2, pj_pos)) {
          pj_pos.x -= pj_vel * speedUp;
        }
        else if ((key == 's' || key == 'S')) { // && Borders(1, pj_pos, pj_vel) && !WallBorder(1, pj_pos)) {
          pj_pos.y += pj_vel * speedUp;
        }
      }
      if (using_mouse)
      {
        pj_pos.y = mouseY;
        pj_pos.x = mouseX;
      }
      
      PNJLogic(); 
          if (enemy_counter < N)
      {
        EnemySpawn(); //Cuando hayan spawneado todos los enemigos => enemy_counter = N(dejaran de spawnear más)
      }
      
      if (WallColision(pnj2.pos, pnj2.size) && !inmortal)
      {
          GetDamage(pnj2, WallDamage); // Si el PNJ2 colisiona con un muro, recibe daño
      }
      
      for (int i = 0; i < items_num; i++)
      {
        if (!items[i].isTaken && DistanceBetween(items[i].pos, pj_pos) < pjItemOffset) // Detectamos si el player colisiona con un item que no haya sido recogido aún
        {
          items[i].effectTimer.StartTimer(items[i].effectTime); // Se activa el Timer del efecto
          items[i].isTaken = true; // Marcamos como recogido
          GetItem(items[i]); // Logica de recoger el Item
          if (items[i].powerUp)
          {
            powerUpsTaken ++;
            if (powerUpsTaken >= POWER_UPS_REQUIRED)
            {
                actualScene = Scene.VICTORY;
                InitializeScene();
            }
          }
        }
      }
      
      ItemCheck(); // Chequeamos si los efectos de los items siguen haciendo efecto
      
      if (poisoned)
      {
        pnj2.hp -= VENOM_DAMAGE; // El item de veneno daña al PNJ2
      }
      
      DrawInstances(); // Dibujamos las instancias
      DrawHUD(); // Dibujamos el HUD
      
      break;
    case BOSS:
      break;
    case DEATH:
      DeathScene();
      break;
    case VICTORY:
      VictoryScene();
      break;
    default:
  }
}

// EVENTS

void keyPressed()
{
   if (key == 'g' || key == 'G') // Si se pulsa G, el modo de movimiento varia entre Mouse y WASD
    {
        using_mouse = !using_mouse;
    }
}

//  FLOAT FUNCTIONS

float DistanceBetween(PVector point1, PVector point2) // Devuelve la distancia entre dos puntos
{
  return sqrt(pow(point2.x - point1.x, 2.0) + pow(point2.y - point1.y, 2.0)); // Se hace el modulo del vector del punto 1 al punto 2
}

float MoveTowards(float thisPoint, float finalPoint, float speed) // da la dirección del thisPoint para ir hasta finalPoint
{
  float move = (1.0 - speed * alfa) * thisPoint + speed * alfa * finalPoint;
  return move;
}

float MoveAway(float thisPoint, float finalPoint, float speed) // da la dirección del thisPoint para alejar-se de finalPoint
{
  float move = (1.0 + speed * alfa) * thisPoint - speed * alfa * finalPoint;
  return move;
}

void mouseClicked()
{
  switch(actualScene)
  {
    case MENU:
      if (N_plus.IsOver() && N < MAX_ENEMIES)
      {
        N++;
      }
      if (N_minus.IsOver() && N > MIN_ENEMIES)
      {
        N--;
      }
      if (playButton.IsOver())
      {
        actualScene = playButton.sceneToGo;
        InitializeScene();
      }
      if (mQuitButton.IsOver())
      {
        exit();
      }
      break;
    case DEATH:
      if (restartButton.IsOver())
      {
        actualScene = restartButton.sceneToGo;
        InitializeScene();
      }
      if (quitButton.IsOver())
      {
        actualScene = quitButton.sceneToGo;
        InitializeScene();
      }
      break;
    case VICTORY:
        if (restartButton.IsOver())
      {
        actualScene = restartButton.sceneToGo;
        InitializeScene();
      }
      if (quitButton.IsOver())
      {
        actualScene = quitButton.sceneToGo;
        InitializeScene();
      }
      break;
    default:
  }
}

//  BOOLEAN FUNCTIONS

Boolean FreeSpot(PVector pos, int index) // Devuelve true si encuentra un sitio libre para instanciar un item
{
  if (WallColision(pos, items_size)) // Mira si está colisionando con un muro
  {
    return false;
  }
  for(int i = 0; i < index; i++)
  {
    if (DistanceBetween(pos, items[i].pos) < items_size) // Mira si está colisionando con un item
    {
      return false;
    }
  }
  return true;
}


boolean Borders(int dir, PVector p, float speed) // Las colisiones con los bordes de la pantalla
{
  switch(dir) 
  {  
    case(0): //Arriba
      if (p.y - speed < 0) // si la posicion p.y menos la velocidad és menor que 0 (colisiona con el borde superior)
      {
        return false;
      }
      else
      {
        return true;
      }
    case(1): //Abajo
      if (p.y + speed > height)
      {
        return false;
      }
      else
      {
        return true;
      }
    case(2): //Izquierda
      if (p.x - speed < 0)
      {
        return false;
      }
      else
      {
        return true;
      }
    case(3): //Derecha
      if (p.x + speed > width)
      {
        return false;
      }
      else
      {
        return true;
      }
     default:
     return false;
  }
}

Boolean WallBorder(int dir, PVector p) // Indica si se está colisionando con un muro (no funciona)
{
  PVector pos = new PVector(p.x,p.y);
    switch(dir)
  {  
    case(0):
      pos.y -= pj_size * 2;
      return WallColision(p, pj_size);
    case(1):
      pos.y += pj_size * 2;
      return WallColision(p, pj_size);
    case(2):
      pos.x -= pj_size * 2;
      return WallColision(p, pj_size);
    case(3):
      pos.x += pj_size * 2;
      return WallColision(p, pj_size);
     default:
     return false;
  }
}

Boolean WallColision(PVector p, float size) // Colision entre un PVector p y su size con algún muro
{
  //Buscamos los puntos maximos y minimos de p
    float p_max_x = p.x + size / 2; 
    float p_max_y = p.y + size / 2;
    float p_min_x = p.x - size / 2;
    float p_min_y = p.y - size / 2;
      
    for(int i = 0; i < muros_num; i++) //Repasamos el array de muros
    {
      PVector max_muro = new PVector(0,0); 

  //Buscamos las máximas del muro i
      max_muro.x = muros[i].x + ancho_muro; 
      max_muro.y = muros[i].y + alto_muro;

      if (p_max_x <= max_muro.x - ancho_muro || p_max_y <= max_muro.y - alto_muro || max_muro.x <= p_min_x || max_muro.y <= p_min_y) //Buscamos si NO colisiona
      {
        continue;
      }
      else
      {
        return true;
      }
    }
    return false;
 }

Boolean WallColision(PVector p, int index) // Colision entre dos muros (para inicializarlos sin que está uno encima del otro)
{
  //p ya es el punto minimo, así que el punto max se le suma a p el tamaño
  float p_max_x = p.x + ancho_muro;
  float p_max_y = p.y + alto_muro;
  float p_min_x = p.x;
  float p_min_y = p.y;
      
  for(int i = 0; i < index; i++)
  {
    PVector max_muro = new PVector(0,0);

    max_muro.x = muros[i].x + ancho_muro;
    max_muro.y = muros[i].y + alto_muro;
     
    if (p_max_x <= max_muro.x - ancho_muro || p_max_y <= max_muro.y - alto_muro || max_muro.x <= p_min_x || max_muro.y <= p_min_y) 
    {
      continue;
    }
    else
    {
      return true;
    }
  }
  return false;
}

// FUNCTIONS

//Initializing functions:
void InitializeScene() //<>//
{
  switch(actualScene)
  {
    case MENU:
      InitializeButtons();
      break;
    case LEVEL1:
      InitializePJ();
      InitializeWalls();
      InitializePNJs();
      InitializeItems();
      InitializeEnemies();   
      break;
    case BOSS:
      break;
    case DEATH:
      InitializeButtons();
      break;
    case VICTORY:
      InitializeButtons();
      break;
    default:
  }
}

void InitializePJ()
{
  pj_vel = PJ_VELOCIDAD; 
  pj_size = PJ_SIZE;
  pj_color = turquesa;
  poisoned = false;
  frozen = false;
  inmortal = false;
  inofensive = false;
  speedUp = 1; 
  pj_pos = new PVector(w_half, h_half);
}

void InitializePNJs() //<>//
{
  pnj1.vel = 0.1;
  pnj1.size = 20.0;
  pnj1.dist = 25.0;
  pnj1.tint = naranja;
  pnj2.vel = 0.15;
  pnj2.size = 15.0;
  pnj2.dist = 75.0;
  pnj2.hp = HP;
  pnj2.isWaiting = true;
  pnj2.tint = azul;
  pnj1.pos = new PVector(random(pnj1.size, width - pnj1.size), random (pnj1.size, height - pnj1.size));
  do
  {
    pnj2.pos = new PVector(random(pnj2.size, width - pnj2.size), random (pnj2.size, height - pnj2.size));
  } while (WallColision(pnj2.pos, pnj2.size + 1));
}

void InitializeWalls() //<>//
{
  // El número de muros es un número aleatorio entre 6 y 20
  muros_num = (int)random(6, 20);
  
  // Inicializamos el array y la mida de los muros, también es aleatoria.
  muros = new PVector[muros_num];
  ancho_muro = width / random(5, 20);
  alto_muro = height / random(20, 50);
  
  // Inicializamos la posición de los muros
  for (int i=0; i < muros_num; i++) {
    muros[i] = new PVector(0, 0); // Reservamos cuantas coords por elemento
    do {  
    muros[i].x = random(0, width - ancho_muro); // Coord X punto inferior izquierdo
    muros[i].y = random(0, height - alto_muro); // Coord Y punto inferior izquierdo
    } while (WallColision(muros[i], i) && (muros[i].x > width/2 + ancho_muro || muros[i].x < width/2 - ancho_muro) && (muros[i].y < height/2 - alto_muro || muros[i].y > height/ 2 + alto_muro));
    // Miramos que en la posicion en la que queremos crear el muro no hay ningun muro y que no esté en el centro, que es donde aparece el pj
  }
}

void InitializeItems() //<>//
{
  //El número de ítems es un número aleatorio
  items_num = (int)random(POWER_UPS_REQUIRED + 3, 12);
  
  //Inicializamos el array de ítems
  items = new Item[items_num];
  pjItemOffset = (items_size + pj_size) / 2;
  powerUpsTaken = 0;
  
  for(int i = 0; i < items_num; i++)
  {
    items[i] = new Item();
    do 
    {
      items[i].pos.x = random(0, width - items_size);
      items[i].pos.y = random(0, height - items_size);
    } while (!FreeSpot(items[i].pos, i)); // Miramos que no haya un muro u otro item en el lugar en el que queremos poner el siguiente
    if (i < POWER_UPS_REQUIRED) // los tres primeros items del array seran powerUps
    {
      items[i].powerUp = true;
      items[i].type = items[i].Type((int)random(0, 3)); // Elige un efecto aleatorio
    }
    else // Los demas seran powerDowns
    {
      items[i].powerUp = false;
      items[i].type = items[i].Type((int)random(3, type_num)); 
    }
    switch (items[i].type) // Seteamos el tiempo que durará el efecto según el tipo de item
    {
      case VEL:
        items[i].effectTime = SPEED_TIME;
        break;
      case FREEZE:
        items[i].effectTime = FREEZE_TIME;
        break;
      case INMORTAL:
        items[i].effectTime = INMORTAL_TIME;
        break;
      case VENOM:
        items[i].effectTime = VENOM_TIME;
        break;  
      case INOFENSIVE:
        items[i].effectTime = INOFENSIVE_TIME;
        break;
      default:
        items[i].effectTime = 0;
    }
    //VEL, FREEZE, INMORTAL, CURE, DAMAGE, VENOM
    println(items[i].type); // Esto hay que quitar-lo de caras al definitivo
  }
}

void InitializeEnemies() //<>//
{
  // Inicializamos el array
  enemies = new Enemy[N];
  enemyTimer = new Timer();
  
  // Seteamos los tipos de los enemies
  for (int i = 0; i < N; i++)
  {
    enemies[i] = new Enemy();
    if (i < N / 4) // Un 25% irá a por el pnj2
    {
      enemies[i].type = Enemy_type.PREDATOR; 
    }
    else if (i < N / 2) // Otro 25% irá a por el pnj1
    {
      enemies[i].type = Enemy_type.STALKER;
    }
    else
    {
      enemies[i].type = Enemy_type.SHY; // El resto irá a por el pnj2 però huirá del pj
    }
    enemies[i].vel = enemyMinVel;
  }
  pjEnemyOffset = pj_size / 2 + enemies[0].size;
  pnj2EnemyOffset = pnj2.size / 2 + enemies[0].size;
  enemy_counter = 0;
}

// Draw functions:

void DrawHUD() // Dibujar el HUD
{
  fill(rojo);
  rect(10, 40, 200, 20);
  fill(verde);
  if (pnj2.hp > 0)
  {
    float anchoBarra = max(map(pnj2.hp, 0, 100, 0, 200), 0); // Evitar valores negativos.
    rect(10, 40, anchoBarra, 20);
  }
}

void DrawInstances() // Dibujamos las instancias
{
   //DIBUJAR AL PJ:
   if (WallColision(pj_pos, pj_size)) //Cambiamos de color cuando colisione con un muro (más que nada es para ver si funcionan las colisiones)
   {
    fill(0,0,0);
   }
   else
   {
    fill(pj_color);   
   }
    ellipse(pj_pos.x, pj_pos.y, pj_size, pj_size);
    
    //DIBUJAR AL PNJ1 Y PNJ2:
    
    fill(pnj1.tint);
    ellipse(pnj1.pos.x, pnj1.pos.y, pnj1.size, pnj1.size);

    fill(pnj2.tint);
    ellipse(pnj2.pos.x, pnj2.pos.y, pnj2.size, pnj2.size);
    
    //DIBUJAR MUROS:
    
     rectMode(CENTER);
     for(int i = 0; i < muros_num; i++)
     {
        fill(0,0,0);
        rect(muros[i].x + ancho_muro/2.0, muros[i].y + alto_muro/2.0, ancho_muro, alto_muro);
     }
     
     //DIBUJAR ÍTEMS:
     
     for(int i = 0; i < items_num; i++)
     {
       if (!items[i].isTaken)
       {
        fill(item_color);
        ellipse(items[i].pos.x, items[i].pos.y, items_size, items_size);
       }
     }     
}    

void DrawEnemies(PVector enemy, float size)
{
  fill(enemy_color);
  ellipse(enemy.x, enemy.y, size, size);
}

// Enemy Manager:

void EnemySpawn()
{
  enemyTimer.StartTimer(enemySpawnTime); // Inicia el timer

  if (enemyTimer.CheckTimer() && !frozen) // Chequea si el timer ha terminado (devuelve true/false)
  {
    GenerateEnemy(); // Genera enemigo
  }
}

void GenerateEnemy() {
  int enemyId;
  do 
  {
    enemyId = (int)random(0, N); // Generamos un index del array aleatorio, para que se cree un enemigo aleatorio de todo el array de enemigos
  } while(enemies[enemyId].isAwake || enemies[enemyId].isDead); // Nos aseguramos que el enemigo no esté ya spawneado y que tampoco esté muerto
  
  int spawn = int(random(4)); // Aparece en uno de los cuatro lados de manera aleatoria.
  switch (spawn) {
    case 0: // Arriba
      enemies[enemy_counter].pos.x = random(width);
      enemies[enemy_counter].pos.y = enemies[enemy_counter].size;
      break;
    case 1: // Abajo
      enemies[enemy_counter].pos.x = random(width);
      enemies[enemy_counter].pos.y = height - enemies[enemy_counter].size;
      break;
    case 2: // Izquierda
      enemies[enemy_counter].pos.x = enemies[enemy_counter].size;
      enemies[enemy_counter].pos.y = random(height);
      break;
    case 3: // Derecha
      enemies[enemy_counter].pos.x = width - enemies[enemy_counter].size;
      enemies[enemy_counter].pos.y = random(height);
      break;
     default:
  }  
  enemies[enemyId].isAwake = true; 
  enemy_counter++; // Contador suma para que cuando llegue a N no spawneen más enemigos
  if (enemy_counter < N)
  {
    enemyTimer.StartTimer(enemySpawnTime); // Iniciamos el timer del siguiente Spawn
  }
}

// Items logic

void GetItem(Item item)
{
  item.isTaken = true;
  switch(item.type)
  {
    case VEL: 
      speedUp = 2; // Este numero multiplica la velocidad general del pj
      pj_color = amarillo;
      break;
    case FREEZE:
      enemy_color = cian;
      for (int i = 0; i < N; i++) // Detiene a los enemigos durante un tiempo
      {
        if (enemies[i].isAwake)
        {
          enemies[i].vel = 0;
          frozen = true;
        }
      }
      break;
    case INMORTAL:
    pj_color = blanco;
      inmortal = true; //El PNJ2 no puede recibir daño
      break;
    case CURE:
      pnj2.hp = (pnj2.hp + CURE_ITEM) % HP; // Cura al PNJ2 sin que supere el máx de HP
      break;
    case DAMAGE:
      pnj2.hp -= DAMAGE_ITEM; // Inflige daño al PNJ2
      break;
    case VENOM:
      pj_color = morado;
      poisoned = true; // va a ir dañando poco a poco al PNJ2
      break;
    case INOFENSIVE:
      pj_color = rosa;
      inofensive = true;
      println("Just got: " + item.type);
      break;
    default:
  }  
}

void ItemCheck() // Retira los efectos de aquellos items cuyo timer haya terminado
{
  boolean free_of_effects = true; // Para ver si no le afecta ningun efecto
  for (int i = 0; i < items_num; i++)
  {
    if (items[i].isTaken)
    {
      if (items[i].effectTimer.CheckTimer())
      {
        switch (items[i].type)
        {
          case VEL:
            speedUp = 1;
            break;
          case FREEZE:
            for (int j = 0; j < N; j++)
            {
              if (enemies[j].isAwake)
              {
                enemies[j].vel = enemyMinVel;
                enemy_color = rojo;
                frozen = false;
              }
            }
            break;
          case INMORTAL:
            inmortal = false;
            break;
          case VENOM:
            poisoned = false;
            break;
          case INOFENSIVE:
            inofensive = false;
          default:
        }
        items[i].type = Item_type.NULO; // el tipo del item pasa a ser NULO porque las colisiones siguen funcionando, así no infligirá ningún efecto al player
      }
      else
      {
        free_of_effects = false; // Si se llega aquí, el pj aún está sufriendo algún efecto
      }
    }
  }
  if (free_of_effects)
  {
    pj_color = turquesa; // el color se devuelve al color original si está libre de efectos
  }
}

// Other Functions

int NearEnemy() // Devuelve el index del array de enemigos que indica el enemigo que más cerca se encuentre del PNJ1
{
  int index = 0; // El indice empieza siendo 0
  for (int i = 0; i < N; i++)
  {  
    if (DistanceBetween(enemies[i].pos, pnj1.pos) < pnj1.dist * 2)
    {
        index = DistanceBetween(enemies[i].pos, pnj1.pos) < DistanceBetween(enemies[index].pos, pnj1.pos) ? i : index; 
        // Si la distancia del enemigo que estamos revisando es menor a la del último enemigo más cercano revisado guardamos su índice
    }
  }
  return index;
}

void PNJLogic()
{
  for (int i = 0; i < N; i++)
  {  
    // como el pnj1 nunca va a esperar a que lo recojamos, la variable isWaiting de la clase pnj nunca se usa, así que le daremos un nuevo uso
    pnj1.isWaiting = DistanceBetween(enemies[i].pos, pnj1.pos) > pnj1.dist * 2 ? true : !enemies[i].isAwake ? true : enemies[i].isDead ? true : false;
    // Si la distancia entre el enemigo y el pnj1 es mayor al doble de la distancia indicada en dist, isWaiting será true
    // en caso contrario, si el enemigo no está despierto (aun no se ha creado) isWaiting será true, en caso contrario, 
    // si el enemigo está muerto, isWaiting será true, y en caso contrario, isWaiting será false    
  }
  // good PNJ movement:
  
  // Si no detectamos ningun enemigo vivo cerca del pnj1:
  if (pnj1.isWaiting) 
  {
    // Si la distancia entre el pj y el pnj1 es mayor a 
    // la distancia establecida en el pnj1_dist que se acerque
    if (DistanceBetween(pnj1.pos, pj_pos) > pnj1.dist) 
    {
      pnj1.pos.x = MoveTowards(pnj1.pos.x, pj_pos.x, pnj1.vel);
      pnj1.pos.y = MoveTowards(pnj1.pos.y, pj_pos.y, pnj1.vel);
    }
  }
  else // Si no, se moverá en dirección contraria a la que se encuentre el enemigo más cercano a este
  {
    pnj1.pos.x = MoveAway(pnj1.pos.x, enemies[NearEnemy()].pos.x, pnj1.vel * 2);  
    pnj1.pos.y = MoveAway(pnj1.pos.y, enemies[NearEnemy()].pos.y, pnj1.vel * 2);
  }
  
  if (pnj2.isWaiting) // Aparece esperando 
  {
    if (DistanceBetween(pnj2.pos, pj_pos) < pnj2.dist) // Cuando el pj se acerque lo suficiente al PNJ2, este comenzará a seguirle
    {
      pnj2.isWaiting = false;
    }
  }
  // Si la distancia entre el pj y el pnj2 es mayor a 
  // la distancia establecida en el pnj2.dist que se acerque
  else if (DistanceBetween(pnj2.pos, pj_pos) > pnj2.dist) 
  {
    pnj2.pos.x = MoveTowards(pnj2.pos.x, pj_pos.x, pnj2.vel);
    pnj2.pos.y = MoveTowards(pnj2.pos.y, pj_pos.y, pnj2.vel);
  }
  
  if (pnj2.hp <= 0) // Si el hp es menor o igual a 0, muere.
  {
    actualScene = Scene.DEATH;
    InitializeScene();
  }
  
  // Enemies movement
  for (int i = 0; i < N; i++)
  {
    if (enemies[i].isAwake && !enemies[i].isDead)
    {
      if (!frozen)
      {
        switch (enemies[i].type)
        {
        case PREDATOR: // Se dirige hacia el PNJ2
          enemies[i].pos.x = MoveTowards(enemies[i].pos.x ,pnj2.pos.x, enemies[i].vel / 2); 
          enemies[i].pos.y = MoveTowards(enemies[i].pos.y ,pnj2.pos.y, enemies[i].vel / 2);
          break;
        case SHY: // Se dirige hacia el PNJ2 a no ser que el pj esté cerca
        if (DistanceBetween(enemies[i].pos, pj_pos) < enemies[i].detectionDistance)
        {
          enemies[i].pos.x = MoveAway(enemies[i].pos.x ,pj_pos.x, enemies[i].vel);
          enemies[i].pos.y = MoveAway(enemies[i].pos.y ,pj_pos.y, enemies[i].vel);
        }
        else // Si el PJ está cerca, se alega de él
        {
          enemies[i].pos.x = MoveTowards(enemies[i].pos.x ,pnj2.pos.x, enemies[i].vel / 2);
          enemies[i].pos.y = MoveTowards(enemies[i].pos.y ,pnj2.pos.y, enemies[i].vel / 2);
        }
          break;
        case STALKER: // Persigue al PNJ1
          enemies[i].pos.x = MoveTowards(enemies[i].pos.x ,pnj1.pos.x, enemies[i].vel);
          enemies[i].pos.y = MoveTowards(enemies[i].pos.y ,pnj1.pos.y, enemies[i].vel);
        }
        EnemyVel(enemies[i]);
      }

      if (DistanceBetween(pj_pos, enemies[i].pos) < pjEnemyOffset && !inofensive) // Si el pj colisiona con el enemy, lo mata
      {
        enemies[i].isDead = true;
      }
      if (DistanceBetween(pnj2.pos, enemies[i].pos) < pnj2EnemyOffset && !inmortal) // Si el pnj2 colisiona con el enemy, recibe daño
      {
        GetDamage(pnj2, enemyDamage);
      }
      DrawEnemies(enemies[i].pos, enemies[i].size); // Dibujamos a los enemigos
    }
  }
}

void EnemyVel(Enemy enemy) // Esta funcion varia la velocidad de los enemigos sutilmente
{
  if (!enemy.speedTimer.isStarted) //Inicia un timer si no está iniciado
  {
    enemy.speedTimer.StartTimer(enemySpeedTime);
  }
  if (enemy.speedTimer.CheckTimer()) //Cuando el timer llegue al tiempo indicado, el incremento de velocidad cambiará
  {
    enemy.speedIncrement = random(enemyMinVel, enemyMaxVel);
  }
  else
  {
     enemy.vel += enemy.vel > enemyMaxVel ? -0.01 : enemy.vel < enemyMinVel ? 0.01 : enemy.speedIncrement; // si la velocidad és mayor que la velocidad maxima, 
  }                                                                                                        // es menor que la velocidad minima, le sumamos 0,01 a la velocidad del 
}                                                                                                          //enemy, si no, le sumamos speedIncrement(lo que hemos seteado anteriormente)

void GetDamage(Pnj pnj, float damage) // el pnj recibe daño
{
  pnj.hp -= damage;
}

void InitializeButtons()
{
  if (actualScene == Scene.MENU)
  {    
    label_pos = new PVector(w_half, h_half - MP_SIZE / 2);
    N_plus = new Button();
    N_minus = new Button();
    playButton = new Button();
    mQuitButton = new Button();
    
    N_plus.ancho = MP_SIZE;
    N_plus.alto = MP_SIZE;
    N_plus.pos = new PVector(label_pos.x + ancho_label / 2, label_pos.y);
    
    N_minus.ancho = MP_SIZE;
    N_minus.alto = MP_SIZE;
    N_minus.pos = new PVector(label_pos.x - ancho_label / 2, label_pos.y);
    
    playButton.ancho = 200;
    playButton.alto = 75;
    playButton.pos = new PVector(w_half, h_half + 80);
  
    mQuitButton.ancho = 175;
    mQuitButton.alto = 50;
    mQuitButton.pos = new PVector(w_half, h_half + 160);
    
    playButton.c_base = verde;
    playButton.c_over = verde_claro;
    mQuitButton.c_base = rojo;
    mQuitButton.c_over = rojo_claro;
    N_plus.c_base = verde;
    N_plus.c_over = verde_claro;
    N_minus.c_base = rojo;
    N_minus.c_over = rojo_claro;
    
    playButton.sceneToGo = Scene.LEVEL1;
  }
  else
  {
    restartButton = new Button();
    quitButton = new Button();
  
    restartButton.ancho = 200;
    restartButton.alto = 75;
    restartButton.pos = new PVector(w_half, h_half + 70);
  
    quitButton.ancho = 175;
    quitButton.alto = 50;
    quitButton.pos = new PVector(w_half, h_half + 150);
    
    restartButton.c_base = verde;
    restartButton.c_over = verde_claro;
    quitButton.c_base = rojo;
    quitButton.c_over = rojo_claro;
    
    restartButton.sceneToGo = Scene.LEVEL1;
    quitButton.sceneToGo = Scene.MENU;
  }
}

void DrawButtons()
{
  // restart Button
  if (restartButton.IsOver())
  {
    fill(restartButton.c_over);
  }
  else
  {
    fill(restartButton.c_base);
  }
  rectMode(CENTER);
  rect(restartButton.pos.x, restartButton.pos.y, restartButton.ancho, restartButton.alto);
  fill(0);
  textSize(40);
  textAlign(CENTER, CENTER);
  text("RESTART", restartButton.pos.x, restartButton.pos.y);
  
  // quit Button
    if (quitButton.IsOver())
  {
    fill(quitButton.c_over);
  }
  else
  {
    fill(quitButton.c_base);
  }
  rectMode(CENTER);
  rect(quitButton.pos.x, quitButton.pos.y, quitButton.ancho, quitButton.alto);
  fill(0);
  textSize(30);
  textAlign(CENTER, CENTER);
  text("QUIT", quitButton.pos.x, quitButton.pos.y);
}

void DeathScene()
{
  fill(0);
  textSize(50);
  textAlign(CENTER);
  text("YOU LOSE!", w_half, h_half - 50);
  DrawButtons();
}

void VictoryScene()
{
  fill(0);
  textSize(50);
  textAlign(CENTER);
  text("YOU WIN!", w_half, h_half - 50);
  DrawButtons();
}

void MainMenu()
{
  // Draw Rectangles
  rectMode(CENTER);
  fill(200);
  rect(label_pos.x, label_pos.y, MP_SIZE + 10, MP_SIZE + 10);
  if (N < MAX_ENEMIES)
  {
    if (N_plus.IsOver())
    {
      fill(N_plus.c_over);
    }
    else
    {
      fill(N_plus.c_base);
    }
    rect(N_plus.pos.x, N_plus.pos.y, N_plus.ancho, N_plus.alto);
    fill(0);
    textSize(50); 
    textAlign(CENTER, CENTER);
    text("+", label_pos.x + MP_SIZE * 1.25, label_pos.y);  
  }
  if(N > MIN_ENEMIES)
  {
      if (N_minus.IsOver())
    {
      fill(N_minus.c_over);
    }
    else
    {
      fill(N_minus.c_base);
    }
    rect(N_minus.pos.x, N_minus.pos.y, N_minus.ancho, N_minus.alto);
    fill(0);
    textSize(50); 
    textAlign(CENTER, CENTER);
    text("-", label_pos.x - MP_SIZE * 1.2, label_pos.y - 5);   
  }
  
  // Draw Text
  fill(0);
  textSize(30);
  text(N, label_pos.x, label_pos.y);
  textSize(50);
  textAlign(CENTER, CENTER);
  text("PURSUIT OF HAPPINESS", w_half, h_half - 100);
  textSize(15);
  text("Nº ENEMIES", w_half, h_half - 55);
  
  // play Button
  if (playButton.IsOver())
  {
    fill(playButton.c_over);
  }
  else
  {
    fill(playButton.c_base);
  }
  rect(playButton.pos.x, playButton.pos.y, playButton.ancho, playButton.alto);
  fill(0);
  textSize(40);
  textAlign(CENTER, CENTER);
  text("PLAY", playButton.pos.x, playButton.pos.y);
  
  // quit Button
    if (mQuitButton.IsOver())
  {
    fill(mQuitButton.c_over);
  }
  else
  {
    fill(mQuitButton.c_base);
  }
  rectMode(CENTER);
  rect(mQuitButton.pos.x, mQuitButton.pos.y, mQuitButton.ancho, mQuitButton.alto);
  fill(0);
  textSize(30);
  textAlign(CENTER, CENTER);
  text("QUIT", mQuitButton.pos.x, mQuitButton.pos.y);
}
