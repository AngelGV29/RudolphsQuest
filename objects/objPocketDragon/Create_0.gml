/// @description Inicializa el dragón de bolsillo

event_inherited();

//Interacciones heredadas
CanBeFlattened = true;
CanBeCarried = true;
CanBeHitByThrown = true;

DropsDiamond = true;

//Recursos de los estados
StateSpriteNormal = sprPocketDragonIdle;
StateMaskNormal = sprPocketDragonMask;
StateAnimSpeedNormal = 1;
//Multiplicador de la velocidad configurada en el sprite de preparación
FirePrepareAnimSpeed = 1;

StateSpriteFlattened = sprPocketDragonFlattened;
StateMaskFlattened = sprPocketDragonFlattenedMask;

StateSpriteWaking = sprPocketDragonWaking;

DefeatSprite = sprPocketDragonDefeated;
DefeatFrames = 18;

//Contacto y movimiento
ContactDamage = 1;
MoveSpeed = 0;

UsesGravity = true;
Gravity = 0.16;
MaxFallSpeed = 5.9;

//Espera antes de praparar un ataque
FireFrames = 210;
FireTimer = FireFrames;

FireSpeed = 2.5;
MouthOffsetY = -20;

//Duración de las fases, en pasos
FirePrepareFrames = 90;
FireSpitFrames = 30;

//Fotograma de la animación de escupir que libera el fuego
FireReleaseFrame = 1;

//Recursos visuales
FirePrepareSprite = sprPocketDragonPrepare;
FireSpitSprite = sprPocketDragonSpit;

//Control del ataque
FirePhase = DRAGON_FIRE_PHASE.WAIT;
FirePhaseTimer = 0;

FireReleased = false;

//Crear el proyectil mirando en la dirección actual
ShootFire = function()
{
    var ShotX;

    if (Facing > 0)
    {
        ShotX = bbox_right + 1;
    }
    else
    {
        ShotX = bbox_left - 1;
    }

    var ShotY = y + MouthOffsetY;

    var Shot = instance_create_layer(
        ShotX,
        ShotY,
        "Projectiles",
        objDragonFire
    );

    Shot.ProjectileOwner = id;

    Shot.Facing = Facing;
    Shot.image_xscale = Facing;

    Shot.HSpeed = FireSpeed * Facing;
    Shot.VSpeed = 0;
};

//Cancelar el ataque sin modificar el sprite de otro estado
ResetFireAttack = function()
{
    FirePhase = DRAGON_FIRE_PHASE.WAIT;
    FirePhaseTimer = 0;

    FireTimer = max(
        1,
        floor(FireFrames)
    );

    FireReleased = false;
};

//Cambiar la fase y seleccionar su animación
SetFirePhase = function(NewPhase)
{
    FirePhase = NewPhase;
    FirePhaseTimer = 0;

    switch (NewPhase)
    {
        case DRAGON_FIRE_PHASE.WAIT:
            sprite_index = StateSpriteNormal;
            image_index = 0;
            image_speed = StateAnimSpeedNormal;

            FireTimer = max(
                1,
                floor(FireFrames)
            );
            break;

        case DRAGON_FIRE_PHASE.PREPARE:
            sprite_index = FirePrepareSprite;
        
            image_index = 0;
            image_speed = FirePrepareAnimSpeed;
        
            FireReleased = false;
            break;

        case DRAGON_FIRE_PHASE.SPIT:
            sprite_index = FireSpitSprite;
            image_index = 0;
            image_speed = 0;

            FireReleased = false;
            break;
    }
};

//Distribuir la animación dentro de la duración de una fase
UpdateFireFrame = function(Duration)
{
    var FrameCount = max(
        1,
        sprite_get_number(sprite_index)
    );

    image_index = min(
        FrameCount - 1,
        floor(
            FirePhaseTimer
            * FrameCount
            / max(1, Duration)
        )
    );
};

//Permanecer inmóvil y actualizar el ataque de fuego
UpdateNormalState = function()
{
    HSpeed = 0;
    HSubPixel = 0;

    var Player = instance_find(objPlayer, 0);

    if (!instance_exists(Player))
    {
        SetFirePhase(DRAGON_FIRE_PHASE.WAIT);
        return;
    }

    //Seguir mirando al jugador durante todo el ataque
    var LookDir = sign(Player.x - x);

    if (LookDir != 0)
    {
        Facing = LookDir;
    }

    image_xscale = Facing;

    if (Player.ActionState == PLAYER_ACTION_STATE.DEAD)
    {
        SetFirePhase(DRAGON_FIRE_PHASE.WAIT);
        return;
    }

    switch (FirePhase)
    {
        case DRAGON_FIRE_PHASE.WAIT:
            FireTimer = max(
                FireTimer - 1,
                0
            );

            if (FireTimer == 0)
            {
                SetFirePhase(
                    DRAGON_FIRE_PHASE.PREPARE
                );
            }
            break;

        case DRAGON_FIRE_PHASE.PREPARE:
            var PrepareDuration = max(
                1,
                floor(FirePrepareFrames)
            );
        
            if (FirePhaseTimer >= PrepareDuration)
            {
                SetFirePhase(
                    DRAGON_FIRE_PHASE.SPIT
                );
        
                break;
            }
        
            //La animación avanza y se repite por su cuenta
            FirePhaseTimer += 1;
            break;

        case DRAGON_FIRE_PHASE.SPIT:
            var SpitDuration = max(
                1,
                floor(FireSpitFrames)
            );

            if (FirePhaseTimer >= SpitDuration)
            {
                SetFirePhase(
                    DRAGON_FIRE_PHASE.WAIT
                );
                break;
            }

            UpdateFireFrame(SpitDuration);

            var FrameCount = max(
                1,
                sprite_get_number(sprite_index)
            );

            var ReleaseFrame = clamp(
                floor(FireReleaseFrame),
                0,
                FrameCount - 1
            );

            if (
                !FireReleased
                && floor(image_index) >= ReleaseFrame
            )
            {
                FireReleased = true;

                ShootFire();
            }

            FirePhaseTimer += 1;
            break;
    }
};

//No girar por tocar una pared
OnWallHit = function()
{
    HSpeed = 0;
    HSubPixel = 0;
};

//Su orientación normal se calcula mirando al jugador
OnPlayerDamaged = function(Player, PlayerSide)
{
};

//Aplicar el estado inicial con los recursos del dragón
OnStateEnter(EnemyState);