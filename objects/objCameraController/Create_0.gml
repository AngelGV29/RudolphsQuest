/// @description Inicializa el controlador de cámara

//Referencia de la cámara y su objetivo
CameraId = -1;
Target = noone;

//Tamaño lógico de la vista
ViewWidth = 320;
ViewHeight = 180;

//Seguimiento
FollowSpeed = 0.12;
TargetOffsetY = -16;

//Posición interna sin redondear
CameraX = 0;
CameraY = 0;

//Control de inicialización
Initialized = false;