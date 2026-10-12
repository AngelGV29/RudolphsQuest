/// @description Sigue al jugador y limita la cámara a la habitación

//Buscar nuevamente al jugador si fuera necesario
if (!instance_exists(Target))
{
    Target = instance_find(objPlayer, 0);
}

if (!instance_exists(Target))
{
    exit;
}

//Recuperar la cámara
if (CameraId == -1)
{
    CameraId = view_camera[0];
}

if (CameraId == -1)
{
    exit;
}

//Calcular posición objetivo
var TargetX =
    Target.x
    - ViewWidth * 0.5;

var TargetY =
    Target.y
    + TargetOffsetY
    - ViewHeight * 0.5;

//Calcular límites de la habitación
var MaxCameraX = max(
    0,
    room_width - ViewWidth
);

var MaxCameraY = max(
    0,
    room_height - ViewHeight
);

//Evitar mostrar el exterior
TargetX = clamp(
    TargetX,
    0,
    MaxCameraX
);

TargetY = clamp(
    TargetY,
    0,
    MaxCameraY
);

//Colocar inmediatamente la cámara al iniciar
if (!Initialized)
{
    CameraX = TargetX;
    CameraY = TargetY;
    Initialized = true;
}
else
{
    CameraX = lerp(
        CameraX,
        TargetX,
        FollowSpeed
    );

    CameraY = lerp(
        CameraY,
        TargetY,
        FollowSpeed
    );
}

//Aplicar una posición entera
camera_set_view_pos(
    CameraId,
    round(CameraX),
    round(CameraY)
);