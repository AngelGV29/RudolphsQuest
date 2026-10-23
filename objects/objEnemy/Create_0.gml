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

//Propiedades de aplastamiento
CanBeFlattened = false;
LastHammerAttackId = -1; //Evitará que un enemigo pueda se alcanzado más de una vez por el mismo martillazo

//Sprites y máscaras de cada estado
StateSpriteNormal = sprite_index;
StateMaskNormal = mask_index;

StateSpriteFlattened = -1;
StateMaskFlattened = -1;

//Referencia al generador que creó al enemigo
SpawnOwner = noone;

//Aplica las propiedades iniciales de un estado
OnStateEnter = function(NewState)
{
    switch (NewState)
    {
        case ENEMY_STATE.NORMAL:
            if (StateSpriteNormal != -1)
            {
                sprite_index = StateSpriteNormal;
            }

            if (StateMaskNormal != -1)
            {
                mask_index = StateMaskNormal;
            }

            image_index = 0;
            image_speed = 0;
            break;

        case ENEMY_STATE.FLATTENED:
            HSpeed = 0;
            HSubPixel = 0;

            if (StateSpriteFlattened != -1)
            {
                sprite_index = StateSpriteFlattened;
            }

            if (StateMaskFlattened != -1)
            {
                mask_index = StateMaskFlattened;
            }

            image_index = 0;
            image_speed = 0;
            break;
    }
};

//Cambia de estado y reinicia su temporizador
ChangeState = function(NewState)
{
    if (EnemyState == NewState)
    {
        return false; //Ya estaba en ese estado
    }
    var PreviousState = EnemyState;
    EnemyState = NewState;
    StateTimer = 0;

    OnStateEnter(NewState);
    
    //Mirar al jugador al terminar de despertar
    if (
        PreviousState == ENEMY_STATE.WAKING
        && NewState == ENEMY_STATE.NORMAL
    )
    {
        var Player = instance_find(objPlayer, 0);
    
        if (instance_exists(Player))
        {
            var PlayerDir = sign(Player.x - x);
    
            if (PlayerDir != 0)
            {
                Facing = PlayerDir;
            }
        }
    
        image_xscale = Facing;
    }

    return true; //El estado cambió
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

//Procesa un impacto del martillo
ReceiveHammerHit = function(AttackId, Attacker)
{
    //Evitar impactos repetidos del mismo martillazo
    if (LastHammerAttackId == AttackId)
    {
        return false;
    }

    LastHammerAttackId = AttackId;

    //Comprobar si este enemigo puede aplastarse
    if (!CanBeFlattened)
    {
        return false;
    }

    //Solo los estados vulnerables pueden aplastarse
    var CanReceiveHit =
        EnemyState == ENEMY_STATE.NORMAL
        || EnemyState == ENEMY_STATE.WAKING;

    if (!CanReceiveHit)
    {
        return false;
    }

    ChangeState(ENEMY_STATE.FLATTENED);

    return true;
};

//Comportamiento mientras el enemigo está aplastado
UpdateFlattenedState = function()
{
    HSpeed = 0;
};