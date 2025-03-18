int SPEED_TIME = 5000; 
int FREEZE_TIME = 3000; 
int INMORTAL_TIME = 5000;
int VENOM_TIME = 10000;
int SLOW_TIME = 3000;
float CURE_ITEM = 50;
float DAMAGE_ITEM = 30;

//Variables de muros
PVector[] muros;
float ancho_muro, alto_muro;
float WallDamage = 0.5;
int muros_num;

//Variables de Jugador
float pj_vel = 3;
float pj_size = 20;
PVector pj_pos;

float alfa = 0.1;
boolean colision = false;

boolean using_mouse = false;

//Enum del Item
public enum Item_type {VEL, FREEZE, INMORTAL, CURE, DAMAGE, VENOM, SLOW};
int type_num = 6;
//Enum del Enemy
public enum Enemy_type {SHY, STALKER, PREDATOR};

public class Item {
  boolean powerUp;
  boolean isTaken;
  Item_type type;
  PVector pos;
  Timer effectTimer;
  float effectTime;
  
  Item() 
  {
    effectTimer = new Timer();
    isTaken = false;
    pos = new PVector(0,0);
  }
  
  Item_type Type(int num)
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
      case 6:
        return Item_type.SLOW;
      default:
        return Item_type.SLOW;
    }
  }
}

public class Pnj {
  boolean isDead;
  boolean isWaiting;
    float vel;
    float size;
    float dist;
    float hp;
    PVector pos;
   
   Pnj()
   {
     isDead = false;
     isWaiting = true;
     pos = new PVector(random(0,width), random (0, height));
   }
}

public class Enemy {
  PVector pos;
  boolean isDead;
  boolean isAwake;
  float vel; 
  float size;
  float detectionDistance;
  float speedIncrement;
  Enemy_type type;
  Timer speedTimer;
  
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

public class Timer {
  boolean isStarted;
  float finalTime;
  
  void StartTimer(float time)
  {
    if (!isStarted)
    {
       finalTime = millis() + time;
       isStarted = true;
    }  
  }
  boolean CheckTimer()
  {
    if (millis() >= finalTime)
    {
      isStarted = false;
      return true;
    }
    else
    {
      return false;
    }
  }
  
  Timer()
  {
    isStarted = false;
  }
}

Pnj pnj1 = new Pnj();
Pnj pnj2 = new Pnj();

// Variables de Item
Item[] items;
int items_num;
int items_size = 10;
boolean poisoned = false;
boolean frozen = false;
boolean inmortal = false;
float slowDown = 1;
float speedUp = 1;


// Variables de Enemy
Enemy[] enemies;
int enemy_num;
int enemy_counter = 0;
float enemySpawnTime = 5000;
float enemySpeedTime = 2500;
float enemyMaxVel = 0.3;
float enemyMinVel = 0.05;
float enemyDamage = 0.5;
float pjEnemyOffset;
float pnj2EnemyOffset;
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
      pj_pos.y -= pj_vel;
    }
    else if ((key == 'd' || key == 'D')) { // && Borders(3, pj_pos, pj_vel) && !WallBorder(3, pj_pos)) {
      pj_pos.x += pj_vel;
    }
    else if ((key == 'a' || key == 'A')) { // && Borders(2, pj_pos, pj_vel) && !WallBorder(2, pj_pos)) {
      pj_pos.x -= pj_vel;
    }
    else if ((key == 's' || key == 'S')) { // && Borders(1, pj_pos, pj_vel) && !WallBorder(1, pj_pos)) {
      pj_pos.y += pj_vel;
    }
    
    colision = WallColision(pj_pos, pj_size);
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

Boolean WallColision(PVector p, float size, int index)
{
    float p_max_x = p.x + size / 2;
    float p_max_y = p.y + size / 2;
    float p_min_x = p.x - size / 2;
    float p_min_y = p.y - size / 2;
    
    // Caja 1 con la 2: xmax1 > xmin2 - Caja 2 con la 1: xmax2 > xmin1
    // Caja 1 con la 2: ymax1 > ymin2 - Caja 2 con la 1: ymax2 > ymin1
    // Suponemos que el PJ es 1 y el muro es 2
    //if (((PJ_max.x > muros[i].x)||(coord_max_muro.x > PJ_min.x))
    //&&
    //((PJ_max.y > muros[i].y)||(coord_max_muro.y > PJ_min.y))) {
      
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

Boolean WallColision(PVector p, float x_size, float y_size, int index)
{
  float p_max_x = p.x + x_size / 2;
  float p_max_y = p.y + y_size / 2;
  float p_min_x = p.x - x_size / 2;
  float p_min_y = p.y - y_size / 2;
      
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
  pnj2.vel = 0.15;
  pnj2.size = 15.0;
  pnj2.dist = 75.0;
  pnj2.hp = 100;
  pnj2.isWaiting = true;
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
    } while (WallColision(muros[i], ancho_muro, alto_muro, i) && (muros[i].x > width/2 + ancho_muro || muros[i].x < width/2 - ancho_muro) && (muros[i].y < height/2 - alto_muro || muros[i].y > height/ 2 + alto_muro));
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
      items[i].type = items[i].Type((int)random(4, type_num - 1));
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
      case SLOW:
        items[i].effectTime = SLOW_TIME;
        break:
      default:
    }
    //VEL, FREEZE, INMORTAL, CURE, DAMAGE, VENOM, SLOW
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
   
   if (colision)
   {
    fill(0, 255, 0);
   }
   else
   {
     fill(255, 0, 0);
   }
    ellipse(pj_pos.x, pj_pos.y, pj_size, pj_size);
    
    //DIBUJAR AL PNJ1 Y PNJ2:
    
    if (!pnj1.isDead)
    {
      fill(0, 0, 255);
      ellipse(pnj1.pos.x, pnj1.pos.y, pnj1.size, pnj1.size);
    }
    if (!pnj2.isDead)
    {
      fill(255, 0, 0);
      ellipse(pnj2.pos.x, pnj2.pos.y, pnj2.size, pnj2.size);
    }
    
    //DIBUJAR MUROS:
    
    rectMode(CENTER);
     for(int i = 0; i < muros_num; i++)
     {
        fill(255, 0, 0);
        rect(muros[i].x + ancho_muro/2.0, muros[i].y + alto_muro/2.0, ancho_muro, alto_muro);
     }
     
     //DIBUJAR ÍTEMS:
     
      for(int i = 0; i < items_num; i++)
     {
        fill(0, 255, 0);
        ellipse(items[i].pos.x, items[i].pos.y, items_size, items_size);
     }     
}    

void DrawEnemies(PVector enemy, float size)
{
  fill(255);
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
  switch(item.type)
  {
    case VEL:
      speedUp = 2;
      break;
    case FREEZE:
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
      inmortal = true;
      break;
    case CURE:
      pnj2.hp += CURE_ITEM;
      break;
    case DAMAGE:
      pnj2.hp -= DAMAGE_ITEM
      break;
    case VENOM:
      poisoned = true;
      break;
    case SLOW:
      slowDown = 0.5;
      break:
    default:
  }
  item.isTaken = true;
}

// Other Functions

void PNJLogic()
{
   // good PNJ movement:
  
  // Si la distancia entre el pj y el pnj1 es mayor a 
  // la distancia establecida en el pnj1_dist que acerque
  if (DistanceBetween(pnj1.pos, pj_pos) > pnj1.dist)
  {
    pnj1.pos.x = MoveTowards(pnj1.pos.x, pj_pos.x, pnj1.vel * speedUp);
    pnj1.pos.y = MoveTowards(pnj1.pos.y, pj_pos.y, pnj1.vel * speedUp);
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
    pnj2.pos.x = MoveTowards(pnj2.pos.x, pj_pos.x, pnj2.vel * speedUp);
    pnj2.pos.y = MoveTowards(pnj2.pos.y, pj_pos.y, pnj2.vel * speedUp);
  }
  
  

  // Enemies movement
  for (int i = 0; i < enemy_num; i++)
  {
    if (enemies[i].isAwake && !enemies[i].isDead)
    {
      switch (enemies[i].type)
      {
        case PREDATOR:
          enemies[i].pos.x = MoveTowards(enemies[i].pos.x ,pnj2.pos.x, enemies[i].vel / 2 * slowDown);
          enemies[i].pos.y = MoveTowards(enemies[i].pos.y ,pnj2.pos.y, enemies[i].vel / 2 * slowDown);
          break;
        case SHY:
        if (DistanceBetween(enemies[i].pos, pj_pos) < enemies[i].detectionDistance)
        {
          enemies[i].pos.x = MoveAway(enemies[i].pos.x ,pj_pos.x, enemies[i].vel * slowDown);
          enemies[i].pos.y = MoveAway(enemies[i].pos.y ,pj_pos.y, enemies[i].vel * slowDown);
        }
        else
        {
          enemies[i].pos.x = MoveTowards(enemies[i].pos.x ,pnj2.pos.x, enemies[i].vel / 2 * slowDown);
          enemies[i].pos.y = MoveTowards(enemies[i].pos.y ,pnj2.pos.y, enemies[i].vel / 2 * slowDown);
        }
          break;
        case STALKER: 
          enemies[i].pos.x = MoveTowards(enemies[i].pos.x ,pnj1.pos.x, enemies[i].vel * slowDown);
          enemies[i].pos.y = MoveTowards(enemies[i].pos.y ,pnj1.pos.y, enemies[i].vel * slowDown);
      }

      if (DistanceBetween(pj_pos, enemies[i].pos) < pjEnemyOffset)
      {
        enemies[i].isDead = true;
      }
      if (DistanceBetween(pnj2.pos, enemies[i].pos) < pnj2EnemyOffset)
      {
        GetDamage(pnj2, enemyDamage);
      }

      EnemyVel(enemies[i]);
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
     enemy.vel += enemy.vel > enemyMaxVel * slowDown ? -0.01 : enemy.vel < enemyMinVel * slowDown ? 0.01 : enemy.speedIncrement;
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
