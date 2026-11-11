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
MaxFallSpeed = 5.9;

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
//Aspecto y duración del efecto de derrota
DefeatSprite = -1;
DefeatFrames = 18;

//Duración del aplastamiento y la advertencia
FlattenedFrames = 240; //4 segundos
WakingFrames = 150; // 2.5 segundos

//Capacidad y vínculo de carga
CanBeCarried = false;
Carrier = noone;

//Duración antes de advertir que despertará en brazos
CarriedFrames = 240; //4 segundos

//Configuración del lanzamiento
ThrowMode = THROW_MODE.HORIZONTAL;
ThrowOwner = noone;
ThrownFrames = 150;

//Frenado del enemigo aplastado al tocar el suelo
FlattenedDecel = 0.5;

//Evitar procesar una instancia retirada
RemovedFromLevel = false;

//Vulnerabilidad a enemigos lanzados
CanBeHitByThrown = false;

//Recompensa al ser derrotado
DropsDiamond = false;

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
        
        case ENEMY_STATE.THROWN:
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
    var PreviousHSpeed = HSpeed;
    var PreviousVSpeed = VSpeed;
    var PreviousHSubPixel = HSubPixel;
    var PreviousVSubPixel = VSubPixel;

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
    //Conservar la trayectoria al terminar el lanzamiento
    if (
        PreviousState == ENEMY_STATE.THROWN
        && NewState == ENEMY_STATE.FLATTENED
    )
    {
        HSpeed = PreviousHSpeed;
        VSpeed = PreviousVSpeed;
    
        HSubPixel = PreviousHSubPixel;
        VSubPixel = PreviousVSubPixel;
    
        ThrowOwner = noone;
    }
    
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
               Facing = -Player.Facing;
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
    return CheckGround();
};

//Reacción ejecutada después de dañar al jugador
OnPlayerDamaged = function(Player, PlayerSide)
{
};

//Elimina al enemigo y notifica a su generador
RemoveFromLevel = function(PermanentlyDefeated)
{
    if (RemovedFromLevel)
    {
        return;
    }

    RemovedFromLevel = true;

    //Representar una derrota real
if (PermanentlyDefeated)
{
    EnemyState = ENEMY_STATE.DEFEATED;
    DropDiamond();

    if (DefeatSprite != -1)
    {
        var DefeatEffect = instance_create_layer(
            x,
            y,
            "Effects",
            objEnemyDefeatEffect
        );

        DefeatEffect.sprite_index = DefeatSprite;
        DefeatEffect.DurationFrames = DefeatFrames;

        DefeatEffect.image_index = 0;
        DefeatEffect.image_speed = 0;
        DefeatEffect.image_xscale = 1;
        DefeatEffect.image_yscale = 1;
        DefeatEffect.image_alpha = 1;
        DefeatEffect.image_blend = c_white;
    }
}

    var Player = Carrier;
    Carrier = noone;

    if (instance_exists(Player))
    {
        if (Player.CarriedEnemy == id)
        {
            Player.CarriedEnemy = noone;
        }
    }

    var Owner = SpawnOwner;

    if (instance_exists(Owner))
    {
        if (Owner.ActiveEnemy == id)
        {
            Owner.ActiveEnemy = noone;
        }

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

//Actualizar al enemigo aplastado
UpdateFlattenedState = function()
{
    //Frenar gradualmente sobre el suelo
    if (OnGround)
    {
        HSpeed += clamp(
            -HSpeed,
            -FlattenedDecel,
            FlattenedDecel
        );
    }

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

//Crear el diamante correspondiente a un enemigo derrotado
DropDiamond = function()
{
    if (!DropsDiamond)
    {
        return;
    }

    var DropX = (bbox_left + bbox_right) * 0.5;
    var DropY = bbox_bottom;

    var Drop = instance_create_layer(
        DropX,
        DropY,
        "Pickups",
        objDiamond
    );

    //Buscar una posición libre cercana
    var Positioned = ResolveSolidOverlap(Drop, 32);

    //El generador decide el impulso inicial
    Drop.HSpeed = random_range(-1.2, 1.2);
    Drop.VSpeed = -2;
};

//Recibir el impacto de un enemigo lanzado
ReceiveThrownHit = function(Projectile)
{
    if (RemovedFromLevel || !CanBeHitByThrown)
    {
        return false;
    }

    if (Carrier != noone)
    {
        return false;
    }

    var ValidState =
        EnemyState == ENEMY_STATE.NORMAL
        || EnemyState == ENEMY_STATE.FLATTENED
        || EnemyState == ENEMY_STATE.WAKING;

    if (!ValidState)
    {
        return false;
    }

    RemoveFromLevel(true);

    return true;
};

//Comprobar impactos del proyectil en su posición actual
CheckThrownImpact = function()
{
    //Los sólidos consumen el proyectil
    if (CheckSolid(x, y))
    {
        RemoveFromLevel(true);
        return true;
    }
    
    //Recoger ítems sin consumir el proyectil
    CollectPickups(ThrowOwner, true);

    var EnemyCount = instance_number(objEnemy);

    for (var Index = 0; Index < EnemyCount; Index += 1)
    {
        var Target = instance_find(objEnemy, Index);

        if (!instance_exists(Target))
        {
            continue;
        }

        if (Target == id || Target.RemovedFromLevel)
        {
            continue;
        }

        if (Target.Carrier != noone)
        {
            continue;
        }

        var ValidTarget =
            Target.EnemyState == ENEMY_STATE.NORMAL
            || Target.EnemyState == ENEMY_STATE.FLATTENED
            || Target.EnemyState == ENEMY_STATE.WAKING;

        if (!ValidTarget)
        {
            continue;
        }

        if (instance_place(x, y, Target) != noone)
        {
            Target.ReceiveThrownHit(id);

            //El primer enemigo alcanzado consume el proyectil
            RemoveFromLevel(true);
            return true;
        }
    }

    return false;
};

//Actualizar el lanzamiento y comprobar todo su recorrido
UpdateThrownState = function()
{
    //Detectar impactos desde la posición inicial
    if (CheckThrownImpact())
    {
		audio_play_sound(sndEnemyImpact, 1, false);
        return;
    }

    if (ThrowMode == THROW_MODE.ARC)
    {
        VSpeed = min(
            VSpeed + Gravity,
            MaxFallSpeed
        );
    }
    else
    {
        VSpeed = 0;
    }

    //Convertir las velocidades a desplazamiento entero
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

    //Dividir el recorrido en avances pequeños
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
            var NextX = StartX + round(
                MoveX * MoveIndex / MoveSteps
            );
       
            var NextY = StartY + round(
                MoveY * MoveIndex / MoveSteps
            );
       
            //Una superficie semisólida consume el proyectil al descender
            if (
                NextY > y
                && CheckSemi(NextX, NextY)
            )
            {
                RemoveFromLevel(true);
                audio_play_sound(sndEnemyImpact, 1, false);
                return;
            }
       
            x = NextX;
            y = NextY;
       
            if (CheckThrownImpact())
            {
               audio_play_sound(sndEnemyImpact, 1, false);
               return;
            }
        }
    }

    //Terminar el lanzamiento sin borrar el impulso
    if (StateTimer >= ThrownFrames)
    {
        ChangeState(ENEMY_STATE.FLATTENED);
    }
};