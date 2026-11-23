/// @description Inicializa el comportamiento del puercoespín malandrín

//Inicializar propiedades heredadas
event_inherited();

//Impedir que el martillo lo aplaste o que pueda cargarse
CanBeFlattened = false;
CanBeCarried = false;

//Permitir que solo un enemigo lanzado pueda derrotarlo
CanBeHitByThrown = true;
DropsDiamond = true;

//Recursos de cada estado heredado
StateSpriteNormal = sprRascalPorcupinePlaceholder;
StateMaskNormal = sprRascalPorcupineMask;
StateAnimSpeedNormal = 1;

StateSpriteFlattened = sprRascalPorcupineFlattenedPlaceholder;
StateMaskFlattened = sprRascalPorcupineFlattenedMask;

StateSpriteWaking = sprRascalPorcupineWakingPlaceholder;

//Recurso temporal para resistir el martillazo
StateSpriteBlock = sprRascalPorcupineBlock;

//Efecto visual de derrota por proyectil
DefeatSprite = sprRascalPorcupineDefeated;
DefeatFrames = 18;

//Propiedades del puercoespín
ContactDamage = 1;
MoveSpeed = 0.50;

UsesGravity = true;
Gravity = 0.16;
MaxFallSpeed = 5.90;
Facing = -1;

//Tiempo manteniendo la pose de protección
BlockFrames = 90;
BlockTimer = 0;

BlockActive = false;

//Duración de la entrada y salida, en pasos
BlockEnterFrames = 18;
BlockReleaseFrames = 18;

//Control de la fase visual
BlockPhase = PORCUPINE_BLOCK_PHASE.ENTER;
BlockPhaseTimer = 0;

//Iniciar la protección o renovar la que ya está activa
StartBlockReaction = function()
{
    BlockTimer = max(1, floor(BlockFrames));

    HSpeed = 0;
    HSubPixel = 0;

    if (BlockActive)
    {
        //Si estaba saliendo, recuperar directamente la pose protegida
        if (BlockPhase == PORCUPINE_BLOCK_PHASE.EXIT)
        {
            BlockPhase = PORCUPINE_BLOCK_PHASE.HOLD;
            BlockPhaseTimer = 0;

            image_index = max(
                0,
                sprite_get_number(StateSpriteBlock) - 1
            );

            image_speed = 0;
        }

        //No reiniciar la entrada ni la pose que ya mantiene
        return;
    }

    BlockActive = true;

    BlockPhase = PORCUPINE_BLOCK_PHASE.ENTER;
    BlockPhaseTimer = 0;

    sprite_index = StateSpriteBlock;
    mask_index = StateMaskNormal;

    image_index = 0;
    image_speed = 0;
};

//Comprobar si hay suelo delante antes de avanzar
HasGroundAhead = function()
{
    //Avanzar una máscara completa para no detectar el suelo detrás
    var ProbeDistance = max(
        abs(bbox_right - x),
        abs(x - bbox_left)
    ) + 1;

    var ProbeX = x + ProbeDistance * Facing;

    if (CheckSolid(ProbeX, y + 1))
    {
        return true;
    }

    //Los semisólidos también permiten continuar la patrulla
    if (VSpeed >= 0 && CheckSemi(ProbeX, y + 1))
    {
        return true;
    }

    return false;
};

//Avanzar constantemente y regresar antes de caer de un borde
//Patrullar o actualizar las fases de protección
UpdateNormalState = function()
{
    if (BlockActive)
    {
        HSpeed = 0;
        HSubPixel = 0;

        var FrameCount = max(
            1,
            sprite_get_number(StateSpriteBlock)
        );

        var LastFrame = FrameCount - 1;

        image_speed = 0;

        switch (BlockPhase)
        {
            case PORCUPINE_BLOCK_PHASE.ENTER:
                var EnterDuration = max(
                    1,
                    floor(BlockEnterFrames)
                );

                if (BlockPhaseTimer >= EnterDuration)
                {
                    BlockPhase = PORCUPINE_BLOCK_PHASE.HOLD;
                    BlockPhaseTimer = 0;

                    image_index = LastFrame;

                    return;
                }

                image_index = min(
                    LastFrame,
                    floor(
                        BlockPhaseTimer
                        * FrameCount
                        / EnterDuration
                    )
                );

                BlockPhaseTimer += 1;

                return;

            case PORCUPINE_BLOCK_PHASE.HOLD:
                image_index = LastFrame;

                BlockTimer = max(
                    BlockTimer - 1,
                    0
                );

                if (BlockTimer == 0)
                {
                    BlockPhase = PORCUPINE_BLOCK_PHASE.EXIT;
                    BlockPhaseTimer = 0;
                }

                return;

            case PORCUPINE_BLOCK_PHASE.EXIT:
                var ExitDuration = max(
                    1,
                    floor(BlockReleaseFrames)
                );

                if (BlockPhaseTimer < ExitDuration)
                {
                    var ReverseOffset = min(
                        LastFrame,
                        floor(
                            BlockPhaseTimer
                            * FrameCount
                            / ExitDuration
                        )
                    );

                    image_index = LastFrame - ReverseOffset;

                    BlockPhaseTimer += 1;

                    return;
                }

                //Volver a la animación normal
                BlockActive = false;

                sprite_index = StateSpriteNormal;
                mask_index = StateMaskNormal;

                image_index = 0;
                image_speed = StateAnimSpeedNormal;

                break;
        }
    }

    //Invertir el sentido cuando no exista suelo por delante
    if (!HasGroundAhead())
    {
        Facing *= -1;

        HSpeed = 0;
        HSubPixel = 0;

        return;
    }

    HSpeed = MoveSpeed * Facing;
};

//Girar al tocar una pared
OnWallHit = function()
{
    Facing *= -1;
    HSpeed = 0;
};

//Resistir el martillazo sin cambiar al estado aplastado
ReceiveHammerHit = function(AttackId, Attacker)
{
    if (RemovedFromLevel || Carrier != noone)
    {
        return false;
    }

    if (LastHammerAttackId == AttackId)
    {
        return false;
    }

    LastHammerAttackId = AttackId;

    if (EnemyState != ENEMY_STATE.NORMAL)
    {
        return false;
    }

    StartBlockReaction();

    return true;
};

//Girar si dañó al jugador desde atrás
OnPlayerDamaged = function(Player, PlayerSide)
{
    var HitFromBehind =
        PlayerSide == -Facing;

    if (HitFromBehind)
    {
        Facing = PlayerSide;

        HSpeed =
            MoveSpeed
            * Facing;

        image_xscale = Facing;
    }
};

//Rebotar y erizarse sin quedar aplastado
ReceiveBlockBump = function(Impulse)
{
    if (
        RemovedFromLevel
        || Carrier != noone
        || EnemyState != ENEMY_STATE.NORMAL
    )
    {
        return false;
    }

    StartBlockReaction();

    VSpeed = -abs(Impulse);
    VSubPixel = 0;
    OnGround = false;

    return true;
};

//Aplicar los recursos y la animación del estado inicial
OnStateEnter(EnemyState);