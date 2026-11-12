/// @description Configura la recompensa de una moneda

event_inherited();

CanCollectByThrown = true;

PickupSound = sndCollectACoin;

image_speed = 0;

//Entregar una moneda al controlador de partida
ApplyReward = function(Game, Player)
{
    Game.AddCoins(1);

    return true;
};