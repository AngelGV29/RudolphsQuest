/// @description Configura el corazón de vida extra

event_inherited();

//Recogida directa por Rudolph
CanCollectByThrown = false;

//Cantidad de vidas concedidas
LifeAmount = 1;

//No desaparece por tiempo
HasLifetime = false;

//Sonido de recogida
PickupSound = -1;

image_speed = 0;

//Conceder la vida y consumir incluso con vidas al máximo
ApplyReward = function(Game, Player)
{
    Game.AddLives(LifeAmount);

    return true;
};