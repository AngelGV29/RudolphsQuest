/// @description Inicializa la física de los recogibles móviles

event_inherited();

//Movimiento
HSpeed = 0;
VSpeed = 0;

HSubPixel = 0;
VSubPixel = 0;

//Gravedad y frenado
Gravity = 0.16;
MaxFallSpeed = 5.9;
GroundDecel = 0.08;

OnGround = false;

//Duración opcional
HasLifetime = false;

LifeTimer = 0;
LifeFrames = 0;

BlinkFrames = 0;
BlinkInterval = 6;