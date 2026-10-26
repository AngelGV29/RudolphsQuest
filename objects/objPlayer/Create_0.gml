/// @description Inicializa el movimiento básico del jugador
//Límites de velocidad horizontal
MaxWalkSpeed = 1.75;
MaxRunSpeed = 3.50;

//Límite horizontal conservado durante el salto
AirMaxSpeed = MaxWalkSpeed;

//Aceleración, frenado y giro en el suelo
GroundAccel = 0.05;
GroundDecel = 0.2;
GroundTurnAccel = 0.2;

//Aceleración,frenado y gito en el aire
AirAccel = 0.05;
AirDecel = 0.01;
AirTurnAccel = 0.15;

//Impulso de salto, gravedad y límite de caida
JumpSpeed = 4.75;
Gravity = 0.16;
MaxFallSpeed = 5.9;

//Velocidad horizontal y vertical actuales
HSpeed = 0;
VSpeed = 0;

//Fracciones de movimiento pendientes de aplicar
HSubPixel = 0;
VSubPixel = 0;

Facing = 1; //Indica hacia donde está mirando el jugador: -1 izquierda y 1 derecha
HammerFacing = Facing; //Dirección conservada durante el martillazo
OnGround = false; //Indica si el jugador está en el suelo

//Duración y contador del coyote tume
CoyoteFrames = 6;
CoyoteTimer = 0;

//Duración y contador del buffer de salto
JumpBufferFrames = 6;
JumpBufferTimer = 0;

//Proporción de impulso conservado al interrumpir el salto
JumpCutMultiplier = 0.4;

//Vida
MaxHp = 4;
Hp = MaxHp;

//Duración del daño
HurtFrames = 18;
HurtTimer = 0;

//Invulnerabilidad después de recibir daño
InvulnerabilityFrames = 90;
InvulnerabilityTimer = 0;

//Retroceso
KnockbackHSpeed = 2;
KnockbackVSpeed = 1.5;

//Muerte
DeathFrames = 45;
DeathTimer = 0;

//Duración de las fases del martillazo
HammerStartupFrames = 4;
HammerActiveFrames = 5;
HammerRecoveryFrames = 7;

//Control del martillazo actual
HammerTimer = 0;
HammerAttackId = 0;
HammerActive = false;

//Dimensiones de la hitbox
HammerRange = 14;

//Coordenadas actuales de la hitbox
HammerHitLeft = 0;
HammerHitTop = 0;
HammerHitRight = 0;
HammerHitBottom = 0;

//Lista temporal de enemigos alcanzados
HammerHitList = ds_list_create();
//Mostrar la hitbox del martillo durante las pruebas
ShowHammerHitbox = true;


//Sprite y fotograma independientes del torso atacante
HammerUpperSprite = sprPlayerHammerUpper;
HammerUpperFrame = 0;

//Enemigo actualmente sujeto
CarriedEnemy = noone;

//Alcance para recoger desde los lados
PickupRange = 10;

//Diferencia vertical permitida entre los pies
PickupHeight = 8;

//Posición visual del enemigo respecto a Rudolph
CarryOffsetX = 10;
CarryOffsetY = -16;

//Parte superior correspondiente a la locomoción
MoveUpperSprite = sprPlayerIdleUpper; //Sprite superior que corresponde a la locomoción actual

//Reemplazo visual temporal de la parte superior
UpperOverrideSprite = -1; //Sprite que reemplaza temporalmente al superior; -1 significa que no hay reemplazo
UpperOverrideFrame = 0; //Fotograma del reemplazo superior

//Inicializar la locomoción visible
sprite_index = sprPlayerIdleLower; //Sprite inferior de locomoción
image_index = 0; //Fotograma de locomoción compartido por ambas partes
image_speed = 1;

//Estados lógicos y visual del jugador
ActionState = PLAYER_ACTION_STATE.NORMAL;
AnimationState = PLAYER_ANIMATION_STATE.IDLE;

//Soltar al enemigo sin lanzarlo
DropCarriedEnemy = function()
{
    var Enemy = CarriedEnemy;

    CarriedEnemy = noone;

    if (!instance_exists(Enemy))
    {
        return;
    }

    if (Enemy.Carrier != id)
    {
        return;
    }

    Enemy.ChangeState(ENEMY_STATE.FLATTENED);
};

//Aplica daño y devuelve si el golpe fue aceptado
TakeDamage = function(DamageAmount, SourceX)
{
    if (ActionState == PLAYER_ACTION_STATE.DEAD)
    {
        return false;
    }

    if (InvulnerabilityTimer > 0)
    {
        return false;
    }

    //Soltar solo si el daño fue aceptado
    DropCarriedEnemy();
    
    Hp = max(
        Hp - DamageAmount,
        0
    );

    var KnockbackDirection = sign(
        x - SourceX
    );

    if (KnockbackDirection == 0)
    {
        KnockbackDirection = -Facing;
    }

    HSpeed =
        KnockbackHSpeed
        * KnockbackDirection;

    VSpeed = -KnockbackVSpeed;

    HSubPixel = 0;
    VSubPixel = 0;

    AirMaxSpeed = max(
        AirMaxSpeed,
        abs(HSpeed)
    );

    OnGround = false;
    CoyoteTimer = 0;
    JumpBufferTimer = 0;

    if (Hp <= 0)
    {
        ActionState =
            PLAYER_ACTION_STATE.DEAD;

        DeathTimer = DeathFrames;
    }
    else
    {
        ActionState =
            PLAYER_ACTION_STATE.HURT;

        HurtTimer = HurtFrames;

        InvulnerabilityTimer =
            InvulnerabilityFrames;
    }

    return true;
};

//Inicia un nuevo martillazo
StartHammerAttack = function()
{
    if (ActionState != PLAYER_ACTION_STATE.NORMAL)
    {
        return false;
    }
    
    //No utilizar el martillo mientras carga un enemigo
    if (instance_exists(CarriedEnemy))
    {
        return false;
    }

    //Guardar la dirección del ataque
    HammerFacing = Facing;
    ActionState = PLAYER_ACTION_STATE.HAMMER;

    HammerTimer = 0;
    HammerActive = false;
    HammerUpperFrame = 0;

    HammerAttackId += 1;

    return true;
};

//Calcula la zona de impacto del martillo
UpdateHammerHitbox = function()
{
    HammerHitTop = bbox_top + 2;
    HammerHitBottom = bbox_bottom + 2;

    if (HammerFacing > 0)
    {
        HammerHitLeft = bbox_right - 2;
        HammerHitRight = bbox_right + HammerRange;
    }
    else
    {
        HammerHitLeft = bbox_left - HammerRange;
        HammerHitRight = bbox_left + 2;
    }
};

//Golpea todos los enemigos dentro de la hitbox
PerformHammerHit = function()
{
    ds_list_clear(HammerHitList);

    var HitCount = collision_rectangle_list(
        HammerHitLeft,
        HammerHitTop,
        HammerHitRight,
        HammerHitBottom,
        objEnemy,
        false,
        true,
        HammerHitList,
        false
    );

    for (var i = 0; i < HitCount; i += 1)
    {
        var Enemy = HammerHitList[| i];

        if (instance_exists(Enemy))
        {
            Enemy.ReceiveHammerHit(
                HammerAttackId,
                id
            );
        }
    }
};

//Actualiza las fases del martillazo
UpdateHammerAttack = function()
{
    HammerActive = false;

    if (ActionState != PLAYER_ACTION_STATE.HAMMER)
    {
        return;
    }

    HammerTimer += 1;

    var ActiveStart =
        HammerStartupFrames;

    var ActiveEnd =
        HammerStartupFrames
        + HammerActiveFrames;

    var AttackEnd =
        HammerStartupFrames
        + HammerActiveFrames
        + HammerRecoveryFrames;
    
    //Sincronizar el torso con la duración del ataque
    var HammerFrameCount =
        sprite_get_number(HammerUpperSprite);
    
    HammerUpperFrame = min(
        floor(
            (max(HammerTimer - 1, 0) / AttackEnd)
            * HammerFrameCount
        ),
        HammerFrameCount - 1
    );

    //Activar la hitbox
    if (
        HammerTimer > ActiveStart
        && HammerTimer <= ActiveEnd
    )
    {
        HammerActive = true;

        UpdateHammerHitbox();
        PerformHammerHit();
    }

    //Terminar el ataque
    if (HammerTimer >= AttackEnd)
    {
        HammerTimer = 0;
        HammerActive = false;

        ActionState =
            PLAYER_ACTION_STATE.NORMAL;
    }
};

//Recoger el enemigo válido más cercano
TryPickupEnemy = function()
{
    if (ActionState != PLAYER_ACTION_STATE.NORMAL)
    {
        return false;
    }

    if (instance_exists(CarriedEnemy))
    {
        return false;
    }

    CarriedEnemy = noone;

    var BestEnemy = noone;
    var BestDistance = 1000000;

    var EnemyCount = instance_number(objEnemy);

    for (var Index = 0; Index < EnemyCount; Index += 1)
    {
        var Enemy = instance_find(objEnemy, Index);

        if (!instance_exists(Enemy))
        {
            continue;
        }

        if (!Enemy.CanBeCarried || Enemy.Carrier != noone)
        {
            continue;
        }

        var ValidState =
            Enemy.EnemyState == ENEMY_STATE.FLATTENED
            || Enemy.EnemyState == ENEMY_STATE.WAKING;

        if (!ValidState)
        {
            continue;
        }

        //Comprobar el suelo en este momento
        if (!Enemy.HasGround())
        {
            continue;
        }

        var GapX = max(
            0,
            max(
                Enemy.bbox_left - bbox_right,
                bbox_left - Enemy.bbox_right
            )
        );

        var GapY = abs(Enemy.bbox_bottom - bbox_bottom);

        if (GapX > PickupRange || GapY > PickupHeight)
        {
            continue;
        }

        var Distance = abs(Enemy.x - x);

        if (Distance < BestDistance)
        {
            BestDistance = Distance;
            BestEnemy = Enemy;
        }
    }

    if (!instance_exists(BestEnemy))
    {
        return false;
    }

    CarriedEnemy = BestEnemy;
    BestEnemy.Carrier = id;

    BestEnemy.ChangeState(ENEMY_STATE.CARRIED);

    return true;
};