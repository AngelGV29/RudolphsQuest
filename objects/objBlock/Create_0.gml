/// @description Inicializa las interacciones comunes de los bloques

mask_index = sprBlockMask;

LastHammerOwner = noone;
LastHammerAttackId = -1;

BumpSpeed = 2; //Impulso para enemigos encima
PickupBumpSpeed = 2; //Impulso para recogibles con físicas encima

//Cada hijo define qué ocurre al aceptar un golpe
ActivateBlock = function(Attacker, HitType)
{
    return false;
};

//Validar la dirección y evitar martillazos repetidos
ReceiveBlockHit = function(Attacker, HitType, AttackId)
{
    if (!instance_exists(Attacker))
    {
        return false;
    }

    if (HitType == BLOCK_HIT.HAMMER)
    {
        //El cuerpo debe aproximarse desde un lateral
        var SideHit =
            Attacker.bbox_right <= bbox_left + 2
            || Attacker.bbox_left >= bbox_right - 2;

        var VerticalOverlap =
            Attacker.bbox_bottom > bbox_top
            && Attacker.bbox_top < bbox_bottom;

        if (!SideHit || !VerticalOverlap)
        {
            return false;
        }

        if (
            LastHammerOwner == Attacker
            && LastHammerAttackId == AttackId
        )
        {
            return false;
        }

        LastHammerOwner = Attacker;
        LastHammerAttackId = AttackId;
    }

    return ActivateBlock(Attacker, HitType);
};

//Notificar a los enemigos apoyados encima
BumpEnemies = function()
{
    var Enemies = [];

    with (objEnemy)
    {
        array_push(Enemies, id);
    }

    for (
        var Index = 0;
        Index < array_length(Enemies);
        Index += 1
    )
    {
        var Enemy = Enemies[Index];

        if (!instance_exists(Enemy))
        {
            continue;
        }

        if (
            Enemy.RemovedFromLevel
            || Enemy.Carrier != noone
            || Enemy.EnemyState == ENEMY_STATE.THROWN
            || Enemy.EnemyState == ENEMY_STATE.DEFEATED
        )
        {
            continue;
        }
        
        //Permitir reacciones de proximidad, aunque no esté apoyado
        Enemy.ReceiveBlockAlert(id);

        var OverlapX =
            Enemy.bbox_right >= bbox_left
            && Enemy.bbox_left <= bbox_right;

        var FeetGap = bbox_top - Enemy.bbox_bottom;

        var RestingAbove =
            FeetGap >= -1
            && FeetGap <= 2
            && Enemy.VSpeed >= 0;

        if (OverlapX && RestingAbove)
        {
            Enemy.ReceiveBlockBump(BumpSpeed);
        }
    }
};

//Impulsar únicamente recogibles con física
BumpPickups = function()
{
    var Pickups = [];

    with (objPickupPhysical)
    {
        array_push(Pickups, id);
    }

    for (
        var Index = 0;
        Index < array_length(Pickups);
        Index += 1
    )
    {
        var Pickup = Pickups[Index];

        if (!instance_exists(Pickup))
        {
            continue;
        }

        if (Pickup.Collected)
        {
            continue;
        }

        var OverlapX =
            Pickup.bbox_right >= bbox_left
            && Pickup.bbox_left <= bbox_right;

        var FeetGap = bbox_top - Pickup.bbox_bottom;

        var RestingAbove =
            FeetGap >= -1
            && FeetGap <= 2
            && Pickup.VSpeed >= 0;

        if (OverlapX && RestingAbove)
        {
            Pickup.ReceiveBlockBump(
                PickupBumpSpeed
            );
        }
    }
};