/// @description Inicializa el murciélago chupavida

event_inherited();

//Interacciones heredadas
CanBeFlattened = true;
CanBeCarried = true;
CanBeHitByThrown = true;

DropsDiamond = true;

ContactDamage = 1;
MoveSpeed = 0;

//Recursos de los estados generales
StateSpriteNormal = sprLifeLeechBatIdle;
StateMaskNormal = sprLifeLeechBatMask;
StateAnimSpeedNormal = 0;

StateSpriteFlattened = sprLifeLeechBatFlattened;
StateMaskFlattened = sprLifeLeechBatFlattenedMask;

StateSpriteWaking = sprLifeLeechBatWaking;

DefeatSprite = sprLifeLeechBatDefeated;
DefeatFrames = 18;

//Protección al recuperar colisiones dentro del terreno
ResolveOnFlattened = true;

//Detección
VisionRadius = 128;
//Distancia a un bloque activado que puede alertarlo
BlockAlertRadius = 16;

//Preparación: distancia y duración del descenso
DropDistance = 12;
DropFrames = 18;
DropTimer = 0;

//Velocidad del vuelo
FlightSpeed = 2;
FlightHSpeed = 0;
FlightVSpeed = 0;

//Recursos visuales de las fases
PrepareSprite = sprLifeLeechBatPrepare;
FlySprite = sprLifeLeechBatFly;

PrepareAnimSpeed = 1;
FlyAnimSpeed = 1;

BatPhase = BAT_PHASE.WAIT;

//Conservar la entrada a estados del enemigo base
BaseStateEnter = OnStateEnter;

//Ampliar la configuración de cada estado
OnStateEnter = function(NewState)
{
    IgnoresTerrain =
        NewState == ENEMY_STATE.NORMAL;

    UsesGravity = !IgnoresTerrain;

    BaseStateEnter(NewState);

    if (NewState == ENEMY_STATE.NORMAL)
    {
        BatPhase = BAT_PHASE.WAIT;

        DropTimer = 0;

        FlightHSpeed = 0;
        FlightVSpeed = 0;

        HSpeed = 0;
        VSpeed = 0;

        HSubPixel = 0;
        VSubPixel = 0;

        OnGround = false;

        TerrainRecoveryFailed = false;
    }
    else if (NewState == ENEMY_STATE.FLATTENED)
    {
        //Cancelar por completo la trayectoria de vuelo
        HSpeed = 0;
        VSpeed = 0;

        HSubPixel = 0;
        VSubPixel = 0;
    }
};

//Comenzar la preparación descendente
StartDrop = function()
{
    BatPhase = BAT_PHASE.DROP;
    DropTimer = 0;

    HSpeed = 0;
    VSpeed = 0;

    HSubPixel = 0;
    VSubPixel = 0;

    sprite_index = PrepareSprite;
    image_index = 0;
    image_speed = PrepareAnimSpeed;
};

//Calcular una única trayectoria hacia el jugador
StartFlight = function(Player)
{
    var StartX = (bbox_left + bbox_right) * 0.5;
    var StartY = (bbox_top + bbox_bottom) * 0.5;

    var TargetX =
        (Player.bbox_left + Player.bbox_right) * 0.5;

    var TargetY =
        (Player.bbox_top + Player.bbox_bottom) * 0.5;

    var Distance = point_distance(
        StartX,
        StartY,
        TargetX,
        TargetY
    );

    var FlightDir;

    if (Distance > 0)
    {
        FlightDir = point_direction(
            StartX,
            StartY,
            TargetX,
            TargetY
        );
    }
    else
    {
        //Dirección de respaldo si ambos centros coinciden
        FlightDir = 0;

        if (Facing < 0)
        {
            FlightDir = 180;
        }
    }

    FlightHSpeed = lengthdir_x(
        FlightSpeed,
        FlightDir
    );

    FlightVSpeed = lengthdir_y(
        FlightSpeed,
        FlightDir
    );

    if (FlightHSpeed != 0)
    {
        Facing = sign(FlightHSpeed);
    }

    HSubPixel = 0;
    VSubPixel = 0;

    HSpeed = FlightHSpeed;
    VSpeed = FlightVSpeed;

    BatPhase = BAT_PHASE.FLY;

    sprite_index = FlySprite;
    image_index = 0;
    image_speed = FlyAnimSpeed;
};

//Actualizar únicamente el comportamiento normal
UpdateNormalState = function()
{
    //Una vez iniciado el vuelo, no volver a consultar el objetivo
    if (BatPhase == BAT_PHASE.FLY)
    {
        HSpeed = FlightHSpeed;
        VSpeed = FlightVSpeed;
        return;
    }

    var Player = instance_find(objPlayer, 0);

    if (!instance_exists(Player))
    {
        HSpeed = 0;
        VSpeed = 0;
        return;
    }

    if (Player.ActionState == PLAYER_ACTION_STATE.DEAD)
    {
        HSpeed = 0;
        VSpeed = 0;
        return;
    }

    switch (BatPhase)
    {
        case BAT_PHASE.WAIT:
            HSpeed = 0;
            VSpeed = 0;

            var CenterX =
                (bbox_left + bbox_right) * 0.5;

            var CenterY =
                (bbox_top + bbox_bottom) * 0.5;

            var PlayerX =
                (Player.bbox_left + Player.bbox_right) * 0.5;

            var PlayerY =
                (Player.bbox_top + Player.bbox_bottom) * 0.5;

            if (
                point_distance(
                    CenterX,
                    CenterY,
                    PlayerX,
                    PlayerY
                ) <= VisionRadius
            )
            {
                var LookDir = sign(PlayerX - CenterX);

                if (LookDir != 0)
                {
                    Facing = LookDir;
                }

                StartDrop();
            }
            break;

        case BAT_PHASE.DROP:
            var Duration = max(
                1,
                floor(DropFrames)
            );

            if (DropTimer >= Duration)
            {
                //El objetivo se consulta al terminar el descenso
                StartFlight(Player);
                break;
            }

            HSpeed = 0;

            VSpeed =
                max(0, DropDistance)
                / Duration;

            DropTimer += 1;
            break;
    }
};

//Conservar la reacción física del enemigo base
BaseBlockBump = ReceiveBlockBump;

//Reaccionar al bloque únicamente en estados físicos vulnerables
ReceiveBlockBump = function(Impulse)
{
    var CanReact =
        EnemyState == ENEMY_STATE.FLATTENED
        || EnemyState == ENEMY_STATE.WAKING;

    if (!CanReact)
    {
        return false;
    }

    return BaseBlockBump(Impulse);
};

//Abandonar la espera cuando se activa un bloque cercano
ReceiveBlockAlert = function(Block)
{
    if (
        RemovedFromLevel
        || Carrier != noone
        || EnemyState != ENEMY_STATE.NORMAL
        || BatPhase != BAT_PHASE.WAIT
    )
    {
        return false;
    }

    if (!instance_exists(Block))
    {
        return false;
    }

    var Player = instance_find(objPlayer, 0);

    if (!instance_exists(Player))
    {
        return false;
    }

    if (Player.ActionState == PLAYER_ACTION_STATE.DEAD)
    {
        return false;
    }

    var CenterX = (bbox_left + bbox_right) * 0.5;
    var CenterY = (bbox_top + bbox_bottom) * 0.5;

    //Buscar el punto del bloque más cercano al murciélago
    var ClosestX = clamp(
        CenterX,
        Block.bbox_left,
        Block.bbox_right
    );

    var ClosestY = clamp(
        CenterY,
        Block.bbox_top,
        Block.bbox_bottom
    );

    if (
        point_distance(
            CenterX,
            CenterY,
            ClosestX,
            ClosestY
        ) > BlockAlertRadius
    )
    {
        return false;
    }

    var LookDir = sign(Player.x - x);

    if (LookDir != 0)
    {
        Facing = LookDir;
    }

    image_xscale = Facing;

    StartDrop();

    return true;
};

//No cambiar la trayectoria al dañar al jugador
OnPlayerDamaged = function(Player, PlayerSide)
{
};

//Conservar las transiciones del enemigo base
BaseChangeState = ChangeState;

//Prepararse inmediatamente después de terminar de despertar
ChangeState = function(NewState)
{
    var PreviousState = EnemyState;

    var Changed = BaseChangeState(NewState);

    if (
        Changed
        && !RemovedFromLevel
        && !TerrainRecoveryFailed
        && PreviousState == ENEMY_STATE.WAKING
        && NewState == ENEMY_STATE.NORMAL
    )
    {
        StartDrop();
    }

    return Changed;
};

//Aplicar la configuración inicial
OnStateEnter(EnemyState);