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

//Duración y contador de la defensa contra el martillo
BlockFrames = 90;
BlockTimer = 0;

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
UpdateNormalState = function()
{
    //Mantenerse inmóvil y mostrar la defensa durante el impacto
    if (BlockTimer > 0)
    {
        BlockTimer -= 1;

        HSpeed = 0;
        HSubPixel = 0;

        sprite_index = StateSpriteBlock;
        mask_index = StateMaskNormal;

        image_index = 0;
        image_speed = 0;
        return;
    }

    //Recuperar el aspecto normal al terminar de bloquear
    sprite_index = StateSpriteNormal;
    mask_index = StateMaskNormal;

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
    //No procesar golpes después de retirarse ni mientras está sujeto
    if (RemovedFromLevel || Carrier != noone)
    {
        return false;
    }

    //Evitar que el mismo martillazo reinicie la defensa
    if (LastHammerAttackId == AttackId)
    {
        return false;
    }

    LastHammerAttackId = AttackId;

    //Solo bloquear en la patrulla; los proyectiles conservan prioridad
    if (EnemyState != ENEMY_STATE.NORMAL)
    {
        return false;
    }

    //Cancelar de inmediato el movimiento acumulado y actual
    HSpeed = 0;
    HSubPixel = 0;

    //Mostrar la defensa durante un breve instante
    BlockTimer = BlockFrames;
    sprite_index = StateSpriteBlock;
    mask_index = StateMaskNormal;

    image_index = 0;
    image_speed = 0;

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
