/// @description Alinea al enemigo sujeto después del movimiento del jugador

if (instance_exists(Carrier))
{
    x = round(
        Carrier.x
        + Carrier.CarryOffsetX * Carrier.Facing
    );

    y = round(
        Carrier.y
        + Carrier.CarryOffsetY
    );

    image_xscale = 1;
}