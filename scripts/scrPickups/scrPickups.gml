/// @description Recoge los ítems que tocan la máscara de la instancia

function CollectPickups(Player, ByThrown)
{
    if (!instance_exists(Player))
    {
        return;
    }

    if (Player.ActionState == PLAYER_ACTION_STATE.DEAD)
    {
        return;
    }

    //Preparar una lista independiente de las instancias actuales
    var PickupList = [];

    with (objPickup)
    {
        array_push(PickupList, id);
    }

    //Comprobar cada recogible con la máscara de quien llama
    var PickupCount = array_length(PickupList);

    for (var Index = 0; Index < PickupCount; Index += 1)
    {
        var Pickup = PickupList[Index];

        if (!instance_exists(Pickup))
        {
            continue;
        }

        if (Pickup.Collected)
        {
            continue;
        }

        if (ByThrown && !Pickup.CanCollectByThrown)
        {
            continue;
        }

        if (instance_place(x, y, Pickup) != noone)
        {
            Pickup.TryCollect(Player, ByThrown);
        }
    }
}