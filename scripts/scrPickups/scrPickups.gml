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

/// @description Comprueba sólidos usando la máscara de una instancia

function CheckInstanceSolid(Target, CheckX, CheckY)
{
    //Una referencia inválida no representa una posición utilizable
    if (!instance_exists(Target))
    {
        return true;
    }

    var Blocked = false;

    with (Target)
    {
        Blocked = CheckSolid(CheckX, CheckY);
    }

    return Blocked;
}

/// @description Recoloca una instancia en la posición libre más cercana

function ResolveSolidOverlap(Target, MaxDistance)
{
    if (!instance_exists(Target))
    {
        return false;
    }

    var StartX = Target.x;
    var StartY = Target.y;

    //No modificar una instancia que ya está libre
    if (!CheckInstanceSolid(Target, StartX, StartY))
    {
        return true;
    }

    var SearchRadius = max(0, floor(MaxDistance));
    var MaxDistanceSquared = SearchRadius * SearchRadius;

    var Found = false;

    var BestX = StartX;
    var BestY = StartY;
    var BestDistanceSquared = MaxDistanceSquared + 1;

    //Examinar desplazamientos en todas las direcciones
    for (
        var OffsetY = -SearchRadius;
        OffsetY <= SearchRadius;
        OffsetY += 1
    )
    {
        for (
            var OffsetX = -SearchRadius;
            OffsetX <= SearchRadius;
            OffsetX += 1
        )
        {
            var DistanceSquared =
                OffsetX * OffsetX
                + OffsetY * OffsetY;

            //Limitar la búsqueda a un radio circular
            if (DistanceSquared > MaxDistanceSquared)
            {
                continue;
            }

            //No comprobar candidatos peores que el encontrado
            if (DistanceSquared >= BestDistanceSquared)
            {
                continue;
            }

            var CheckX = StartX + OffsetX;
            var CheckY = StartY + OffsetY;

            if (!CheckInstanceSolid(Target, CheckX, CheckY))
            {
                Found = true;

                BestX = CheckX;
                BestY = CheckY;
                BestDistanceSquared = DistanceSquared;
            }
        }
    }

    if (!Found)
    {
        return false;
    }

    Target.x = BestX;
    Target.y = BestY;

    return true;
}