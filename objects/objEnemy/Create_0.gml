/// @description Inicializa las propiedades comunes de los enemigos

//Estado
EnemyState = ENEMY_STATE.NORMAL;
StateTimer = 0;

//Propiedades generales
ContactDamage = 0;
MoveSpeed = 0;

//Gravedad
UsesGravity = true;
Gravity = 0.16;
MaxFallSpeed = 5.90;

//Movimiento
HSpeed = 0;
VSpeed = 0;
HSubPixel = 0;
VSubPixel = 0;

//Condiciones
Facing = -1;
OnGround = false;

//Referencia al generador que creó al enemigo
SpawnOwner = noone;

//Cambia el estado y reinicia su temporizador
ChangeState = function(NewState)
{
    if (EnemyState == NewState)
    {
        return;
    }

    EnemyState = NewState;
    StateTimer = 0;
};

//Comportamiento normal reemplazable
UpdateNormalState = function()
{
    HSpeed = 0;
};

//Reacción reemplazable al tocar una pared
OnWallHit = function()
{
    HSpeed = 0;
};

//Reacción ejecutada después de dañar al jugador
OnPlayerDamaged = function(Player, PlayerSide)
{
};

//Elimina al enemigo y notifica a su generador
RemoveFromLevel = function(PermanentlyDefeated)
{
    var Owner = SpawnOwner;

    if (instance_exists(Owner))
    {
        Owner.ActiveEnemy = noone;

        if (PermanentlyDefeated)
        {
            Owner.Defeated = true;
        }
    }

    instance_destroy();
};

