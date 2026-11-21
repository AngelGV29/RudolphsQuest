/// @description Actualiza recorrido, impactos y duración

LifeTimer += 1;

if (LifeTimer >= LifeFrames)
{
    instance_destroy();
    exit;
}

var Player = instance_find(objPlayer, 0);

//Retirar proyectiles alejados del jugador
if (instance_exists(Player))
{
    if (
        abs(x - Player.x) > DespawnRangeX
        || abs(y - Player.y) > DespawnRangeY
    )
    {
        instance_destroy();
        exit;
    }
}

//Respaldo para proyectiles fuera de la habitación
if (
    x < -RoomMargin
    || x > room_width + RoomMargin
    || y < -RoomMargin
    || y > room_height + RoomMargin
)
{
    instance_destroy();
    exit;
}

//Detectar también impactos desde la posición inicial
if (CheckImpact())
{
    ResolveImpact();
    exit;
}

//Acumular movimiento fraccional
HSubPixel += HSpeed;
VSubPixel += VSpeed;

var MoveX =
    floor(abs(HSubPixel))
    * sign(HSubPixel);

var MoveY =
    floor(abs(VSubPixel))
    * sign(VSubPixel);

HSubPixel -= MoveX;
VSubPixel -= MoveY;

//Comprobar el recorrido mediante avances pequeños
var MoveSteps = max(
    abs(MoveX),
    abs(MoveY)
);

if (MoveSteps > 0)
{
    var StartX = x;
    var StartY = y;

    for (
        var MoveIndex = 1;
        MoveIndex <= MoveSteps;
        MoveIndex += 1
    )
    {
        x = StartX + round(
            MoveX * MoveIndex / MoveSteps
        );

        y = StartY + round(
            MoveY * MoveIndex / MoveSteps
        );

        if (CheckImpact())
        {
            ResolveImpact();
            exit;
        }
    }
}

image_xscale = Facing;