/// @description Inicializa un bloque con contenido configurable

event_inherited();

//Conservar la configuración del editor o utilizar valores de respaldo
if (!variable_instance_exists(id, "ContentObject"))
{
    ContentObject = objCoin;
}

if (!variable_instance_exists(id, "ContentCount"))
{
    ContentCount = 1;
}

if (!variable_instance_exists(id, "ReleaseFrame"))
{
    ReleaseFrame = 1;
}

if (!variable_instance_exists(id, "ActiveFrames"))
{
    ActiveFrames = 16;
}

BlockState = BLOCK_STATE.READY;

RemainingCount = max(0, floor(ContentCount));

ActiveTimer = 0;
EffectReleased = false;
RewardPlayer = noone;

image_speed = 0;

//Actualizar el aspecto estable del bloque
SetRestSprite = function()
{
    if (RemainingCount > 0)
    {
        BlockState = BLOCK_STATE.READY;
        sprite_index = sprItemBlockIdle;
    }
    else
    {
        BlockState = BLOCK_STATE.EMPTY;
        sprite_index = sprItemBlockEmpty;
    }

    image_index = 0;
    image_speed = 0;
};

//Entregar una unidad de contenido
ReleaseContent = function()
{
    if (RemainingCount <= 0 || ContentObject == noone)
    {
        return false;
    }

    if (!object_exists(ContentObject))
    {
        return false;
    }

    //El contenido debe ser un recogible del sistema actual
    if (
        ContentObject != objPickup
        && !object_is_ancestor(ContentObject, objPickup)
    )
    {
        show_debug_message(
            "El contenido del bloque no deriva de objPickup."
        );

        return false;
    }

    var Drop = instance_create_layer(
        (bbox_left + bbox_right) * 0.5,
        bbox_top,
        layer,
        ContentObject
    );

    //Colocar el recogible inmediatamente encima del bloque
    Drop.y += bbox_top - 1 - Drop.bbox_bottom;

    var DirectReward =
        ContentObject == objCoin
        || ContentObject == objDiamond;

    if (DirectReward)
    {
        var RewardSprite = Drop.sprite_index;
        var RewardX = Drop.x;
        var RewardY = Drop.y;

        //Reutilizar recompensas y sonidos existentes
        var Granted = Drop.TryCollect(RewardPlayer, false);

        if (!Granted)
        {
            if (instance_exists(Drop))
            {
                instance_destroy(Drop);
            }

            return false;
        }

        if (RewardSprite != -1)
        {
            var Effect = instance_create_layer(
                RewardX,
                RewardY,
                layer,
                objBlockRewardEffect
            );

            Effect.sprite_index = RewardSprite;
        }
    }
    else
    {
        //Los corazones y demás recogibles físicos permanecen
        ResolveSolidOverlap(Drop, 32);
    }

    RemainingCount -= 1;

    return true;
};

//Comenzar una activación
ActivateBlock = function(Attacker, HitType)
{
    if (
        BlockState != BLOCK_STATE.READY
        || RemainingCount <= 0
    )
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

    RewardPlayer = Player;

    BlockState = BLOCK_STATE.ACTIVE;
    ActiveTimer = 0;
    EffectReleased = false;

    sprite_index = sprItemBlockActive;
    image_index = 0;
    image_speed = 0;

    return true;
};

SetRestSprite();