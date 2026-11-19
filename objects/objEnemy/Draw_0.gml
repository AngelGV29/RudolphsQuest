/// @description Dibuja al enemigo salvo que lo represente su portador

var DrawByCarrier = false;

if (instance_exists(Carrier))
{
    DrawByCarrier = Carrier.CarriedEnemy == id;
}

if (!DrawByCarrier)
{
    draw_self();
}