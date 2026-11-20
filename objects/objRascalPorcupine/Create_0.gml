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
BlockActive = false;

//Iniciar o reiniciar la defensa temporal
StartBlockReaction = function()
{
    BlockTimer = BlockFrames;
    BlockActive = true;

    HSpeed = 0;
    HSubPixel = 0;

    sprite_index = StateSpriteBlock;
    mask_index = StateMaskNormal;

    image_index = 0;
    image_speed = 1;
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
//Patrullar o permanecer temporalmente a la defensiva
UpdateNormalState = function()
{
    if (BlockActive)
    {
        HSpeed = 0;
        HSubPixel = 0;

        BlockTimer = max(BlockTimer - 1, 0);

        if (BlockTimer > 0)
        {
            return;
        }

        //Restaurar la apariencia una sola vez al terminar
        BlockActive = false;

        sprite_index = StateSpriteNormal;
        mask_index = StateMaskNormal;

        image_index = 0;
        image_speed = 0;
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