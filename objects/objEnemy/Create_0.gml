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

StateSpriteWaking = -1;

//Duración del aplastamiento y la advertencia
FlattenedFrames = 240; //4 segundos
WakingFrames = 150; // 2.5 segundos

//Capacidad y vínculo de carga
CanBeCarried = false;
Carrier = noone;

//Duración antes de advertir que despertará en brazos
CarriedFrames = 240; //4 segundos

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
        
        case ENEMY_STATE.WAKING:
            HSpeed = 0;
            HSubPixel = 0;
        
            if (StateSpriteWaking != -1)
            {
                sprite_index = StateSpriteWaking;
            }
            else if (StateSpriteFlattened != -1)
            {
                sprite_index = StateSpriteFlattened;
            }
        
            if (StateMaskFlattened != -1)
            {
                mask_index = StateMaskFlattened;
            }
        
            image_index = 0;
            image_speed = 1;
            break;
        
        case ENEMY_STATE.CARRIED:
            HSpeed = 0;
            VSpeed = 0;
        
            HSubPixel = 0;
            VSubPixel = 0;
        
            OnGround = false;
        
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

//Desvincular al portador y colocar al enemigo junto a sus pies
DetachCarrier = function()
{
    var Player = Carrier;

    Carrier = noone;

    if (instance_exists(Player))
    {
        if (Player.CarriedEnemy == id)
        {
            Player.CarriedEnemy = noone;
        }

        x = Player.x;
        y = Player.y;
    }

    HSpeed = 0;
    VSpeed = 0;

    HSubPixel = 0;
    VSubPixel = 0;

    OnGround = false;
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

    //Conservar el vínculo solo durante carga y advertencia
    if (
        Carrier != noone
        && NewState != ENEMY_STATE.CARRIED
        && NewState != ENEMY_STATE.WAKING
    )
    {
        DetachCarrier();
    }
    
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
           var WakeDir = sign(Player.x - x);
   
           if (WakeDir != 0)
           {
               Facing = WakeDir;
           }
           else
           {
               Facing = Player.Facing;
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

//Comprobar si la máscara del enemigo está apoyada
HasGround = function()
{
    return place_meeting(x, y + 1, objSolid);
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
    //No golpear enemigos que estén sujetos
    if (Carrier != noone)
    {
        return false;
    }
    
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
    
    if (StateTimer >= FlattenedFrames)
    {
        ChangeState(ENEMY_STATE.WAKING);
    }
};

//Advierte que el enemigo está a punto de despertar
UpdateWakingState = function()
{
    HSpeed = 0;

    //Recuperar el comportamiento normal
    if (StateTimer >= WakingFrames)
    {
        ChangeState(ENEMY_STATE.NORMAL);
    }
};

//Esperar en brazos antes de comenzar a despertar
UpdateCarriedState = function()
{
    if (StateTimer >= CarriedFrames)
    {
        ChangeState(ENEMY_STATE.WAKING);
    }
};