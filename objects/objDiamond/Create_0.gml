/// @description Configura el diamante físico

event_inherited();

CanCollectByThrown = true;

PickupSound = sndCollectDiamond;

//Duraciones según los Steps configurados
var StepsPerSecond = game_get_speed(gamespeed_fps);

HasLifetime = true;

LifeFrames = round(StepsPerSecond * 8);
BlinkFrames = round(StepsPerSecond * 2);

BlinkInterval = max(
    1,
    round(StepsPerSecond * 0.1)
);

image_speed = 0;

//Recompensa
ApplyReward = function(Game, Player)
{
    Game.AddDiamonds(1);

    return true;
};