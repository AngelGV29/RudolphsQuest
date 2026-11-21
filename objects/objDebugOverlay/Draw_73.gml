/// @description Dibuja las regiones de depuración del mundo

var Debug = id;

var PreviousColor = draw_get_color();
var PreviousAlpha = draw_get_alpha();

//Jugador y sus áreas de interacción
with (objPlayer)
{
    if (Debug.ShowPlayer)
    {
        Debug.DrawBox(
            bbox_left,
            bbox_top,
            bbox_right,
            bbox_bottom,
            c_aqua
        );
    }

    if (
        Debug.ShowHammer
        && ActionState != PLAYER_ACTION_STATE.DEAD
    )
    {
        var HitLeft;
        var HitRight;

        var HitBottom = bbox_bottom + HammerOffsetY;
        
        var HitTop =
            HitBottom
            - max(1, HammerHeight);

        var AttackFacing = Facing;

        if (ActionState == PLAYER_ACTION_STATE.HAMMER)
        {
            AttackFacing = HammerFacing;
        }

        //Previsualizar el alcance aunque no esté atacando
        if (AttackFacing > 0)
        {
            HitLeft = bbox_right - 2;
            HitRight = bbox_right + HammerRange;
        }
        else
        {
            HitLeft = bbox_left - HammerRange;
            HitRight = bbox_left + 2;
        }

        var HitColor = c_orange;

        if (HammerActive)
        {
            //Mostrar la región registrada por el ataque real
            HitLeft = HammerHitLeft;
            HitTop = HammerHitTop;
            HitRight = HammerHitRight;
            HitBottom = HammerHitBottom;

            HitColor = c_red;
        }

        Debug.DrawBox(
            HitLeft,
            HitTop,
            HitRight,
            HitBottom,
            HitColor
        );
    }

    if (Debug.ShowPickupArea)
    {
        Debug.DrawBox(
            bbox_left - PickupRange,
            bbox_bottom - PickupHeight,
            bbox_right + PickupRange,
            bbox_bottom + PickupHeight,
            c_lime
        );
    }
}

//Todos los enemigos y sus descendientes
if (ShowEnemies)
{
    with (objEnemy)
    {
        if (!RemovedFromLevel)
        {
            Debug.DrawBox(
                bbox_left,
                bbox_top,
                bbox_right,
                bbox_bottom,
                c_fuchsia
            );
        }
    }
}

//Todos los recogibles y sus descendientes
if (ShowPickups)
{
    with (objPickup)
    {
        if (!Collected)
        {
            Debug.DrawBox(
                bbox_left,
                bbox_top,
                bbox_right,
                bbox_bottom,
                c_yellow
            );
        }
    }
}

//Todos los proyectiles y sus descendientes
if (ShowProjectiles)
{
    with (objProjectile)
    {
        Debug.DrawBox(
            bbox_left,
            bbox_top,
            bbox_right,
            bbox_bottom,
            c_blue
        );
    }
}

draw_set_color(PreviousColor);
draw_set_alpha(PreviousAlpha);