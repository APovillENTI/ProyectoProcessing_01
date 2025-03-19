// VARIABLES CONSTANTES

// Tiempo que duran los efectos de los items
static final int SPEED_TIME = 5000; 
static final int FREEZE_TIME = 3000; 
static final int INMORTAL_TIME = 5000;
static final int VENOM_TIME = 10000;

// Poder de los efectos de los items
static final float VENOM_DAMAGE = 0.01;
static final float CURE_ITEM = 50;
static final float DAMAGE_ITEM = 1;

// Vida inicial del PNJ2
static final float HP = 100;

//Colores
color morado = color(150, 0, 180); // Para el veneno
color rojo = color(200, 0, 0); // Para los enemigos
color cian = color(165, 244, 255); // Para los enemigos congelados (Frozen)
color verde = color(0, 205, 0); // Para los items
color amarillo = color(250, 250, 0); // Para el efecto de velociad
color naranja = color(250, 150, 0); // Para el PNJ1
color azul = color(0, 250, 0); // Para el PNJ2
color blanco = color(255, 255, 255); // Para la inmortalidad
color turquesa = color(0, 250, 160); // Para el PJ

//Variables de muros
PVector[] muros; // Contiene todos los muros
float ancho_muro, alto_muro; 
float WallDamage = 0.5; // Daño que inflingen los muros al colisionar con el PNJ2
int muros_num; // Numero max de muros

//Variables de Jugador
float pj_vel = 3; 
float pj_size = 20;
PVector pj_pos;
color pj_color = turquesa;

float alfa = 0.1;

boolean using_mouse = false; // Para cambiar de modo WASD a modo Mouse (falta por ajustar)

//Enum del Item
public enum Item_type {VEL, FREEZE, INMORTAL, CURE, DAMAGE, VENOM, NULO};
int type_num = 6; // Es el numero total de efectos de los items(sin contar el NULO) para randomizarlos
//Enum del Enemy
public enum Enemy_type {SHY, STALKER, PREDATOR}; // SHY: Se acerca al PNJ2 pero huye del PJ
                                                 // STALKER: Se acerca al PNJ1
                                                 // PREDATOR: Ataca al PNJ2

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
  
  Item_type Type(int num) // Este método sirve para asignarle un efecto aleatorio al item
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
        return Item_type.CURE;
      case 4: 
        return Item_type.DAMAGE;
      case 5:
        return Item_type.VENOM;
      default:
        return Item_type.NULO;
    }
  }
}

public class Pnj {
  boolean isDead;
  boolean isWaiting; // Cuando spawnea, el PNJ2 permanece inmovil, este booleano activa o desactiva este estado
    float vel;
    float size;
    float dist; // distancia respecto al PJ que tendrá el PNJ
    float hp; 
    PVector pos;
    color tint; // Color del PNJ
    
   Pnj() //Constructor de la clase PNJ
   {
     isDead = false;
     isWaiting = true;
     pos = new PVector(random(0,width), random (0, height)); // la posición es aleatoria (revisarlo porque no funciona correctamente(siempre aparece en la esquina izqda))
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

// Variables que indican el estado actual del player
boolean poisoned = false;
boolean frozen = false;
boolean inmortal = false;

float items_size = 10; 
float speedUp = 1; // la velocidad del PJ se multiplica por este valor, el cual cambia si se obtiene un item de velocidad
color item_color = verde;

// Variables de Enemy
Enemy[] enemies; // Contiene todos los enemigos
int enemy_num; // Total de enemigos
int enemy_counter = 0; // Cuenta los enemigos spawneados

float enemySpawnTime = 5000; // Tiempo que tardan los enemigos en spawnear
float enemySpeedTime = 2500; // Tiempo que tarda en variar la velocidad del enemy
//Velocidad Max y min del enemy (variará dentro de este rango)
float enemyMaxVel = 0.3;
float enemyMinVel = 0.05;
float enemyDamage = 0.5; // Dna

float pjEnemyOffset;
float pnj2EnemyOffset;
color enemy_color = rojo;
Timer enemyTimer;

int N = 10;

//  SETUP

void setup() {
  // Creamos la ventana
  size(600, 600);
  
  enemy_num = N;
  
  //Inicializamos las variables de los PNJ
  InitializePNJs();
  
  // Inicializamos los muros
  InitializeWalls();
  
  //Inicializamos los ítems
  InitializeItems();
  
  // Inicializamos los enemigos
  InitializeEnemies();
  
  // Inicializamos la posicion del jugador en medio de la ventana
  pj_pos = new PVector(width / 2.0, height / 2.0);
}

//  DRAW

void draw()
{
  background(255);
  // KEY PRESSED
  
  //Movimiento del PJ (WASD)
  if (keyPressed) {
    if ((key == 'w' || key == 'W')) { // && Borders(0, pj_pos, pj_vel) && !WallBorder(0, pj_pos)) {
      pj_pos.y -= pj_vel * speedUp;
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
  
  if (enemy_counter < enemy_num)
  {
    EnemySpawn();
  }
  
  if (WallColision(pnj2.pos, pnj2.size))
  {
      GetDamage(pnj2, WallDamage);
  }
  
  for (int i = 0; i < items_num; i++)
  {
    if (!items[i].isTaken && DistanceBetween(items[i].pos, pj_pos) < (items_size + pj_size) / 2)
    {
      items[i].effectTimer.StartTimer(items[i].effectTime);
      items[i].isTaken = true;
      GetItem(items[i]);
    }
  }
  
  ItemCheck();
  
  if (poisoned)
  {
    pnj2.hp -= VENOM_DAMAGE;
  }
  
  DrawInstances();
  DrawHUD();
}

// EVENTS

void keyPressed()
{
   if (key == 'g' || key == 'G')
    {
      if (using_mouse)
      {
        using_mouse = false;
      }
      else
      {
        using_mouse = true;
      }
    }
}

void mouseMoved()
{
  for (int i = 0; i < items_num; i++)
  {
    if (DistanceBetween(items[i].pos, pj_pos) < (items_size + pj_size) / 2)
    {
      items[i].effectTimer.StartTimer(items[i].effectTime);
      items[i].isTaken = true;
      GetItem(items[i]);
    }
  }
}

//  FLOAT FUNCTIONS

float DistanceBetween(PVector point1, PVector point2)
{
  return sqrt(pow(point2.x - point1.x, 2.0) + pow(point2.y - point1.y, 2.0));
}

float MoveTowards(float thisPoint, float finalPoint, float speed)
{
  float move = (1.0 - speed * alfa) * thisPoint + speed * alfa * finalPoint;
  return move;
}

float MoveAway(float thisPoint, float finalPoint, float speed)
{
  float move = (1.0 + speed * alfa) * thisPoint - speed * alfa * finalPoint;
  return move;
}

//  BOOLEAN FUNCTIONS

Boolean FreeSpot(PVector pos, int index)
{
  if (WallColision(pos, items_size))
  {
    return false;
  }
  for(int i = 0; i < index; i++)
  {
    if (DistanceBetween(pos, items[i].pos) >= items_size)
    {
      continue;
    }
    else
    {
      return false;
    }
  }
  return true;
}


boolean Borders(int dir, PVector p, float speed)
{
  switch(dir)
  {  
    case(0):
      if (p.y - speed < 0)
      {
        return false;
      }
      else
      {
        return true;
      }
    case(1):
      if (p.y + speed > height)
      {
        return false;
      }
      else
      {
        return true;
      }
    case(2):
      if (p.x - speed < 0)
      {
        return false;
      }
      else
      {
        return true;
      }
    case(3):
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

Boolean WallBorder(int dir, PVector p)
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

Boolean WallColision(PVector p, float size)
{
    float p_max_x = p.x + size / 2;
    float p_max_y = p.y + size / 2;
    float p_min_x = p.x - size / 2;
    float p_min_y = p.y - size / 2;
      
    for(int i = 0; i < muros_num; i++)
    {
      PVector max_muro = new PVector(0,0);

      max_muro.x = muros[i].x + ancho_muro;
      max_muro.y = muros[i].y + alto_muro;

      if (p_max_x < max_muro.x - ancho_muro || p_max_y < max_muro.y - alto_muro || max_muro.x < p_min_x || max_muro.y < p_min_y) 
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

Boolean WallColision(PVector p, int index)
{
  float p_max_x = p.x + ancho_muro;
  float p_max_y = p.y + alto_muro;
  float p_min_x = p.x;
  float p_min_y = p.y;
      
  for(int i = 0; i < index; i++)
  {
    PVector max_muro = new PVector(0,0);

    max_muro.x = muros[i].x + ancho_muro;
    max_muro.y = muros[i].y + alto_muro;
     
    if (p_max_x < max_muro.x - ancho_muro || p_max_y < max_muro.y - alto_muro || max_muro.x < p_min_x || max_muro.y < p_min_y) 
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
void InitializePNJs()
{
  pnj1.vel = 0.1;
  pnj1.size = 20.0;
  pnj1.dist = 25.0;
  pnj1.hp = 100;
  pnj1.tint = naranja;
  pnj2.vel = 0.15;
  pnj2.size = 15.0;
  pnj2.dist = 75.0;
  pnj2.hp = HP;
  pnj2.isWaiting = true;
  pnj2.tint = azul;
}

void InitializeWalls()
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
  }
}

void InitializeItems()
{
    //El número de ítems es un número aleatorio
  items_num = (int)random(6, 12);
  
  //Inicializamos el array de ítems
  items = new Item[items_num];
  
  for(int i = 0; i < items_num; i++)
  {
    items[i] = new Item();
    do 
    {
      items[i].pos.x = random(0, width - items_size);
      items[i].pos.y = random(0, height - items_size);
    } while (!FreeSpot(items[i].pos, i));
    if (i < 3)
    {
      items[i].powerUp = true;
      items[i].type = items[i].Type((int)random(0, 3));
    }
    else
    {
      items[i].powerUp = false;
      items[i].type = items[i].Type((int)random(3, type_num));
    }
    switch (items[i].type)
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
      default:
        items[i].effectTime = 0;
    }
    //VEL, FREEZE, INMORTAL, CURE, DAMAGE, VENOM
    println(items[i].type);
  }
}

void InitializeEnemies()
{
  // Inicializamos el array
  enemies = new Enemy[enemy_num];
  enemyTimer = new Timer();
  
  // Seteamos los tipos de los enemies
  for (int i = 0; i < enemy_num; i++)
  {
    enemies[i] = new Enemy();
    if (i < enemy_num / 4)
    {
      enemies[i].type = Enemy_type.PREDATOR;
    }
    else if (i < enemy_num / 2)
    {
      enemies[i].type = Enemy_type.STALKER;
    }
    else
    {
      enemies[i].type = Enemy_type.SHY;
    }
    enemies[i].vel = enemyMinVel;
  }
  pjEnemyOffset = pj_size / 2 + enemies[0].size;
  pnj2EnemyOffset = pnj2.size / 2 + enemies[0].size;
}

// Draw functions:

void DrawHUD()
{
  fill(255, 0, 0);
  rect(10, 40, 200, 20);
  fill(0, 255, 0);
  float anchoBarra = max(map(pnj2.hp, 0, 100, 0, 200), 0); // Evitar valores negativos.
  rect(10, 40, anchoBarra, 20);
}

void DrawInstances()
{
   //DIBUJAR AL PJ:
   if (WallColision(pj_pos, pj_size))
   {
    fill(0,0,0);
   }
   else
   {
    fill(pj_color);   
   }
    ellipse(pj_pos.x, pj_pos.y, pj_size, pj_size);
    
    //DIBUJAR AL PNJ1 Y PNJ2:
    
    if (!pnj1.isDead)
    {
      fill(pnj1.tint);
      ellipse(pnj1.pos.x, pnj1.pos.y, pnj1.size, pnj1.size);
    }
    if (!pnj2.isDead)
    {
      fill(pnj2.tint);
      ellipse(pnj2.pos.x, pnj2.pos.y, pnj2.size, pnj2.size);
    }
    
    //DIBUJAR MUROS:
    
    rectMode(CENTER);
     //for(int i = 0; i < muros_num; i++)
     //{
     //   fill(255, 0, 0);
     //   rect(muros[i].x, muros[i].y, ancho_muro, alto_muro);
     //}
     
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
  println(enemies[0].vel);
}

// Enemy Manager:

void EnemySpawn()
{
  if (!enemyTimer.isStarted)
  {
    enemyTimer.StartTimer(enemySpawnTime);
  }
  if (enemyTimer.CheckTimer())
  {
    GenerateEnemy();
  }
}

void GenerateEnemy() {
  int enemyId;
  do 
  {
    enemyId = (int)random(0, enemy_num);
  } while(enemies[enemyId].isAwake && enemies[enemyId].isDead);
  
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
  enemyTimer.StartTimer(enemySpawnTime);
  enemies[enemyId].isAwake = true;
  enemy_counter++;
}

// Items logic

void GetItem(Item item)
{
  item.isTaken = true;
  switch(item.type)
  {
    case VEL:
      speedUp = 2;
      pj_color = amarillo;
      break;
    case FREEZE:
      enemy_color = cian;
      for (int i = 0; i < enemy_num; i++)
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
      inmortal = true;
      break;
    case CURE:
      pnj2.hp = (pnj2.hp + CURE_ITEM) % HP;
      break;
    case DAMAGE:
      pnj2.hp -= DAMAGE_ITEM;
      break;
    case VENOM:
      pj_color = morado;
      poisoned = true;
      break;
    default:
  }
}

void ItemCheck()
{
  boolean free_of_effects = true;
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
            for (int j = 0; j < enemy_num; j++)
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
          default:
        }
        items[i].type = Item_type.NULO;
      }
      else
      {
        free_of_effects = false;
      }
    }
  }
  if (free_of_effects)
  {
    pj_color = turquesa;
  }
}

//void ResetState()

// Other Functions

void PNJLogic()
{
   // good PNJ movement:
  
  // Si la distancia entre el pj y el pnj1 es mayor a 
  // la distancia establecida en el pnj1_dist que acerque
  if (DistanceBetween(pnj1.pos, pj_pos) > pnj1.dist)
  {
    pnj1.pos.x = MoveTowards(pnj1.pos.x, pj_pos.x, pnj1.vel);
    pnj1.pos.y = MoveTowards(pnj1.pos.y, pj_pos.y, pnj1.vel);
  }
  if (pnj2.isWaiting)
  {
    if (DistanceBetween(pnj2.pos, pj_pos) < pnj2.dist)
    {
      pnj2.isWaiting = false;
    }
  }
  else if (DistanceBetween(pnj2.pos, pj_pos) > pnj2.dist)
  {
    pnj2.pos.x = MoveTowards(pnj2.pos.x, pj_pos.x, pnj2.vel);
    pnj2.pos.y = MoveTowards(pnj2.pos.y, pj_pos.y, pnj2.vel);
  }

  // Enemies movement
  for (int i = 0; i < enemy_num; i++)
  {
    if (enemies[i].isAwake && !enemies[i].isDead)
    {
      if (!frozen)
      {
        switch (enemies[i].type)
        {
        case PREDATOR:
          enemies[i].pos.x = MoveTowards(enemies[i].pos.x ,pnj2.pos.x, enemies[i].vel / 2);
          enemies[i].pos.y = MoveTowards(enemies[i].pos.y ,pnj2.pos.y, enemies[i].vel / 2);
          break;
        case SHY:
        if (DistanceBetween(enemies[i].pos, pj_pos) < enemies[i].detectionDistance)
        {
          enemies[i].pos.x = MoveAway(enemies[i].pos.x ,pj_pos.x, enemies[i].vel);
          enemies[i].pos.y = MoveAway(enemies[i].pos.y ,pj_pos.y, enemies[i].vel);
        }
        else
        {
          enemies[i].pos.x = MoveTowards(enemies[i].pos.x ,pnj2.pos.x, enemies[i].vel / 2);
          enemies[i].pos.y = MoveTowards(enemies[i].pos.y ,pnj2.pos.y, enemies[i].vel / 2);
        }
          break;
        case STALKER: 
          enemies[i].pos.x = MoveTowards(enemies[i].pos.x ,pnj1.pos.x, enemies[i].vel);
          enemies[i].pos.y = MoveTowards(enemies[i].pos.y ,pnj1.pos.y, enemies[i].vel);
        }
        EnemyVel(enemies[i]);
      }

      if (DistanceBetween(pj_pos, enemies[i].pos) < pjEnemyOffset)
      {
        enemies[i].isDead = true;
      }
      if (DistanceBetween(pnj2.pos, enemies[i].pos) < pnj2EnemyOffset)
      {
        GetDamage(pnj2, enemyDamage);
      }
      DrawEnemies(enemies[i].pos, enemies[i].size);
    }
  }
}

void EnemyVel(Enemy enemy)
{
  if (!enemy.speedTimer.isStarted)
  {
    enemy.speedTimer.StartTimer(enemySpeedTime);
  }
  if (enemy.speedTimer.CheckTimer())
  {
    enemy.speedIncrement = random(enemyMinVel, enemyMaxVel);
  }
  else
  {
     enemy.vel += enemy.vel > enemyMaxVel ? -0.01 : enemy.vel < enemyMinVel ? 0.01 : enemy.speedIncrement;
  } 
}

void GetDamage(Pnj pnj, float damage)
{
  pnj.hp -= damage;
  if (pnj.hp <= 0)
  {
    pnj.isDead = true;
  }
}
