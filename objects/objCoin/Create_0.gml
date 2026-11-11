/// @description Configura la recompensa de una moneda

event_inherited();

CanCollectByThrown = true;

image_speed = 0;

//Entregar una moneda al controlador de partida
ApplyReward = function(Game, Player)
{
    Game.AddCoins(1);
	audio_play_sound(sndCollectACoin, 1, false);

    return true;
};