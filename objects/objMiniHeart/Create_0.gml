/// @description Configura el minicorazón

event_inherited();

//Recogida directa por Rudolph
CanCollectByThrown = false;

//Cantidad de salud recuperada
HealAmount = 1;

//No desaparece por tiempo
HasLifetime = false;

//Sonido de recogida
PickupSound = sndCollectMiniHeart;

image_speed = 0;

//Aplicar el beneficio y consumir incluso con salud completa
ApplyReward = function(Game, Player)
{
    Player.RecoverHp(HealAmount);

    return true;
};
