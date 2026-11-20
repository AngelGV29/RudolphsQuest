/// @description Comprueba colisiones con sólidos de objetos y tiles

function CheckSolid(CheckX, CheckY)
{
    //Consultar la capa sólida de la habitación actual
    var SolidLayer = layer_get_id("CollisionSolid");

    if (SolidLayer != -1)
    {
        var SolidMap = layer_tilemap_get_id(SolidLayer);

        if (SolidMap != -1)
        {
            return place_meeting(
                CheckX,
                CheckY,
                [objSolid, SolidMap]
            );
        }
    }

    //Conservar compatibilidad con habitaciones sin tilemap
    return place_meeting(
        CheckX,
        CheckY,
        objSolid
    );
}

/// @description Comprueba el cruce descendente de una superficie semisólida

/// @description Comprueba el cruce descendente de una superficie semisólida

function CheckSemi(CheckX, CheckY)
{
    //No bloquear movimientos ascendentes ni horizontales
    if (CheckY <= y)
    {
        return false;
    }

    var SemiLayer = layer_get_id("CollisionSemi");

    if (SemiLayer == -1)
    {
        return false;
    }

    var SemiMap = layer_tilemap_get_id(SemiLayer);

    if (SemiMap == -1)
    {
        return false;
    }

    //Calcular el borde inferior actual y propuesto
    var OldBottom = bbox_bottom;
    var NewBottom = bbox_bottom + (CheckY - y);

    //Consultar el último píxel que ocuparía la máscara
    var TileSize = 16;
    var SampleY = NewBottom - 1;
    var SurfaceY = floor(SampleY / TileSize) * TileSize;

    //Permitir llegar a la superficie y bloquear al atravesarla
    if (
        OldBottom > SurfaceY
        || NewBottom <= SurfaceY
    )
    {
        return false;
    }

    //Consultar los píxeles interiores de la anchura propuesta
    var LeftX = bbox_left + (CheckX - x);
    var RightX = bbox_right + (CheckX - x) - 1;

    for (
        var SampleX = LeftX;
        SampleX <= RightX;
        SampleX += 1
    )
    {
        var TileData = tilemap_get_at_pixel(
            SemiMap,
            SampleX,
            SurfaceY
        );

        if (TileData == -1)
        {
            continue;
        }

        if (tile_get_index(TileData) != 0)
        {
            return true;
        }
    }

    return false;
}

/// @description Comprueba apoyo sobre sólidos y semisólidos

function CheckGround()
{
    if (CheckSolid(x, y + 1))
    {
        return true;
    }

    //No considerar apoyo semisólido mientras se asciende
    if (VSpeed < 0)
    {
        return false;
    }

    return CheckSemi(x, y + 1);
}